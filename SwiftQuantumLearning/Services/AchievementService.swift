//
//  AchievementService.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - Achievement Service
/// Service responsible for managing achievements and badges
@MainActor
class AchievementService: ObservableObject {
    
    // MARK: - Singleton
    static let shared = AchievementService()
    
    // MARK: - Published Properties
    @Published var unlockedAchievements: [String: Date] = [:]
    @Published var recentlyUnlocked: Achievement?
    @Published var showNotification = false
    
    // MARK: - Private Properties
    private let storageService = StorageService.shared
    private var allAchievements: [Achievement] = Achievement.allAchievements
    
    // MARK: - Initialization
    private init() {
        loadAchievements()
    }
    
    // MARK: - Achievement Management
    
    /// Load achievements from storage
    func loadAchievements() {
        unlockedAchievements = storageService.loadAchievements() ?? [:]
    }
    
    /// Save achievements to storage
    func saveAchievements() {
        storageService.saveAchievements(unlockedAchievements)
    }
    
    /// Unlock an achievement
    func unlockAchievement(_ achievementId: String) {
        guard unlockedAchievements[achievementId] == nil,
              let achievement = allAchievements.first(where: { $0.id == achievementId }) else {
            return
        }
        
        unlockedAchievements[achievementId] = Date()
        recentlyUnlocked = achievement
        showNotification = true
        
        saveAchievements()
        
        // Hide notification after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.showNotification = false
        }
    }
    
    /// Check if achievement is unlocked
    func isUnlocked(_ achievementId: String) -> Bool {
        unlockedAchievements[achievementId] != nil
    }
    
    /// Get unlock date for achievement
    func getUnlockDate(for achievementId: String) -> Date? {
        unlockedAchievements[achievementId]
    }
    
    // MARK: - Achievement Checking
    
    /// Check XP-based achievements
    func checkXPAchievements(totalXP: Int) {
        if totalXP >= 500 && !isUnlocked("xp_500") {
            unlockAchievement("xp_500")
        }
        if totalXP >= 1000 && !isUnlocked("xp_1000") {
            unlockAchievement("xp_1000")
        }
        if totalXP >= 2000 && !isUnlocked("xp_2000") {
            unlockAchievement("xp_2000")
        }
        if totalXP >= 5000 && !isUnlocked("xp_5000") {
            unlockAchievement("xp_5000")
        }
    }
    
    /// Check level completion achievements
    func checkLevelAchievements(completedCount: Int) {
        if completedCount >= 1 && !isUnlocked("first_lesson") {
            unlockAchievement("first_lesson")
        }
        if completedCount >= 3 && !isUnlocked("quantum_novice") {
            unlockAchievement("quantum_novice")
        }
        if completedCount >= 8 && !isUnlocked("quantum_adept") {
            unlockAchievement("quantum_adept")
        }
        if completedCount >= LearningLevel.allLevels.count && !isUnlocked("quantum_master") {
            unlockAchievement("quantum_master")
        }
    }
    
    /// Check streak achievements
    func checkStreakAchievements(currentStreak: Int) {
        if currentStreak >= 7 && !isUnlocked("week_warrior") {
            unlockAchievement("week_warrior")
        }
        if currentStreak >= 30 && !isUnlocked("month_master") {
            unlockAchievement("month_master")
        }
        if currentStreak >= 100 && !isUnlocked("century_scholar") {
            unlockAchievement("century_scholar")
        }
    }
    
    /// Check time-based achievements
    func checkTimeAchievements(totalMinutes: Int) {
        if totalMinutes >= 60 && !isUnlocked("hour_scholar") {
            unlockAchievement("hour_scholar")
        }
        if totalMinutes >= 300 && !isUnlocked("dedicated_learner") {
            unlockAchievement("dedicated_learner")
        }
        if totalMinutes >= 1200 && !isUnlocked("quantum_devotee") {
            unlockAchievement("quantum_devotee")
        }
    }
    
    /// Check special achievements
    func checkSpecialAchievements() {
        // Early adopter - check if user started within first week
        let firstWeekEnd = Date(timeIntervalSince1970: 1735948800) // Example date
        if Date() < firstWeekEnd && !isUnlocked("early_adopter") {
            unlockAchievement("early_adopter")
        }
    }
    
    // MARK: - Statistics
    
    /// Get achievement statistics
    func getStatistics() -> AchievementStatistics {
        let unlocked = unlockedAchievements.count
        let total = allAchievements.count
        let percentage = total > 0 ? (unlocked * 100) / total : 0
        
        let totalXP = allAchievements
            .filter { isUnlocked($0.id) }
            .reduce(0) { $0 + $1.xpReward }
        
        return AchievementStatistics(
            unlockedCount: unlocked,
            totalCount: total,
            completionPercentage: percentage,
            totalXPEarned: totalXP
        )
    }
}

// MARK: - Achievement Statistics
struct AchievementStatistics {
    let unlockedCount: Int
    let totalCount: Int
    let completionPercentage: Int
    let totalXPEarned: Int
}