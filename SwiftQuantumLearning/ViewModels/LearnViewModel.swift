//
//  LearnViewModel.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Learning Track Model 삭제 (LearningTrack.swift로 이동)

// MARK: - Learn View Model
@MainActor
class LearnViewModel: ObservableObject {
    @Published var tracks: [LearningTrack] = []
    @Published var currentTrack: Track = .beginner
    @Published var isLoading = false
    @Published var completedLevels: Set<Int> = []
    @Published var errorMessage: String?
    @Published var availableLevels: [LevelListResponse] = []
    
    private let learningService = LearningService.shared
    private let progressService = ProgressService.shared
    private let apiClient = APIClient.shared
    
    init() {
        print("✅ LearnViewModel initialized")
      //  loadTracks()
      //  loadProgress()
    }
    
    func loadTracks() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // 각 트랙별로 레벨 로드
                for track in Track.allCases {
                    let levels: [LevelListResponse] = try await apiClient.get(
                        endpoint: "/api/v1/learning/levels/\(track.rawValue.lowercased())"
                    )
                    
                    DispatchQueue.main.async {
                        self.availableLevels.append(contentsOf: levels)
                    }
                }
                
                DispatchQueue.main.async {
                    self.createTracksFromLevels()
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    // 실패시 로컬 데이터 사용
                    self.createTracksFromLocalData()
                }
                print("❌ Failed to load tracks: \(error)")
            }
        }
    }
    
    func loadProgress() {
        completedLevels = progressService.userProgress.completedLevels
    }
    
    func isLevelUnlocked(_ levelId: Int) -> Bool {
        guard let level = LearningLevel.allLevels.first(where: { $0.id == levelId }) else {
            return false
        }
        
        if level.number == 1 {
            return true
        }
        
        for prereq in level.prerequisites {
            if !completedLevels.contains(prereq) {
                return false
            }
        }
        
        return true
    }
    
    func completeLevel(_ levelId: Int) {
        Task {
            do {
                let request = CompleteLevelRequest(quiz_score: nil)
                let _: CompleteLevelResponse = try await apiClient.post(
                    endpoint: "/api/v1/learning/progress/complete/\(levelId)/practice",
                    body: request
                )
                
                DispatchQueue.main.async {
                    self.progressService.completeLevel(levelId)
                    self.loadProgress()
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                print("❌ Failed to complete level: \(error)")
            }
        }
    }
    
    func getNextLevel() -> LearningLevel? {
        for level in LearningLevel.allLevels {
            if !completedLevels.contains(level.id) && isLevelUnlocked(level.id) {
                return level
            }
        }
        return nil
    }
    
    func getProgress(for track: LearningTrack) -> Double {
        let completedInTrack = track.levels.filter { completedLevels.contains($0.id) }.count
        return track.levels.isEmpty ? 0 : Double(completedInTrack) / Double(track.levels.count)
    }
    
    private func createTracksFromLevels() {
        let beginnerLevels = LearningLevel.allLevels.filter { $0.track == .beginner }
        let intermediateLevels = LearningLevel.allLevels.filter { $0.track == .intermediate }
        let advancedLevels = LearningLevel.allLevels.filter { $0.track == .advanced }
        
        tracks = [
            LearningTrack(
                name: "Beginner",
                description: "Start your quantum journey",
                iconName: "star.fill",
                levels: beginnerLevels
            ),
            LearningTrack(
                name: "Intermediate",
                description: "Build on the fundamentals",
                iconName: "star.leadinghalf.filled",
                levels: intermediateLevels
            ),
            LearningTrack(
                name: "Advanced",
                description: "Master quantum computing",
                iconName: "star.circle.fill",
                levels: advancedLevels
            )
        ]
    }
    
    private func createTracksFromLocalData() {
        let beginnerLevels = LearningLevel.allLevels.filter { $0.track == .beginner }
        let intermediateLevels = LearningLevel.allLevels.filter { $0.track == .intermediate }
        let advancedLevels = LearningLevel.allLevels.filter { $0.track == .advanced }
        
        tracks = [
            LearningTrack(
                name: "Beginner",
                description: "Start your quantum journey",
                iconName: "star.fill",
                levels: beginnerLevels
            ),
            LearningTrack(
                name: "Intermediate",
                description: "Build on the fundamentals",
                iconName: "star.leadinghalf.filled",
                levels: intermediateLevels
            ),
            LearningTrack(
                name: "Advanced",
                description: "Master quantum computing",
                iconName: "star.circle.fill",
                levels: advancedLevels
            )
        ]
    }
    
    static let sample: LearnViewModel = {
        let vm = LearnViewModel()
        vm.completedLevels = [1, 2]
        return vm
    }()
}
