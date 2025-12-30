//
//  UserProgress.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//
//  MARK: - Data Model: User Progress
//  Tracks all user progress including XP, streaks, completed levels,
//  study time, and achievements. Persisted to UserDefaults.
//

import SwiftUI

// MARK: - User Progress Model
/// Observable class that tracks all user progress
/// Uses @Observable macro for SwiftUI integration (iOS 17+)
/// Falls back to ObservableObject for older iOS versions
@MainActor
class UserProgress: ObservableObject {
    
    // MARK: - Published Properties
    
    /// User's display name
    @Published var userName: String = "Learner"
    
    /// Total experience points earned
    @Published var totalXP: Int = 0
    
    /// Current consecutive day streak
    @Published var currentStreak: Int = 0
    
    /// Longest streak ever achieved
    @Published var longestStreak: Int = 0
    
    /// Last date the user studied
    @Published var lastStudyDate: Date?
    
    /// Set of completed level IDs
    @Published var completedLevelIds: Set<Int> = []
    
    /// Total study time in minutes
    @Published var totalStudyMinutes: Int = 0
    
    /// Set of unlocked achievement IDs
    @Published var unlockedAchievementIds: Set<String> = []
    
    /// Currently active level ID (if any)
    @Published var currentLevelId: Int?
    
    /// Progress percentage for current level
    @Published var currentLevelProgress: Int = 0
    
    /// Whether daily challenge is completed today
    @Published var dailyChallengeCompletedToday: Bool = false
    
    /// Date of last daily challenge completion
    @Published var lastDailyChallengeDate: Date?
    
    // MARK: - Computed Properties
    
    /// User's level based on XP (every 500 XP = 1 level)
    var userLevel: Int {
        (totalXP / 500) + 1
    }
    
    /// XP needed for next level
    var xpForNextLevel: Int {
        userLevel * 500
    }
    
    /// XP at current level start
    var xpAtCurrentLevelStart: Int {
        (userLevel - 1) * 500
    }
    
    /// XP remaining until next level
    var xpUntilNextLevel: Int {
        xpForNextLevel - totalXP
    }
    
    /// Progress within current level (0.0 - 1.0)
    var levelProgress: Double {
        let currentLevelXP = totalXP - xpAtCurrentLevelStart
        let xpInLevel = xpForNextLevel - xpAtCurrentLevelStart
        return Double(currentLevelXP) / Double(xpInLevel)
    }
    
    /// Level progress as percentage string
    var levelProgressText: String {
        "\(Int(levelProgress * 100))%"
    }
    
    /// Number of completed levels
    var completedLevelsCount: Int {
        completedLevelIds.count
    }
    
    /// Total available levels
    var totalLevelsCount: Int {
        LearningLevel.allLevels.count
    }
    
    /// Formatted study time
    var studyTimeText: String {
        if totalStudyMinutes < 60 {
            return "\(totalStudyMinutes) min"
        } else {
            let hours = totalStudyMinutes / 60
            let mins = totalStudyMinutes % 60
            return mins > 0 ? "\(hours)h \(mins)m" : "\(hours) hours"
        }
    }
    
    /// Whether the user has studied today
    var hasStudiedToday: Bool {
        guard let lastDate = lastStudyDate else { return false }
        return Calendar.current.isDateInToday(lastDate)
    }
    
    /// Streak emoji based on current streak
    var streakEmoji: String {
        switch currentStreak {
        case 0:
            return "💤"
        case 1...6:
            return "🔥"
        case 7...29:
            return "🔥🔥"
        case 30...99:
            return "🔥🔥🔥"
        default:
            return "⚡"
        }
    }
    
    // MARK: - Initialization
    
    init() {
        load()
    }
    
    // MARK: - XP Methods
    
    /// Add XP and check for level up
    /// - Parameter amount: Amount of XP to add
    /// - Returns: True if user leveled up
    @discardableResult
    func addXP(_ amount: Int) -> Bool {
        let previousLevel = userLevel
        totalXP += amount
        
        updateStudyDate()
        checkAchievements()
        save()
        
        return userLevel > previousLevel
    }
    
    // MARK: - Level Completion
    
    /// Mark a level as completed
    /// - Parameter levelId: ID of the completed level
    func completeLevel(_ levelId: Int) {
        guard !completedLevelIds.contains(levelId) else { return }
        
        completedLevelIds.insert(levelId)
        addXP(100) // Bonus XP for completing a level
        
        // Update current level to next one
        if let nextLevel = LearningLevel.allLevels.first(where: { !completedLevelIds.contains($0.id) }) {
            currentLevelId = nextLevel.id
            currentLevelProgress = 0
        } else {
            currentLevelId = nil
        }
        
        updateStreak()
        checkAchievements()
        save()
    }
    
