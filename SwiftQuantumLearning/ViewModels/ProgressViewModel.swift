//
//  ProgressViewModel.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ProgressViewModel: ObservableObject {
    @Published var userProgress: UserProgress = UserProgress()
    @Published var totalXP: Int = 0
    @Published var currentLevel: Int = 1
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var completedLevelsCount: Int = 0
    @Published var userName: String = "Quantum Learner"
    @Published var studyTimeMinutes: Int = 0
    @Published var userLevel: Int = 1
    @Published var xpUntilNextLevel: Int = 500
    @Published var levelProgress: Double = 0.0
    @Published var totalLevelsCount: Int = 10
    @Published var overallProgressPercentage: Int = 0
    
    private let progressService = ProgressService.shared
    
    init() {
        loadProgress()
    }
    
    var studyTimeText: String {
        let hours = studyTimeMinutes / 60
        let minutes = studyTimeMinutes % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes) min"
    }
    
    func loadProgress() {
        progressService.loadProgress()
        userProgress = progressService.userProgress
        updatePublishedProperties()
    }
    
    @discardableResult
    func addXP(_ amount: Int, reason: String = "General") -> Bool {
        let leveledUp = progressService.addXP(amount, reason: reason)
        updatePublishedProperties()
        return leveledUp
    }
    
    func completeLevel(_ levelId: String, xp: Int) {
        if let id = Int(levelId) {
            progressService.completeLevel(id)
            addXP(xp, reason: "Level completed")
            updatePublishedProperties()
        }
    }
    
    func updateStreak() {
        progressService.updateStreak()
        updatePublishedProperties()
    }
    
    func resetProgress() {
        userProgress = UserProgress()
        progressService.userProgress = userProgress
        progressService.saveProgress()
        updatePublishedProperties()
    }
    
    private func updatePublishedProperties() {
        totalXP = userProgress.totalXP
        currentLevel = userProgress.currentLevel
        userLevel = userProgress.userLevel
        currentStreak = userProgress.currentStreak
        longestStreak = userProgress.longestStreak
        completedLevelsCount = userProgress.completedLevels.count
        userName = userProgress.userName
        studyTimeMinutes = userProgress.studyTimeMinutes
        xpUntilNextLevel = userProgress.xpUntilNextLevel
        levelProgress = userProgress.levelProgress
        totalLevelsCount = LearningLevel.allLevels.count
        overallProgressPercentage = totalLevelsCount > 0 ? (completedLevelsCount * 100) / totalLevelsCount : 0
    }
    
    static let sample: ProgressViewModel = {
        let vm = ProgressViewModel()
        vm.totalXP = 1250
        vm.currentLevel = 12
        vm.currentStreak = 7
        vm.longestStreak = 15
        vm.completedLevelsCount = 8
        vm.userName = "Sample User"
        vm.studyTimeMinutes = 450
        return vm
    }()
}
