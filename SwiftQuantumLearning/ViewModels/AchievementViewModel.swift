//
//  AchievementViewModel.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AchievementViewModel: ObservableObject {
    @Published var achievements: [Achievement] = []
    @Published var unlockedCount: Int = 0
    @Published var totalCount: Int = 0
    @Published var completionPercentage: Int = 0
    @Published var totalAchievementXP: Int = 0
    @Published var recentUnlocks: [Achievement] = []
    
    private let achievementService = AchievementService.shared
    
    init() {
        loadAchievements()
    }
    
    func loadAchievements() {
        // Achievement.allAchievements 사용
        achievements = Achievement.allAchievements
        totalCount = achievements.count
        updateStatistics()
    }
    
    func achievements(for category: Category) -> [Achievement] {
        achievements.filter { $0.category == category }
    }
    
    private func updateStatistics() {
        let stats = achievementService.getStatistics()
        unlockedCount = stats.unlockedCount
        totalCount = stats.totalCount
        completionPercentage = stats.completionPercentage
        totalAchievementXP = stats.totalXPEarned
        
        // Recent unlocks
        recentUnlocks = achievements
            .filter { achievementService.isUnlocked($0.id) }
            .sorted {
                (achievementService.getUnlockDate(for: $0.id) ?? Date()) >
                (achievementService.getUnlockDate(for: $1.id) ?? Date())
            }
            .prefix(3)
            .map { $0 }
    }
    
    static let sample: AchievementViewModel = {
        let vm = AchievementViewModel()
        vm.unlockedCount = 12
        vm.totalCount = 25
        vm.completionPercentage = 48
        vm.totalAchievementXP = 850
        return vm
    }()
}
