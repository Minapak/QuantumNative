//
//  ChallengesView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

struct ChallengesView: View {
    @State private var selectedChallenge: Challenge?
    
    struct Challenge: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let difficulty: String
        let xpReward: Int
        let icon: String
    }
    
    private let challenges = [
        Challenge(
            title: "Superposition Master",
            description: "Create specific quantum states",
            difficulty: "Beginner",
            xpReward: 50,
            icon: "waveform"
        ),
        Challenge(
            title: "Gate Sequencer",
            description: "Apply gates to achieve target state",
            difficulty: "Intermediate",
            xpReward: 100,
            icon: "square.grid.3x3"
        ),
        Challenge(
            title: "Entanglement Expert",
            description: "Create Bell states",
            difficulty: "Advanced",
            xpReward: 150,
            icon: "link"
        )
    ]
    
    var body: some View {
        ZStack {
            Color.bgDark.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(challenges) { challenge in
                        ChallengeCard(challenge: challenge) {
                            selectedChallenge = challenge
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Challenges")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.quantumOrange)
            }
            #else
            ToolbarItem(placement: .automatic) {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.quantumOrange)
            }
            #endif
        }
    }
}

struct ChallengeCard: View {
    let challenge: ChallengesView.Challenge
    let action: () -> Void
    
    var difficultyColor: Color {
        switch challenge.difficulty {
        case "Beginner": return .completed
        case "Intermediate": return .inProgress
        case "Advanced": return .locked
        default: return .textSecondary
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: challenge.icon)
                    .font(.title2)
                    .foregroundColor(difficultyColor)
                    .frame(width: 50, height: 50)
                    .background(difficultyColor.opacity(0.1))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.title)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    Text(challenge.description)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(challenge.xpReward) XP")
                        .font(.caption.bold())
                        .foregroundColor(.quantumCyan)
                    
                    Text(challenge.difficulty)
                        .font(.caption2)
                        .foregroundColor(difficultyColor)
                }
            }
            .padding(16)
            .background(Color.bgCard)
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}
