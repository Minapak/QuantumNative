//
//  ProgressService.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - Progress Service
/// Service responsible for tracking and updating user progress
@MainActor
class ProgressService: ObservableObject {
    
    // MARK: - Singleton
    static let shared = ProgressService()
    
    // MARK: - Published Properties
    @Published var userProgress: UserProgress
    @Published var dailyGoals: DailyGoals
    
    // MARK: - Private Properties
    private let storageService = StorageService.shared
    private let achievementService = AchievementService.shared
    
    // MARK: - Initialization
    private init() {
        self.userProgress = UserProgress()
        self.dailyGoals = DailyGoals()
        loadProgress()
    }
    
    // MARK: - Progress Management
    
    /// Load user progress from storage
    func loadProgress() {
        userProgress = storageService.loadUserProgress() ?? UserProgress()
        dailyGoals = storageService.loadDailyGoals() ?? DailyGoals()
    }
    
    /// Save current progress
    func saveProgress() {
        storageService.saveUserProgress(userProgress)
        storageService.saveDailyGoals(dailyGoals)
    }
    
    /// Add XP and check for level up
    func addXP(_ amount: Int, reason: String = "General") -> Bool {
        let previousLevel = userProgress.userLevel
        userProgress.addXP(amount)
        
        // Track XP source
        trackXPSource(amount: amount, reason: reason)
        
        // Check achievements
        achievementService.checkXPAchievements(totalXP: userProgress.totalXP)
        
        saveProgress()
        
        return userProgress.userLevel > previousLevel
    }
    
    /// Complete a level
    func completeLevel(_ levelId: Int) {
        userProgress.completeLevel(levelId)
        
        // Update daily goals
        dailyGoals.levelsCompletedToday += 1
        
        // Check achievements
        achievementService.checkLevelAchievements(
            completedCount: userProgress.completedLevelIds.count
        )
        
        saveProgress()
    }
    
    /// Update streak
    func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastDate = userProgress.lastStudyDate {
            let lastDay = Calendar.current.startOfDay(for: lastDate)
            let daysDifference = Calendar.current.dateComponents([.day], 
                                                                from: lastDay, 
                                                                to: today).day ?? 0
            
            if daysDifference == 1 {
                userProgress.currentStreak += 1
            } else if daysDifference > 1 {
                userProgress.currentStreak = 1
            }
        } else {
            userProgress.currentStreak = 1
        }
        
        userProgress.longestStreak = max(userProgress.longestStreak, 
                                        userProgress.currentStreak)
        userProgress.lastStudyDate = Date()
        
        // Check streak achievements
        achievementService.checkStreakAchievements(
            currentStreak: userProgress.currentStreak
        )
        
        saveProgress()
    }
    
    /// Track XP source for analytics
    private func trackXPSource(amount: Int, reason: String) {
        // This could be expanded to track detailed analytics
        print("Added \(amount) XP for: \(reason)")
    }
    
    /// Reset daily goals (called at midnight)
    func resetDailyGoals() {
        dailyGoals = DailyGoals()
        saveProgress()
    }
    
    /// Check if daily goals are completed
    func checkDailyGoalsCompletion() -> Bool {
        return dailyGoals.levelsCompletedToday >= dailyGoals.targetLevels &&
               dailyGoals.xpEarnedToday >= dailyGoals.targetXP
    }
}

// MARK: - Daily Goals Model
struct DailyGoals: Codable {
    var targetXP: Int = 50
    var targetLevels: Int = 1
    var xpEarnedToday: Int = 0
    var levelsCompletedToday: Int = 0
    var lastResetDate: Date = Date()
}