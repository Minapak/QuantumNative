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
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let achievementService = AchievementService.shared
    private let apiClient = APIClient.shared
    
    init() {
        print("✅ AchievementViewModel initialized")
        //loadAchievements()
    }
    
    func loadAchievements() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response: AchievementsListResponse = try await apiClient.get(
                    endpoint: "/api/v1/achievements/"
                )
                
                DispatchQueue.main.async {
                    // Convert API response to Achievement model
                    self.achievements = response.achievements.map { apiAchievement in
                        var achievement = Achievement.allAchievements.first { $0.id == apiAchievement.id } ?? Achievement(
                            id: apiAchievement.id,
                            title: apiAchievement.title,
                            description: apiAchievement.description,
                            emoji: apiAchievement.icon,
                            iconName: "star.fill",
                            xpReward: apiAchievement.xp_reward,
                            category: Category(rawValue: apiAchievement.category) ?? .progress,
                            rarity: Rarity(rawValue: apiAchievement.rarity) ?? .common
                        )
                        
                        if apiAchievement.is_unlocked {
                            achievement.unlockedDate = Date()
                        }
                        
                        return achievement
                    }
                    
                    self.totalCount = response.total
                    self.unlockedCount = response.unlocked
                    self.completionPercentage = response.total > 0 ? (response.unlocked * 100) / response.total : 0
                    self.totalAchievementXP = self.achievements
                        .filter { $0.isUnlocked }
                        .reduce(0) { $0 + $1.xpReward }
                    
                    self.updateRecentUnlocks()
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    // 실패시 로컬 데이터 사용
                    self.loadLocalAchievements()
                }
                print("❌ Failed to load achievements: \(error)")
            }
        }
    }
    
    func achievements(for category: Category) -> [Achievement] {
        achievements.filter { $0.category == category }
    }
    
    private func updateRecentUnlocks() {
        recentUnlocks = achievements
            .filter { $0.isUnlocked }
            .sorted { ($0.unlockedDate ?? Date()) > ($1.unlockedDate ?? Date()) }
            .prefix(3)
            .map { $0 }
    }
    
    private func loadLocalAchievements() {
        achievements = Achievement.allAchievements
        totalCount = achievements.count
        let stats = achievementService.getStatistics()
        unlockedCount = stats.unlockedCount
        totalCount = stats.totalCount
        completionPercentage = stats.completionPercentage
        totalAchievementXP = stats.totalXPEarned
        
        updateRecentUnlocks()
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
