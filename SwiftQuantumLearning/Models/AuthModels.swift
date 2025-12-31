//
//  AuthModels.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import Foundation

// MARK: - Sign Up Request
struct SignUpRequest: Codable {
    let email: String
    let username: String
    let password: String
}

// MARK: - Login Request
struct LoginRequest: Codable {
    let email: String
    let password: String
}

// MARK: - Auth Response
struct AuthResponse: Codable {
    let access_token: String
    let token_type: String?
    let user_id: Int?
    let username: String?
    let email: String?
    let expires_in: Int?
    
    enum CodingKeys: String, CodingKey {
        case access_token
        case token_type
        case user_id
        case username
        case email
        case expires_in
    }
}

// MARK: - User Response
struct UserResponse: Codable {
    let id: Int
    let email: String
    let username: String
    let subscription_type: String
    let total_xp: Int
    let current_level: Int
    let current_streak: Int
    let longest_streak: Int
    let lessons_completed: Int
    let created_at: String
}

// MARK: - User Stats Response
struct UserStatsResponse: Codable {
    let total_xp: Int
    let current_level: Int
    let current_streak: Int
    let longest_streak: Int
    let levels_completed: Int
    let lessons_completed: Int
    let total_study_time_minutes: Int
    let xp_until_next_level: Int
    let level_progress: Double
}

// MARK: - Learning Levels Response
struct LevelListResponse: Codable {
    let id: Int
    let number: Int
    let name: String
    let description: String
    let track: String
    let difficulty: String
    let estimated_duration_minutes: Int
    let base_xp: Int
    let lessons: [String]
}

// MARK: - Achievement Response
struct AchievementResponse: Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let xp_reward: Int
    let rarity: String
    let category: String
    let is_unlocked: Bool
}

// MARK: - Achievements List Response
struct AchievementsListResponse: Codable {
    let total: Int
    let unlocked: Int
    let achievements: [AchievementResponse]
}

// MARK: - Complete Level Request
struct CompleteLevelRequest: Codable {
    let quiz_score: Double?
    
    enum CodingKeys: String, CodingKey {
        case quiz_score
    }
}

// MARK: - Complete Level Response
struct CompleteLevelResponse: Codable {
    let xp_earned: Int
    let total_xp: Int
    let section_completed: Bool
    let level_completed: Bool
    let streak: Int
}
