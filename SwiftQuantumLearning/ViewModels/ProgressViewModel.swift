//
//  ProgressViewModel.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - Progress View Model
@MainActor
class ProgressViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var userProgress: UserProgress
    @Published var totalXP: Int = 0
    @Published var currentLevel: Int = 1
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var completedLevelsCount: Int = 0
    @Published var userName: String = "Quantum Learner"
    @Published var studyTimeMinutes: Int = 0
    
    // MARK: - Computed Properties
    var xpToNextLevel: Int {
        (currentLevel + 1) * 100 - (totalXP % 100)
    }
    
    var progressToNextLevel: Double {
        Double(totalXP % 100) / 100.0
    }
    
    var studyTimeText: String {
        let hours = studyTimeMinutes / 60
        let minutes = studyTimeMinutes % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes) min"
    }
    
    // MARK: - Services
    private let progressService = ProgressService.shared
    
    // MARK: - Initialization
    init() {
        self.userProgress = UserProgress()
        loadProgress()
    }
    
    // MARK: - Methods
    func loadProgress() {
        userProgress = progressService.userProgress
        updatePublishedProperties()
    }
    
    func addXP(_ amount: Int, reason: String = "General") {
        let leveledUp = progressService.addXP(amount, reason: reason)
        updatePublishedProperties()
        
        if leveledUp {
            // Handle level up celebration
            QuantumTheme.Haptics.success()
        }
    }
    
    func completeLevel(_ levelId: Int) {
        progressService.completeLevel(levelId)
        updatePublishedProperties()
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
        currentLevel = userProgress.userLevel
        currentStreak = userProgress.currentStreak
        longestStreak = userProgress.longestStreak
        completedLevelsCount = userProgress.completedLevelIds.count
    }
    
    // MARK: - Sample Data
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
