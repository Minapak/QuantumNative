//
//  Achievement.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//
//  MARK: - Data Model: Achievement
//  Represents achievements/badges that users can unlock.
//  Provides gamification elements to encourage learning.
//

import SwiftUI

// MARK: - Achievement Model
/// Represents an achievement that users can unlock
struct Achievement: Identifiable, Codable, Equatable {
    
    // MARK: - Properties
    
    /// Unique identifier for the achievement
    let id: String
    
    /// Display title
    let title: String
    
    /// Description of how to unlock
    let description: String
    
    /// Emoji icon for the achievement
    let emoji: String
    
    /// SF Symbol name for fallback icon
    let iconName: String
    
    /// XP reward when unlocked
    let xpReward: Int
    
    /// Achievement category
    let category: Category
    
    /// Rarity level
    let rarity: Rarity
    
    // MARK: - User-specific (set at runtime)
    
    /// Date when unlocked (nil if not yet unlocked)
    var unlockedDate: Date?
    
    // MARK: - Computed Properties
    
    /// Whether this achievement is unlocked
    var isUnlocked: Bool {
        unlockedDate != nil
    }
    
    /// Formatted unlock date
    var unlockDateText: String? {
        guard let date = unlockedDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Achievement Category
/// Categories for organizing achievements
enum Category: String, Codable, CaseIterable {
    case progress = "progress"      // Level completion
    case streak = "streak"          // Consistency
    case xp = "xp"                  // XP milestones
    case time = "time"              // Study time
    case mastery = "mastery"        // Skill mastery
    case special = "special"        // Special achievements
    
    /// Display name
    var displayName: String {
        switch self {
        case .progress: return "Progress"
        case .streak: return "Streaks"
        case .xp: return "Experience"
        case .time: return "Dedication"
        case .mastery: return "Mastery"
        case .special: return "Special"
        }
    }
    
    /// Icon for category
    var iconName: String {
        switch self {
        case .progress: return "arrow.up.forward.circle"
        case .streak: return "flame"
        case .xp: return "star.circle"
        case .time: return "clock"
        case .mastery: return "crown"
        case .special: return "sparkles"
        }
    }
    
    /// Color for category
    var color: Color {
        switch self {
        case .progress: return .quantumCyan
        case .streak: return .orange
        case .xp: return .yellow
        case .time: return .quantumPurple
        case .mastery: return .quantumOrange
        case .special: return .pink
        }
    }
}

// MARK: - Achievement Rarity
/// Rarity levels for achievements
enum Rarity: String, Codable, CaseIterable {
    case common = "common"
    case uncommon = "uncommon"
    case rare = "rare"
    case epic = "epic"
    case legendary = "legendary"
    
    /// Display name
    var displayName: String {
        rawValue.capitalized
    }
    
    /// Color for rarity
    var color: Color {
        switch self {
        case .common: return .gray
        case .uncommon: return .green
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
    
    /// Gradient for rarity
    var gradient: LinearGradient {
        switch self {
        case .common:
            return LinearGradient(colors: [.gray, .gray.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .uncommon:
            return LinearGradient(colors: [.green, .green.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .rare:
            return LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .epic:
            return LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .legendary:
            return LinearGradient(colors: [.orange, .yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

// MARK: - Achievement Extensions
extension Achievement {
    
    /// Display view for the achievement icon
    @ViewBuilder
    var iconView: some View {
        ZStack {
            // Background circle with rarity gradient
            Circle()
                .fill(rarity.gradient)
                .frame(width: 60, height: 60)
            
            // Emoji icon
            Text(emoji)
                .font(.system(size: 28))
        }
        .opacity(isUnlocked ? 1.0 : 0.4)
    }
    
    /// Compact icon for lists
    @ViewBuilder
    var compactIconView: some View {
        ZStack {
            Circle()
                .fill(isUnlocked ? rarity.color.opacity(0.2) : Color.gray.opacity(0.1))
                .frame(width: 44, height: 44)
            
            if isUnlocked {
                Text(emoji)
                    .font(.system(size: 22))
            } else {
                Image(systemName: "lock.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.textTertiary)
            }
        }
    }
}

// MARK: - Sample Achievements
extension Achievement {
    
    /// All available achievements
    static let allAchievements: [Achievement] = [
        
        // MARK: Progress Achievements
        Achievement(
            id: "first_lesson",
            title: "First Steps",
            description: "Complete your first lesson",
            emoji: "🚀",
            iconName: "star.fill",
            xpReward: 25,
            category: .progress,
            rarity: .common
        ),
        
        Achievement(
            id: "quantum_novice",
            title: "Quantum Novice",
            description: "Complete all beginner levels",
            emoji: "🎓",
            iconName: "graduationcap.fill",
            xpReward: 100,
            category: .progress,
            rarity: .uncommon
        ),
        
        Achievement(
            id: "quantum_adept",
            title: "Quantum Adept",
            description: "Complete all intermediate levels",
            emoji: "⚡",
            iconName: "bolt.fill",
            xpReward: 150,
            category: .progress,
            rarity: .rare
        ),
        
        Achievement(
            id: "quantum_master",
            title: "Quantum Master",
            description: "Complete all levels",
            emoji: "👑",
            iconName: "crown.fill",
            xpReward: 500,
            category: .mastery,
            rarity: .legendary
        ),
        
        // MARK: Streak Achievements
        Achievement(
            id: "week_warrior",
            title: "Week Warrior",
            description: "Maintain a 7-day streak",
            emoji: "🔥",
            iconName: "flame.fill",
            xpReward: 50,
            category: .streak,
            rarity: .uncommon
        ),
        
        Achievement(
            id: "month_master",
            title: "Month Master",
            description: "Maintain a 30-day streak",
            emoji: "🌟",
            iconName: "star.circle.fill",
            xpReward: 200,
            category: .streak,
            rarity: .epic
        ),
        
        Achievement(
            id: "century_scholar",
            title: "Century Scholar",
            description: "Maintain a 100-day streak",
            emoji: "💎",
            iconName: "diamond.fill",
            xpReward: 1000,
            category: .streak,
            rarity: .legendary
        ),
        
        // MARK: XP Achievements
        Achievement(
            id: "xp_500",
            title: "Rising Star",
            description: "Earn 500 XP",
            emoji: "⭐",
            iconName: "star.fill",
            xpReward: 25,
            category: .xp,
            rarity: .common
        ),
        
        Achievement(
            id: "xp_1000",
            title: "Shining Bright",
            description: "Earn 1,000 XP",
            emoji: "🌟",
            iconName: "star.circle.fill",
            xpReward: 50,
            category: .xp,
            rarity: .uncommon
        ),
        
        Achievement(
            id: "xp_2000",
            title: "Supernova",
            description: "Earn 2,000 XP",
            emoji: "💫",
            iconName: "sparkles",
            xpReward: 100,
            category: .xp,
            rarity: .rare
        ),
        
        Achievement(
            id: "xp_5000",
            title: "Quantum Legend",
            description: "Earn 5,000 XP",
            emoji: "🏆",
            iconName: "trophy.fill",
            xpReward: 250,
            category: .xp,
            rarity: .epic
        ),
        
        // MARK: Time Achievements
        Achievement(
            id: "hour_scholar",
            title: "Hour Scholar",
            description: "Study for 1 hour total",
            emoji: "⏱️",
            iconName: "clock.fill",
            xpReward: 25,
            category: .time,
            rarity: .common
        ),
        
        Achievement(
            id: "dedicated_learner",
            title: "Dedicated Learner",
            description: "Study for 5 hours total",
            emoji: "📚",
            iconName: "book.fill",
            xpReward: 75,
            category: .time,
            rarity: .uncommon
        ),
        
        Achievement(
            id: "quantum_devotee",
            title: "Quantum Devotee",
            description: "Study for 20 hours total",
            emoji: "🧠",
            iconName: "brain.head.profile",
            xpReward: 200,
            category: .time,
            rarity: .rare
        ),
        
        // MARK: Mastery Achievements
        Achievement(
            id: "superposition_master",
            title: "Superposition Master",
            description: "Complete Level 2 with 100% score",
            emoji: "🌊",
            iconName: "waveform",
            xpReward: 75,
            category: .mastery,
            rarity: .rare
        ),
        
        Achievement(
            id: "algorithm_expert",
            title: "Algorithm Expert",
            description: "Master Deutsch-Jozsa algorithm",
            emoji: "🧮",
            iconName: "function",
            xpReward: 150,
            category: .mastery,
            rarity: .epic
        ),
        
        // MARK: Special Achievements
        Achievement(
            id: "early_adopter",
            title: "Early Adopter",
            description: "Start learning in the first week",
            emoji: "🌱",
            iconName: "leaf.fill",
            xpReward: 100,
            category: .special,
            rarity: .rare
        ),
        
        Achievement(
            id: "daily_challenger",
            title: "Daily Challenger",
            description: "Complete 10 daily challenges",
            emoji: "🎯",
            iconName: "target",
            xpReward: 100,
            category: .special,
            rarity: .uncommon
        )
    ]
    
    /// Get achievement by ID
    static func achievement(withId id: String) -> Achievement? {
        allAchievements.first { $0.id == id }
    }
    
    /// Get achievements by category
    static func achievements(for category: Category) -> [Achievement] {
        allAchievements.filter { $0.category == category }
    }
    
    /// Get achievements by rarity
    static func achievements(withRarity rarity: Rarity) -> [Achievement] {
        allAchievements.filter { $0.rarity == rarity }
    }
}

// MARK: - Preview Provider
#Preview("Achievements Grid") {
    ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 16) {
            ForEach(Achievement.allAchievements.prefix(12)) { achievement in
                VStack(spacing: 8) {
                    achievement.iconView
                    
                    Text(achievement.title)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    Text("+\(achievement.xpReward) XP")
                        .font(.caption2)
                        .foregroundColor(.textSecondary)
                    
                    Text(achievement.rarity.displayName)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(achievement.rarity.color)
                }
                .frame(width: 100)
            }
        }
        .padding()
    }
    .background(Color.bgDark)
}

#Preview("Achievement Card") {
    let achievement = Achievement.allAchievements[0]
    
    HStack(spacing: 16) {
        achievement.iconView
        
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text("+\(achievement.xpReward) XP")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.quantumCyan)
            }
            
            Text(achievement.description)
                .font(.caption)
                .foregroundColor(.textSecondary)
            
            HStack {
                Text(achievement.category.displayName)
                    .font(.caption2)
                    .foregroundColor(achievement.category.color)
                
                Text("•")
                    .foregroundColor(.textTertiary)
                
                Text(achievement.rarity.displayName)
                    .font(.caption2)
                    .foregroundColor(achievement.rarity.color)
            }
        }
    }
    .padding()
    .background(Color.bgCard)
    .cornerRadius(12)
    .padding()
    .background(Color.bgDark)
}
