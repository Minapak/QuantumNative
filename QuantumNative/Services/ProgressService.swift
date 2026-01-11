//
//  ProgressService.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ProgressService: ObservableObject {
    
    // MARK: - Singleton
    static let shared = ProgressService()
    
    @Published var userProgress: UserProgress
    @Published var dailyGoals: DailyGoals
    
    private let storageService = StorageService.shared
    private let achievementService = AchievementService.shared
    
    private init() {
        self.userProgress = UserProgress()
        self.dailyGoals = DailyGoals()
        loadProgress()
    }
    
    func loadProgress() {
        userProgress = storageService.loadUserProgress() ?? UserProgress()
        dailyGoals = storageService.loadDailyGoals() ?? DailyGoals()
    }
    
    func saveProgress() {
        storageService.saveUserProgress(userProgress)
        storageService.saveDailyGoals(dailyGoals)
    }
    
    /// Add XP and check for level up
    @discardableResult
    func addXP(_ amount: Int, reason: String = "General") -> Bool {
        let previousLevel = userProgress.userLevel
        userProgress.totalXP += amount
        userProgress.addXP(amount)
        
        // Track XP source
        trackXPSource(amount: amount, reason: reason)
        
        // Check achievements
        achievementService.checkXPAchievements(totalXP: userProgress.totalXP)
        
        saveProgress()
        
        return userProgress.userLevel > previousLevel
    }
    
    func completeLevel(_ levelId: Int) {
        userProgress.completeLevel(levelId)
        
        // Update daily goals
        dailyGoals.levelsCompletedToday += 1
        
        // Check achievements
        achievementService.checkLevelAchievements(
            completedCount: userProgress.completedLevels.count
        )
        
        saveProgress()
    }
    
    func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastDay = Calendar.current.startOfDay(for: userProgress.lastActiveDate)
        let daysDifference = Calendar.current.dateComponents([.day],
                                                            from: lastDay,
                                                            to: today).day ?? 0
        
        if daysDifference == 0 {
            // Same day, no change needed
            return
        } else if daysDifference == 1 {
            // Next day, increment streak
            userProgress.currentStreak += 1
        } else if daysDifference > 1 {
            // Missed days, reset streak
            userProgress.currentStreak = 1
        }
        
        userProgress.longestStreak = max(userProgress.longestStreak,
                                        userProgress.currentStreak)
        userProgress.lastActiveDate = Date()
        
        // Check streak achievements
        achievementService.checkStreakAchievements(
            currentStreak: userProgress.currentStreak
        )
        
        saveProgress()
    }
    
    private func trackXPSource(amount: Int, reason: String) {
        print("Added \(amount) XP for: \(reason)")
    }
    
    func resetDailyGoals() {
        dailyGoals = DailyGoals()
        saveProgress()
    }
    
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
