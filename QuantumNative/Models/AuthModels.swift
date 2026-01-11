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
    let subscription_type: String?
    let total_xp: Int?
    let current_level: Int?
    let current_streak: Int?
    let longest_streak: Int?
    let lessons_completed: Int?
    let created_at: String?
    let is_active: Bool?
    let is_premium: Bool?
    let subscription_tier: String?
    let subscription_expires_at: String?

    // Convenience initializer for Admin/Mock users
    init(
        id: Int,
        email: String,
        username: String,
        is_active: Bool = true,
        is_premium: Bool = false,
        created_at: String? = nil,
        subscription_tier: String? = nil,
        subscription_expires_at: String? = nil
    ) {
        self.id = id
        self.email = email
        self.username = username
        self.subscription_type = subscription_tier
        self.total_xp = 0
        self.current_level = 1
        self.current_streak = 0
        self.longest_streak = 0
        self.lessons_completed = 0
        self.created_at = created_at
        self.is_active = is_active
        self.is_premium = is_premium
        self.subscription_tier = subscription_tier
        self.subscription_expires_at = subscription_expires_at
    }
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
