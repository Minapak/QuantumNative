//
//  LearningService.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class LearningService: ObservableObject {
    
    // MARK: - Singleton
    static let shared = LearningService()
    
    // MARK: - Published Properties
    @Published var availableLevels: [LearningLevel] = []
    @Published var currentTrack: Track = .beginner
    @Published var isLoading = false
    
    // MARK: - Private Properties
    private let storageService = StorageService.shared
    
    // MARK: - Initialization
    private init() {
        loadLearningContent()
    }
    
    // MARK: - Public Methods
    
    /// Load all learning content
    func loadLearningContent() {
        isLoading = true
        
        DispatchQueue.main.async { [weak self] in
            self?.availableLevels = LearningLevel.allLevels
            self?.isLoading = false
        }
    }
    
    /// Get levels for specific track
    func getLevels(for track: Track) -> [LearningLevel] {
        availableLevels.filter { $0.track == track }
    }
    
    /// Get next available level for user
    func getNextLevel(after levelId: Int) -> LearningLevel? {
        guard let currentIndex = availableLevels.firstIndex(where: { $0.id == levelId }) else {
            return nil
        }
        
        let nextIndex = currentIndex + 1
        return nextIndex < availableLevels.count ? availableLevels[nextIndex] : nil
    }
    
    /// Check if level is unlocked based on prerequisites
    func isLevelUnlocked(_ levelId: Int, completedLevels: Set<Int>) -> Bool {
        guard let level = availableLevels.first(where: { $0.id == levelId }) else {
            return false
        }
        
        if level.number == 1 {
            return true
        }
        
        let trackLevels = getLevels(for: level.track)
        guard let currentIndex = trackLevels.firstIndex(where: { $0.id == levelId }),
              currentIndex > 0 else {
            return false
        }
        
        let previousLevel = trackLevels[currentIndex - 1]
        return completedLevels.contains(previousLevel.id)
    }
    
    /// Complete a lesson
    func completeLesson(levelId: Int, lessonId: String) {
        print("Completing lesson \(lessonId) in level \(levelId)")
    }
    
    /// Calculate total XP for track - 수정된 reduce
    func getTotalXP(for track: Track) -> Int {
        getLevels(for: track).reduce(0) { accumulator, level in
            accumulator + level.xpReward
        }
    }
    
    /// Get recommended next level based on user progress
    func getRecommendedLevel(completedLevels: Set<Int>) -> LearningLevel? {
        for level in availableLevels {
            if !completedLevels.contains(level.id) &&
               isLevelUnlocked(level.id, completedLevels: completedLevels) {
                return level
            }
        }
        return nil
    }
}
