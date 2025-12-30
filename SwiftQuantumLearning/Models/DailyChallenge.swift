//
//  DailyChallenge.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//
//  MARK: - Data Model: Daily Challenge
//  Represents daily challenges that rotate each day.
//  Provides engagement and consistent learning motivation.
//

import SwiftUI

// MARK: - Daily Challenge Model
/// Represents a daily challenge for the user
struct DailyChallenge: Identifiable, Codable, Equatable {
    
    // MARK: - Properties
    
    /// Unique identifier
    let id: String
    
    /// Challenge title
    let title: String
    
    /// Description of what to do
    let description: String
    
    /// Detailed instructions
    let instructions: String
    
    /// XP reward for completion
    let xpReward: Int
    
    /// Difficulty level
    let difficulty: ChallengeDifficulty
    
    /// Type of challenge
    let type: ChallengeType
    
    /// Emoji icon
    let emoji: String
    
    /// Target value (e.g., number of measurements)
    let targetValue: Int?
    
    /// Related level ID (if any)
    let relatedLevelId: Int?
}

// MARK: - Challenge Difficulty
/// Difficulty levels for challenges
enum ChallengeDifficulty: String, Codable, CaseIterable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
    
    /// Display name
    var displayName: String {
        rawValue.capitalized
    }
    
    /// Color for difficulty
    var color: Color {
        switch self {
        case .easy: return .completed
        case .medium: return .inProgress
        case .hard: return .quantumOrange
        }
    }
    
    /// XP multiplier
    var xpMultiplier: Double {
        switch self {
        case .easy: return 1.0
        case .medium: return 1.5
        case .hard: return 2.0
        }
    }
}

// MARK: - Challenge Type
/// Types of daily challenges
enum ChallengeType: String, Codable, CaseIterable {
    case createState = "create_state"       // Create a specific quantum state
    case applyGates = "apply_gates"         // Apply gates to achieve a state
    case measure = "measure"                // Perform measurements
    case quiz = "quiz"                      // Answer questions
    case explore = "explore"                // Explore a concept
    case practice = "practice"              // Complete a practice session
    
    /// Display name
    var displayName: String {
        switch self {
        case .createState: return "Create State"
        case .applyGates: return "Apply Gates"
        case .measure: return "Measure"
        case .quiz: return "Quiz"
        case .explore: return "Explore"
        case .practice: return "Practice"
        }
    }
    
    /// Icon for type
    var iconName: String {
        switch self {
        case .createState: return "waveform"
        case .applyGates: return "square.grid.3x3"
        case .measure: return "gauge"
        case .quiz: return "questionmark.circle"
        case .explore: return "binoculars"
        case .practice: return "figure.run"
        }
    }
}

// MARK: - Daily Challenge Extensions
extension DailyChallenge {
    
    /// Icon view for the challenge
    @ViewBuilder
    var iconView: some View {
        ZStack {
            Circle()
                .fill(difficulty.color.opacity(0.2))
                .frame(width: 48, height: 48)
            
            Text(emoji)
                .font(.system(size: 24))
        }
    }
    
    /// Compact badge showing XP reward
    @ViewBuilder
    var xpBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.system(size: 10))
            Text("+\(xpReward)")
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .foregroundColor(.quantumOrange)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.quantumOrange.opacity(0.2))
        .cornerRadius(8)
    }
}

// MARK: - Sample Challenges
extension DailyChallenge {
    
