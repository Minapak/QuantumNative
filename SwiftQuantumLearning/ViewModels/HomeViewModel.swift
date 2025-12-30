//
//  HomeViewModel.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var currentLevel: LearningLevel?
    @Published var recentAchievements: [Achievement] = []
    @Published var dailyChallenge: DailyChallenge?
    @Published var isLoading = false
    
    private let progressService = ProgressService.shared
    private let achievementService = AchievementService.shared
    
    init() {
        loadData()
    }
    
    func loadData() {
        isLoading = true
        
        // Load current level
        if let currentLevelId = progressService.userProgress.currentLevelId {
            currentLevel = LearningLevel.allLevels.first { $0.id == currentLevelId }
        }
        
        // Load recent achievements
        let unlockedIds = Array(achievementService.unlockedAchievements.keys)
        recentAchievements = Achievement.allAchievements
            .filter { unlockedIds.contains($0.id) }
            .sorted { (achievementService.unlockedAchievements[$0.id] ?? Date()) > 
                     (achievementService.unlockedAchievements[$1.id] ?? Date()) }
            .prefix(3)
            .map { $0 }
        
        // Load daily challenge
        dailyChallenge = DailyChallenge(
            id: "daily_1",
            title: "Create Superposition",
            description: "Apply Hadamard gate to create superposition",
            iconName: "waveform",
            xpReward: 50,
            streakBonus: 5,
            isCompleted: progressService.userProgress.dailyChallengeCompletedToday
        )
        
        isLoading = false
    }
    
    func completeDailyChallenge() {
        progressService.userProgress.completeDailyChallenge()
        dailyChallenge?.isCompleted = true
    }
}

// Daily Challenge model
struct DailyChallenge {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let xpReward: Int
    let streakBonus: Int
    var isCompleted: Bool
}