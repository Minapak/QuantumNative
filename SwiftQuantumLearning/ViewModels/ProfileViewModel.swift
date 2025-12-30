//
//  ProfileViewModel.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var userStats: UserStats = UserStats()
    @Published var settings = AppSettings()
    
    private let progressService = ProgressService.shared
    private let storageService = StorageService.shared
    
    init() {
        loadProfile()
    }
    
    func loadProfile() {
        userName = progressService.userProgress.userName
        userStats = UserStats(
            totalXP: progressService.userProgress.totalXP,
            level: progressService.userProgress.userLevel,
            streak: progressService.userProgress.currentStreak,
            completedLevels: progressService.userProgress.completedLevelIds.count,
            studyTime: progressService.userProgress.totalStudyMinutes
        )
        
        if let loadedSettings = storageService.loadSettings() {
            settings = loadedSettings
        }
    }
    
    func saveSettings() {
        storageService.saveSettings(settings)
    }
}

struct UserStats {
    var totalXP: Int = 0
    var level: Int = 1
    var streak: Int = 0
    var completedLevels: Int = 0
    var studyTime: Int = 0
}