    /// Update progress for current level
    /// - Parameter progress: Progress percentage (0-100)
    func updateLevelProgress(_ progress: Int) {
        currentLevelProgress = min(100, max(0, progress))
        
        if currentLevelProgress >= 100 {
            if let levelId = currentLevelId {
                completeLevel(levelId)
            }
        }
        
        save()
    }
    
    /// Start a new level
    /// - Parameter levelId: ID of the level to start
    func startLevel(_ levelId: Int) {
        currentLevelId = levelId
        currentLevelProgress = 0
        updateStudyDate()
        save()
    }
    
    /// Check if a level is completed
    /// - Parameter levelId: ID of the level to check
    /// - Returns: True if level is completed
    func isLevelCompleted(_ levelId: Int) -> Bool {
        completedLevelIds.contains(levelId)
    }
    
    /// Check if a level is unlocked
    /// - Parameter level: The level to check
    /// - Returns: True if level is unlocked
    func isLevelUnlocked(_ level: LearningLevel) -> Bool {
        // First level is always unlocked
        if level.number == 1 { return true }
        
        // Check if previous level in same track is completed
        let previousLevels = LearningLevel.allLevels.filter {
            $0.track == level.track && $0.number < level.number
        }
        
        return previousLevels.allSatisfy { completedLevelIds.contains($0.id) }
    }
    
    // MARK: - Streak Methods
    
    /// Update study date and streak
    private func updateStudyDate() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastDate = lastStudyDate {
            let lastDay = Calendar.current.startOfDay(for: lastDate)
            let daysDifference = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            if daysDifference == 1 {
                // Studied yesterday, increase streak
                currentStreak += 1
            } else if daysDifference > 1 {
                // Missed days, reset streak
                currentStreak = 1
            }
            // daysDifference == 0 means already studied today, keep streak
        } else {
            // First time studying
            currentStreak = 1
        }
        
