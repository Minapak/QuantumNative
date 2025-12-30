//
//  LearningService.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - Learning Service
/// Service responsible for managing learning content and curriculum
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
        
        // Load from bundled data or remote source
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
        
        // First level is always unlocked
        if level.number == 1 {
            return true
        }
        
        // Check if previous level in track is completed
        let trackLevels = getLevels(for: level.track)
        guard let currentIndex = trackLevels.firstIndex(where: { $0.id == levelId }),
              currentIndex > 0 else {
            return false
        }
        
        let previousLevel = trackLevels[currentIndex - 1]
        return completedLevels.contains(previousLevel.id)
    }
    
    /// Calculate total XP for track
    func getTotalXP(for track: Track) -> Int {
        getLevels(for: track).reduce(0) { $0 + 100 } // Base XP per level
    }
    
    /// Get recommended next level based on user progress
    func getRecommendedLevel(completedLevels: Set<Int>) -> LearningLevel? {
        // Find first uncompleted level that is unlocked
        for level in availableLevels {
            if !completedLevels.contains(level.id) && 
               isLevelUnlocked(level.id, completedLevels: completedLevels) {
                return level
            }
        }
        return nil
    }
}