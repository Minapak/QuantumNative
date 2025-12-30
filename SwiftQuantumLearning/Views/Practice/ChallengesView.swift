//
//  ChallengesView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

// MARK: - Challenges View
struct ChallengesView: View {
    @State private var selectedChallenge: Challenge?
    
    let challenges = [
        Challenge(
            id: "create_bell",
            title: "Create Bell State",
            difficulty: .intermediate,
            description: "Create a maximally entangled Bell state",
            xpReward: 50
        ),
        Challenge(
            id: "teleportation",
            title: "Quantum Teleportation",
            difficulty: .advanced,
            description: "Implement quantum teleportation protocol",
            xpReward: 100
        ),
        Challenge(
            id: "grover",
            title: "Grover's Search",
            difficulty: .advanced,
            description: "Implement Grover's algorithm",
            xpReward: 150
        )
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(challenges) { challenge in
                        ChallengeCard(challenge: challenge) {
                            selectedChallenge = challenge
                        }
                    }
                }
                .padding()
            }
            .background(Color.bgDark)
            .navigationTitle("Challenges")
            .sheet(item: $selectedChallenge) { challenge in
                ChallengeDetailView(challenge: challenge)
            }
        }
    }
}

struct Challenge: Identifiable {
    let id: String
    let title: String
    let difficulty: PracticeItem.Difficulty
    let description: String
    let xpReward: Int
}

struct ChallengeCard: View {
    let challenge: Challenge
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(challenge.title)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    Text(challenge.description)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    HStack {
                        Label(challenge.difficulty.rawValue, systemImage: "star.fill")
                            .font(.caption)
                            .foregroundColor(challenge.difficulty.color)
                        
                        Spacer()
                        
                        Text("+\(challenge.xpReward) XP")
                            .font(.caption.bold())
                            .foregroundColor(.quantumYellow)
                    }
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.textTertiary)
            }
            .padding()
            .background(Color.bgCard)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct ChallengeDetailView: View {
    let challenge: Challenge
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgDark.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text(challenge.title)
                        .font(.title2.bold())
                        .foregroundColor(.textPrimary)
                    
                    Text(challenge.description)
                        .foregroundColor(.textSecondary)
                    
                    Text("Challenge implementation coming soon")
                        .foregroundColor(.textTertiary)
                }
                .padding()
            }
            .navigationTitle("Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundColor(.quantumCyan)
                }
            }
        }
    }
}