        longestStreak = max(longestStreak, currentStreak)
        lastStudyDate = Date()
    }
    
    /// Update streak (called daily)
    private func updateStreak() {
        updateStudyDate()
        save()
    }
    
    // MARK: - Daily Challenge
    
    /// Complete daily challenge
    func completeDailyChallenge() {
        guard !dailyChallengeCompletedToday else { return }
        
        dailyChallengeCompletedToday = true
        lastDailyChallengeDate = Date()
        addXP(50) // Bonus XP for daily challenge
        
        checkAchievements()
        save()
    }
    
    /// Check and reset daily challenge status
    func checkDailyChallengeReset() {
        guard let lastDate = lastDailyChallengeDate else { return }
        
        if !Calendar.current.isDateInToday(lastDate) {
            dailyChallengeCompletedToday = false
            save()
        }
    }
    
    // MARK: - Study Time
    
    /// Add study time
    /// - Parameter minutes: Minutes to add
    func addStudyTime(_ minutes: Int) {
        totalStudyMinutes += minutes
        updateStudyDate()
        save()
    }
    
    // MARK: - Achievements
    
    /// Check and unlock achievements
    private func checkAchievements() {
        // First lesson
        if completedLevelsCount >= 1 {
            unlockAchievement("first_lesson")
        }
        
        // Week warrior (7-day streak)
        if currentStreak >= 7 {
            unlockAchievement("week_warrior")
        }
        
        // Quantum novice (complete first 3 levels)
        if completedLevelsCount >= 3 {
            unlockAchievement("quantum_novice")
        }
        
        // XP milestones
        if totalXP >= 500 {
            unlockAchievement("xp_500")
        }
        if totalXP >= 1000 {
            unlockAchievement("xp_1000")
        }
        if totalXP >= 2000 {
            unlockAchievement("xp_2000")
        }
        
        // Time milestones
        if totalStudyMinutes >= 60 {
            unlockAchievement("hour_scholar")
        }
        
        // All levels completed
        if completedLevelsCount == totalLevelsCount {
            unlockAchievement("quantum_master")
        }
    }
    
    /// Unlock an achievement
    /// - Parameter achievementId: ID of achievement to unlock
    func unlockAchievement(_ achievementId: String) {
        guard !unlockedAchievementIds.contains(achievementId) else { return }
        unlockedAchievementIds.insert(achievementId)
        save()
    }
    
    /// Check if achievement is unlocked
    /// - Parameter achievementId: ID of achievement to check
    /// - Returns: True if unlocked
    func isAchievementUnlocked(_ achievementId: String) -> Bool {
        unlockedAchievementIds.contains(achievementId)
    }
    
    // MARK: - Persistence
    
    /// UserDefaults key for saving
    private static let userDefaultsKey = "SwiftQuantum_UserProgress"
    
    /// Save progress to UserDefaults
    func save() {
        let data = ProgressData(
            userName: userName,
            totalXP: totalXP,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            lastStudyDate: lastStudyDate,
            completedLevelIds: Array(completedLevelIds),
            totalStudyMinutes: totalStudyMinutes,
            unlockedAchievementIds: Array(unlockedAchievementIds),
            currentLevelId: currentLevelId,
            currentLevelProgress: currentLevelProgress,
            dailyChallengeCompletedToday: dailyChallengeCompletedToday,
            lastDailyChallengeDate: lastDailyChallengeDate
        )
        
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: Self.userDefaultsKey)
        }
    }
    
    /// Load progress from UserDefaults
    func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.userDefaultsKey),
              let decoded = try? JSONDecoder().decode(ProgressData.self, from: data) else {
            return
        }
        
        userName = decoded.userName
        totalXP = decoded.totalXP
        currentStreak = decoded.currentStreak
        longestStreak = decoded.longestStreak
        lastStudyDate = decoded.lastStudyDate
        completedLevelIds = Set(decoded.completedLevelIds)
        totalStudyMinutes = decoded.totalStudyMinutes
        unlockedAchievementIds = Set(decoded.unlockedAchievementIds)
        currentLevelId = decoded.currentLevelId
        currentLevelProgress = decoded.currentLevelProgress
        dailyChallengeCompletedToday = decoded.dailyChallengeCompletedToday
        lastDailyChallengeDate = decoded.lastDailyChallengeDate
        
        // Check if daily challenge needs reset
        checkDailyChallengeReset()
    }
    
    /// Reset all progress (for testing)
    func reset() {
        userName = "Learner"
        totalXP = 0
        currentStreak = 0
        longestStreak = 0
        lastStudyDate = nil
        completedLevelIds = []
        totalStudyMinutes = 0
        unlockedAchievementIds = []
        currentLevelId = 1
        currentLevelProgress = 0
        dailyChallengeCompletedToday = false
        lastDailyChallengeDate = nil
        save()
    }
}

// MARK: - Codable Data Structure
/// Structure for encoding/decoding progress data
private struct ProgressData: Codable {
    let userName: String
    let totalXP: Int
    let currentStreak: Int
    let longestStreak: Int
    let lastStudyDate: Date?
    let completedLevelIds: [Int]
    let totalStudyMinutes: Int
    let unlockedAchievementIds: [String]
    let currentLevelId: Int?
    let currentLevelProgress: Int
    let dailyChallengeCompletedToday: Bool
    let lastDailyChallengeDate: Date?
}

// MARK: - Preview Helper
extension UserProgress {
    /// Sample progress for previews
    static var sample: UserProgress {
        let progress = UserProgress()
        progress.userName = "Alex"
        progress.totalXP = 750
        progress.currentStreak = 5
        progress.longestStreak = 12
        progress.lastStudyDate = Date()
        progress.completedLevelIds = [1, 2]
        progress.totalStudyMinutes = 45
        progress.unlockedAchievementIds = ["first_lesson", "week_warrior"]
        progress.currentLevelId = 3
        progress.currentLevelProgress = 35
        return progress
    }
}

// MARK: - Preview Provider
#Preview("User Progress Card") {
    let progress = UserProgress.sample
    
    VStack(spacing: 16) {
        // XP Card
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Level \(progress.userLevel)")
                    .font(.headline)
                    .foregroundColor(.quantumCyan)
                
                Text("\(progress.totalXP) XP")
                    .font(.title2.bold())
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Next Level")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                Text("\(progress.xpUntilNextLevel) XP")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
            }
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
        
        // Stats Row
        HStack(spacing: 16) {
            StatItem(icon: "flame.fill", value: "\(progress.currentStreak)", label: "Streak", color: .orange)
            StatItem(icon: "checkmark.circle.fill", value: "\(progress.completedLevelsCount)", label: "Levels", color: .completed)
            StatItem(icon: "clock.fill", value: progress.studyTimeText, label: "Time", color: .quantumCyan)
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
    .padding()
    .background(Color.bgDark)
}

// Helper view for stats
struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}
