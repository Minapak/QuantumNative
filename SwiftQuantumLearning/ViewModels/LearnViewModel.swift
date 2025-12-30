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

// MARK: - Learning Track Model
struct LearningTrack: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let iconName: String
    let levels: [LearningLevel]
    
    var totalXP: Int {
        levels.reduce(0) { $0 + $1.xpReward }
    }
}

// MARK: - Learn View Model
@MainActor
class LearnViewModel: ObservableObject {
    @Published var tracks: [LearningTrack] = []
    @Published var currentTrack: Track = .beginner
    @Published var isLoading = false
    @Published var completedLevels: Set<Int> = []
    
    private let learningService = LearningService.shared
    private let progressService = ProgressService.shared
    
    init() {
        loadTracks()
        loadProgress()
    }
    
    func loadTracks() {
        isLoading = true
        
        // Create tracks from LearningLevel data
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
        
        isLoading = false
    }
    
    func loadProgress() {
        completedLevels = progressService.userProgress.completedLevels
    }
    
    func isLevelUnlocked(_ levelId: Int) -> Bool {
        // First level is always unlocked
        guard let level = LearningLevel.allLevels.first(where: { $0.id == levelId }) else {
            return false
        }
        
        // Level 1 of any track is always unlocked
        if level.number == 1 {
            return true
        }
        
        // Check if prerequisites are met
        for prereq in level.prerequisites {
            if !completedLevels.contains(prereq) {
                return false
            }
        }
        
        return true
    }
    
    func completeLevel(_ levelId: Int) {
        progressService.completeLevel(levelId)
        loadProgress()
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
    
    static let sample: LearnViewModel = {
        let vm = LearnViewModel()
        vm.completedLevels = [1, 2]
        return vm
    }()
}