    /// All available daily challenges
    static let allChallenges: [DailyChallenge] = [
        
        // MARK: Easy Challenges
        DailyChallenge(
            id: "create_plus_state",
            title: "Create |+⟩ State",
            description: "Create an equal superposition state",
            instructions: "Apply the Hadamard gate to |0⟩ to create the |+⟩ state with equal probabilities.",
            xpReward: 25,
            difficulty: .easy,
            type: .createState,
            emoji: "➕",
            targetValue: nil,
            relatedLevelId: 2
        ),
        
        DailyChallenge(
            id: "measure_10_times",
            title: "Take 10 Measurements",
            description: "Measure a superposition state 10 times",
            instructions: "Create a superposition and observe how measurement results vary.",
            xpReward: 20,
            difficulty: .easy,
            type: .measure,
            emoji: "📊",
            targetValue: 10,
            relatedLevelId: 3
        ),
        
        DailyChallenge(
            id: "explore_bloch",
            title: "Explore Bloch Sphere",
            description: "Visualize 3 different states on the Bloch sphere",
            instructions: "Use the 3D visualizer to see how states map to the sphere.",
            xpReward: 25,
            difficulty: .easy,
            type: .explore,
            emoji: "🌐",
            targetValue: 3,
            relatedLevelId: 2
        ),
        
        // MARK: Medium Challenges
        DailyChallenge(
            id: "create_minus_state",
            title: "Create |−⟩ State",
            description: "Create the minus superposition state",
            instructions: "Start with |1⟩ and apply Hadamard, or use |0⟩ with H→Z→H.",
            xpReward: 35,
            difficulty: .medium,
            type: .createState,
            emoji: "➖",
            targetValue: nil,
            relatedLevelId: 2
        ),
        
        DailyChallenge(
            id: "gate_sequence",
            title: "Gate Sequence Master",
            description: "Apply 5 gates in sequence",
            instructions: "Build a circuit with 5 gates and execute it.",
            xpReward: 40,
            difficulty: .medium,
            type: .applyGates,
            emoji: "🔗",
            targetValue: 5,
            relatedLevelId: 4
        ),
        
        DailyChallenge(
            id: "measure_statistics",
            title: "Statistical Analysis",
            description: "Perform 100 measurements and analyze results",
            instructions: "Measure a superposition 100 times and verify the probability distribution.",
            xpReward: 40,
            difficulty: .medium,
            type: .measure,
            emoji: "📈",
            targetValue: 100,
            relatedLevelId: 3
        ),
        
        DailyChallenge(
            id: "interference_pattern",
            title: "Create Interference",
            description: "Demonstrate quantum interference",
            instructions: "Apply H→Z→H sequence to see destructive interference.",
            xpReward: 45,
            difficulty: .medium,
            type: .applyGates,
            emoji: "🌊",
            targetValue: nil,
            relatedLevelId: 6
        ),
        
        // MARK: Hard Challenges
        DailyChallenge(
            id: "custom_phase",
            title: "Custom Phase State",
            description: "Create a state with specific phase",
            instructions: "Use rotation gates to create a state with phase π/4.",
            xpReward: 50,
            difficulty: .hard,
            type: .createState,
            emoji: "🎯",
            targetValue: nil,
            relatedLevelId: 4
        ),
        
        DailyChallenge(
            id: "algorithm_challenge",
            title: "Algorithm Challenge",
            description: "Implement Deutsch-Jozsa for a balanced function",
            instructions: "Use the algorithm to determine if a function is balanced.",
            xpReward: 75,
            difficulty: .hard,
            type: .practice,
            emoji: "🧮",
            targetValue: nil,
            relatedLevelId: 7
        ),
        
        DailyChallenge(
            id: "random_number",
            title: "Quantum RNG",
            description: "Generate 10 truly random numbers",
            instructions: "Use quantum superposition to generate random numbers.",
            xpReward: 50,
            difficulty: .hard,
            type: .practice,
            emoji: "🎲",
            targetValue: 10,
            relatedLevelId: 8
        ),
        
        DailyChallenge(
            id: "perfect_statistics",
            title: "Perfect Statistician",
            description: "Achieve < 2% error in 1000 measurements",
            instructions: "Measure a |+⟩ state 1000 times and verify ~50/50 distribution.",
            xpReward: 60,
            difficulty: .hard,
            type: .measure,
            emoji: "🎯",
            targetValue: 1000,
            relatedLevelId: 3
        )
    ]
    
    /// Get today's challenge based on date
    static func todaysChallenge() -> DailyChallenge {
        // Use day of year to rotate through challenges
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = (dayOfYear - 1) % allChallenges.count
        return allChallenges[index]
    }
    
    /// Get challenges by difficulty
    static func challenges(for difficulty: ChallengeDifficulty) -> [DailyChallenge] {
        allChallenges.filter { $0.difficulty == difficulty }
    }
    
    /// Get challenges by type
    static func challenges(ofType type: ChallengeType) -> [DailyChallenge] {
        allChallenges.filter { $0.type == type }
    }
    
    /// Get a random challenge
    static func randomChallenge() -> DailyChallenge {
        allChallenges.randomElement() ?? allChallenges[0]
    }
}

// MARK: - Preview Provider
#Preview("Daily Challenge Card") {
    let challenge = DailyChallenge.todaysChallenge()
    
    VStack(spacing: 16) {
        // Full Challenge Card
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                challenge.iconView
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Challenge")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    Text(challenge.title)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                }
                
                Spacer()
                
                challenge.xpBadge
            }
            
            Text(challenge.description)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
            
            HStack(spacing: 12) {
                Label(challenge.difficulty.displayName, systemImage: "speedometer")
                    .font(.caption)
                    .foregroundColor(challenge.difficulty.color)
                
                Label(challenge.type.displayName, systemImage: challenge.type.iconName)
                    .font(.caption)
                    .foregroundColor(.textTertiary)
            }
            
            Button(action: {}) {
                HStack {
                    Text("Start Challenge")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.quantumCyan.opacity(0.2))
                .foregroundColor(.quantumCyan)
                .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.bgCard)
        .cornerRadius(12)
    }
    .padding()
    .background(Color.bgDark)
}

#Preview("Challenge List") {
    ScrollView {
        VStack(spacing: 12) {
            ForEach(DailyChallenge.allChallenges.prefix(5)) { challenge in
                HStack(spacing: 12) {
                    challenge.iconView
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(challenge.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                        
                        Text(challenge.description)
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    challenge.xpBadge
                }
                .padding(12)
                .background(Color.bgCard)
                .cornerRadius(8)
            }
        }
        .padding()
    }
    .background(Color.bgDark)
}
