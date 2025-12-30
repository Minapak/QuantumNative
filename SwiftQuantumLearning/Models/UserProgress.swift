//
//  UserProgress.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import Foundation
import Combine

// UserProgress as a struct for Codable
struct UserProgress: Codable {
    var totalXP: Int
    var currentLevel: Int
    var completedLevels: Set<Int>
    var achievements: [String]
    var currentStreak: Int
    var lastActiveDate: Date
    var studyTimeMinutes: Int = 0
    var practiceSessionsCompleted: Int = 0
    var userName: String = "Quantum Learner"
    var longestStreak: Int = 0
    var currentLevelId: Int?
    var currentLevelProgress: Int = 0
    var dailyChallengeCompletedToday: Bool = false
    var lastDailyChallengeDate: Date?
    
    init(totalXP: Int = 0,
         currentLevel: Int = 1,
         completedLevels: Set<Int> = [],
         achievements: [String] = [],
         currentStreak: Int = 0,
         lastActiveDate: Date = Date()) {
        self.totalXP = totalXP
        self.currentLevel = currentLevel
        self.completedLevels = completedLevels
        self.achievements = achievements
        self.currentStreak = currentStreak
        self.lastActiveDate = lastActiveDate
        self.userName = "Quantum Learner"
        self.longestStreak = 0
        self.studyTimeMinutes = 0
    }
    
    // Computed Properties
    var userLevel: Int {
        (totalXP / 500) + 1
    }
    
    var xpForNextLevel: Int {
        userLevel * 500
    }
    
    var xpUntilNextLevel: Int {
        xpForNextLevel - totalXP
    }
    
    var levelProgress: Double {
        let currentLevelXP = totalXP - ((userLevel - 1) * 500)
        let xpInLevel = 500
        return Double(currentLevelXP) / Double(xpInLevel)
    }
    
    var studyTimeText: String {
        if studyTimeMinutes < 60 {
            return "\(studyTimeMinutes) min"
        } else {
            let hours = studyTimeMinutes / 60
            let mins = studyTimeMinutes % 60
            return mins > 0 ? "\(hours)h \(mins)m" : "\(hours) hours"
        }
    }
    
    // Methods
    mutating func addXP(_ amount: Int) {
        totalXP += amount
    }
    
    mutating func completeLevel(_ levelId: Int) {
        completedLevels.insert(levelId)
        addXP(100)
    }
    
    mutating func completeDailyChallenge() {
        dailyChallengeCompletedToday = true
        lastDailyChallengeDate = Date()
        addXP(50)
    }
    
    func isLevelCompleted(_ levelId: Int) -> Bool {
        completedLevels.contains(levelId)
    }
}
