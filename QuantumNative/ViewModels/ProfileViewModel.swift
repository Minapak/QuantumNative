//
//  ProfileViewModel.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var userName: String = "Quantum Learner"
    @Published var userLevel: Int = 1
    @Published var totalXP: Int = 0
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var completedLevelsCount: Int = 0
    @Published var completedLevelsIds: Set<Int> = []  // 추가
    @Published var totalStudyMinutes: Int = 0  // 추가
    @Published var badgesEarned: Int = 0
    @Published var isProUser: Bool = false
    @Published var joinDate: Date = Date()
    @Published var lastActiveDate: Date = Date()
    
    private let progressService = ProgressService.shared
    private let achievementService = AchievementService.shared
    
    init() {
        loadUserProfile()
    }
    
    func loadUserProfile() {
        // Load from progress service
        let progress = progressService.userProgress
        
        userName = progress.userName
        totalXP = progress.totalXP
        userLevel = progress.userLevel
        currentStreak = progress.currentStreak
        longestStreak = progress.longestStreak
        completedLevelsCount = progress.completedLevels.count
        completedLevelsIds = progress.completedLevels  // 설정
        totalStudyMinutes = progress.studyTimeMinutes  // 설정
        lastActiveDate = progress.lastActiveDate
        
        // Load achievement data
        let achievements = achievementService.getStatistics()
        badgesEarned = achievements.unlockedCount
    }
    
    func updateProfile() {
        progressService.saveProgress()
        loadUserProfile()
    }
    
    func resetAllProgress() {
        progressService.userProgress = UserProgress()
        progressService.saveProgress()
        loadUserProfile()
    }
    
    var profileCompletionPercentage: Int {
        var completed = 0
        let total = 5
        
        if !userName.isEmpty && userName != "Quantum Learner" { completed += 1 }
        if totalXP > 0 { completed += 1 }
        if completedLevelsCount > 0 { completed += 1 }
        if badgesEarned > 0 { completed += 1 }
        if currentStreak > 0 { completed += 1 }
        
        return (completed * 100) / total
    }
    
    var studyTimeText: String {
        let hours = totalStudyMinutes / 60
        let minutes = totalStudyMinutes % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes) min"
        }
    }
    
    var membershipDurationText: String {
        let days = Calendar.current.dateComponents([.day], from: joinDate, to: Date()).day ?? 0
        
        if days == 0 {
            return "Today"
        } else if days == 1 {
            return "1 day"
        } else if days < 30 {
            return "\(days) days"
        } else if days < 365 {
            let months = days / 30
            return months == 1 ? "1 month" : "\(months) months"
        } else {
            let years = days / 365
            return years == 1 ? "1 year" : "\(years) years"
        }
    }
}
