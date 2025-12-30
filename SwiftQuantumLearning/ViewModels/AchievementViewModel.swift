//
//  AchievementViewModel.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - Achievement View Model
@MainActor
class AchievementViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var achievements: [Achievement] = []
    @Published var unlockedCount: Int = 0
    @Published var totalCount: Int = 0
    @Published var completionPercentage: Int = 0
    @Published var totalAchievementXP: Int = 0
    @Published var showNotification: Bool = false
    @Published var recentlyUnlocked: Achievement?
    
    // MARK: - Services
    private let achievementService = AchievementService.shared
    
    // MARK: - Initialization
    init() {
        loadAchievements()
    }
    
    // MARK: - Methods
    func loadAchievements() {
        achievements = Achievement.allAchievements
        updateStatistics()
        
        // Update unlock status for each achievement
        for index in achievements.indices {
            achievements[index].isUnlocked = achievementService.isUnlocked(achievements[index].id)
        }
    }
    
    func unlockAchievement(_ achievementId: String) {
        achievementService.unlockAchievement(achievementId)
        loadAchievements()
    }
    
    private func updateStatistics() {
        let stats = achievementService.getStatistics()
        unlockedCount = stats.unlockedCount
        totalCount = stats.totalCount
        completionPercentage = stats.completionPercentage
        totalAchievementXP = stats.totalXPEarned
    }
    
    // MARK: - Sample Data
    static let sample: AchievementViewModel = {
        let vm = AchievementViewModel()
        vm.unlockedCount = 12
        vm.totalCount = 25
        vm.completionPercentage = 48
        vm.totalAchievementXP = 850
        return vm
    }()
}
