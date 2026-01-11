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
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let progressService = ProgressService.shared
    private let apiClient = APIClient.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
          // 🔧 init에서 API 호출 제거 - 로그인 후 수동 호출
          print("✅ ProgressViewModel initialized")
      }
    
    var studyTimeText: String {
        let hours = studyTimeMinutes / 60
        let minutes = studyTimeMinutes % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes) min"
    }
    
    // MARK: - API Methods
    
    func loadProgress() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let stats: UserStatsResponse = try await apiClient.get(
                    endpoint: "/api/v1/users/me/stats"
                )
                
                DispatchQueue.main.async {
                    self.totalXP = stats.total_xp
                    self.currentLevel = stats.current_level
                    self.userLevel = stats.current_level
                    self.currentStreak = stats.current_streak
                    self.longestStreak = stats.longest_streak
                    self.completedLevelsCount = stats.levels_completed
                    self.studyTimeMinutes = stats.total_study_time_minutes
                    self.xpUntilNextLevel = stats.xp_until_next_level
                    self.levelProgress = stats.level_progress
                    
                    // Update user progress
                    self.userProgress.totalXP = stats.total_xp
                    self.userProgress.currentLevel = stats.current_level
                    self.userProgress.currentStreak = stats.current_streak
                    self.userProgress.longestStreak = stats.longest_streak
                    
                    // ✅ 이 부분 수정
                    if stats.levels_completed > 0 {
                        self.userProgress.completedLevels = Set(1...stats.levels_completed)
                    } else {
                        self.userProgress.completedLevels = Set()
                    }
                    
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
                print("❌ Failed to load progress: \(error)")
            }
        }
    }
    
    @discardableResult
    func addXP(_ amount: Int, reason: String = "General") -> Bool {
        let leveledUp = progressService.addXP(amount, reason: reason)
        updatePublishedProperties()
        return leveledUp
    }
    
    /// Complete a level - fixed async/await
    func completeLevel(_ levelId: String, xp: Int) {
        if let id = Int(levelId) {
            Task {
                do {
                    let request = CompleteLevelRequest(quiz_score: nil)
                    let response: CompleteLevelResponse = try await apiClient.post(
                        endpoint: "/api/v1/learning/progress/complete/\(id)/explanation",
                        body: request
                    )
                    
                    // ✅ MainActor 컨텍스트에서 안전하게 업데이트
                    self.progressService.completeLevel(id)
                    self.addXP(response.xp_earned, reason: "Level completed")
                    self.updatePublishedProperties()
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = error.localizedDescription
                    }
                    print("❌ Failed to complete level: \(error)")
                }
            }
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
