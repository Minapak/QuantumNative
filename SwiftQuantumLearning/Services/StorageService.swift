//
//  StorageService.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import Foundation
import Combine

class StorageService {
    
    // MARK: - Singleton
    static let shared = StorageService()
    
    // MARK: - Storage Keys - private enum을 public으로 변경
    enum StorageKey: String, CaseIterable {
        case userProgress = "SwiftQuantum_UserProgress"
        case achievements = "SwiftQuantum_Achievements"
        case settings = "SwiftQuantum_Settings"
        case dailyGoals = "SwiftQuantum_DailyGoals"
        case learningHistory = "SwiftQuantum_LearningHistory"
    }
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // MARK: - Initialization
    private init() {
        setupEncoder()
    }
    
    private func setupEncoder() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - User Progress
    
    func saveUserProgress(_ progress: UserProgress) {
        do {
            let data = try encoder.encode(progress)
            userDefaults.set(data, forKey: StorageKey.userProgress.rawValue)
        } catch {
            print("Failed to save user progress: \(error)")
        }
    }
    
    func loadUserProgress() -> UserProgress? {
        guard let data = userDefaults.data(forKey: StorageKey.userProgress.rawValue) else {
            return nil
        }
        
        do {
            return try decoder.decode(UserProgress.self, from: data)
        } catch {
            print("Failed to load user progress: \(error)")
            return nil
        }
    }
    
    // MARK: - Achievements
    
    func saveAchievements(_ achievements: [String: Date]) {
        do {
            let data = try encoder.encode(achievements)
            userDefaults.set(data, forKey: StorageKey.achievements.rawValue)
        } catch {
            print("Failed to save achievements: \(error)")
        }
    }
    
    func loadAchievements() -> [String: Date]? {
        guard let data = userDefaults.data(forKey: StorageKey.achievements.rawValue) else {
            return nil
        }
        
        do {
            return try decoder.decode([String: Date].self, from: data)
        } catch {
            print("Failed to load achievements: \(error)")
            return nil
        }
    }
    
    // MARK: - Settings
    
    func saveSettings(_ settings: AppSettings) {
        do {
            let data = try encoder.encode(settings)
            userDefaults.set(data, forKey: StorageKey.settings.rawValue)
        } catch {
            print("Failed to save settings: \(error)")
        }
    }
    
    func loadSettings() -> AppSettings? {
        guard let data = userDefaults.data(forKey: StorageKey.settings.rawValue) else {
            return nil
        }
        
        do {
            return try decoder.decode(AppSettings.self, from: data)
        } catch {
            print("Failed to load settings: \(error)")
            return nil
        }
    }
    
    // MARK: - Daily Goals
    
    func saveDailyGoals(_ goals: DailyGoals) {
        do {
            let data = try encoder.encode(goals)
            userDefaults.set(data, forKey: StorageKey.dailyGoals.rawValue)
        } catch {
            print("Failed to save daily goals: \(error)")
        }
    }
    
    func loadDailyGoals() -> DailyGoals? {
        guard let data = userDefaults.data(forKey: StorageKey.dailyGoals.rawValue) else {
            return nil
        }
        
        do {
            return try decoder.decode(DailyGoals.self, from: data)
        } catch {
            print("Failed to load daily goals: \(error)")
            return nil
        }
    }
    
    // MARK: - Learning History
    
    func saveLearningHistory(_ history: [LearningSession]) {
        do {
            let data = try encoder.encode(history)
            userDefaults.set(data, forKey: StorageKey.learningHistory.rawValue)
        } catch {
            print("Failed to save learning history: \(error)")
        }
    }
    
    func loadLearningHistory() -> [LearningSession]? {
        guard let data = userDefaults.data(forKey: StorageKey.learningHistory.rawValue) else {
            return nil
        }
        
        do {
            return try decoder.decode([LearningSession].self, from: data)
        } catch {
            print("Failed to load learning history: \(error)")
            return nil
        }
    }
    
    // MARK: - Clear Data
    
    func clearAllData() {
        StorageKey.allCases.forEach { key in
            userDefaults.removeObject(forKey: key.rawValue)
        }
    }
    
    func clearUserProgress() {
        userDefaults.removeObject(forKey: StorageKey.userProgress.rawValue)
    }
}

// MARK: - Supporting Models

struct AppSettings: Codable {
    var notificationsEnabled: Bool = true
    var dailyReminderTime: Date?
    var soundEnabled: Bool = true
    var hapticEnabled: Bool = true
    var theme: String = "dark"
}

struct LearningSession: Codable {
    let date: Date
    let levelId: Int
    let duration: Int
    let xpEarned: Int
    let completed: Bool
}
