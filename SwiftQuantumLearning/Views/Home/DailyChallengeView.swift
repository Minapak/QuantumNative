//
//  DailyChallengeView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//
//  MARK: - Daily Challenge View
//  Displays the daily quantum challenge with countdown and rewards
//

import SwiftUI

// MARK: - Daily Challenge View
/// Shows today's daily challenge
struct DailyChallengeView: View {
    
    // MARK: - Properties
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @State private var showChallenge = false
    @State private var animateCard = false
    @State private var timeRemaining: String = ""
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            headerSection
            
            // Challenge card
            challengeCard
        }
        .onAppear {
            withAnimation(.spring()) {
                animateCard = true
            }
        }
        .onReceive(timer) { _ in
            updateTimeRemaining()
        }
    }
    
    // MARK: - Subviews
    
    /// Header section
    private var headerSection: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "star.circle.fill")
                    .foregroundColor(.quantumYellow)
                
                Text("Daily Challenge")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
            
            // Time remaining
            if !timeRemaining.isEmpty {
                Text(timeRemaining)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.bgDark.opacity(0.5))
                    .cornerRadius(12)
            }
        }
    }
    
    /// Challenge card
    private var challengeCard: some View {
        Button(action: { showChallenge = true }) {
            HStack(spacing: 16) {
                // Challenge icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.quantumYellow.opacity(0.3), Color.quantumOrange.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: progressViewModel.dailyChallenge.iconName)
                        .font(.title2)
                        .foregroundColor(.quantumYellow)
                        .scaleEffect(animateCard ? 1 : 0.5)
                        .rotationEffect(.degrees(animateCard ? 0 : -10))
                }
                
                // Challenge info
                VStack(alignment: .leading, spacing: 6) {
                    Text(progressViewModel.dailyChallenge.title)
                        .font(.subheadline.bold())
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                    
                    Text(progressViewModel.dailyChallenge.description)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                    
                    // Reward
                    HStack(spacing: 12) {
                        Label("+\(progressViewModel.dailyChallenge.xpReward) XP", systemImage: "star.fill")
                            .font(.caption.bold())
                            .foregroundColor(.quantumYellow)
                        
                        if progressViewModel.dailyChallenge.streakBonus > 0 {
                            Label("+\(progressViewModel.dailyChallenge.streakBonus) Streak", systemImage: "flame.fill")
                                .font(.caption.bold())
                                .foregroundColor(.quantumOrange)
                        }
                    }
                }
                
                Spacer()
                
                // Status indicator
                if progressViewModel.dailyChallenge.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.quantumGreen)
                } else {
                    Image(systemName: "chevron.right.circle")
                        .font(.title2)
                        .foregroundColor(.textTertiary)
                }
            }
            .padding()
            .background(
                Group {
                    if progressViewModel.dailyChallenge.isCompleted {
                        Color.quantumGreen.opacity(0.05)
                    } else {
                        LinearGradient(
                            colors: [
                                Color.quantumYellow.opacity(0.05),
                                Color.quantumOrange.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        progressViewModel.dailyChallenge.isCompleted ?
                        Color.quantumGreen.opacity(0.2) : Color.quantumYellow.opacity(0.2),
                        lineWidth: 1
                    )
            )
            .cornerRadius(16)
        }
        .disabled(progressViewModel.dailyChallenge.isCompleted)
        .opacity(progressViewModel.dailyChallenge.isCompleted ? 0.7 : 1)
        .sheet(isPresented: $showChallenge) {
            DailyChallengeDetailView(challenge: progressViewModel.dailyChallenge)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Update time remaining until next challenge
    private func updateTimeRemaining() {
        let calendar = Calendar.current
        let now = Date()
        
        // Calculate tomorrow's date at midnight
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
           let tomorrowMidnight = calendar.dateInterval(of: .day, for: tomorrow)?.start {
            
            let components = calendar.dateComponents([.hour, .minute, .second], from: now, to: tomorrowMidnight)
            
            if let hours = components.hour, let minutes = components.minute {
                timeRemaining = String(format: "%02d:%02d:%02d", hours, minutes, components.second ?? 0)
            }
        }
    }
}

// MARK: - Daily Challenge Detail View
/// Detailed view for daily challenge
struct DailyChallengeDetailView: View {
    let challenge: DailyChallenge
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @State private var showingQuiz = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.bgDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Challenge header
                        challengeHeader
                        
                        // Description
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Challenge Description")
                                .font(.headline)
                                .foregroundColor(.textPrimary)
                            
                            Text(challenge.fullDescription)
                                .font(.body)
                                .foregroundColor(.textSecondary)
                                .lineSpacing(4)
                        }
                        .padding()
                        .background(Color.bgCard)
                        .cornerRadius(12)
                        
                        // Requirements
                        requirementsSection
                        
                        // Rewards
                        rewardsSection
                        
                        // Start button
                        if !challenge.isCompleted {
                            startButton
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Daily Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundColor(.quantumCyan)
                }
            }
        }
    }
    
    /// Challenge header
    private var challengeHeader: some View {
        VStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.quantumYellow.opacity(0.2), Color.quantumOrange.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: challenge.iconName)
                    .font(.system(size: 36))
                    .foregroundColor(.quantumYellow)
            }
            
            Text(challenge.title)
                .font(.title2.bold())
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
            
            // Difficulty
            Label(challenge.difficulty.label, systemImage: "star.fill")
                .font(.subheadline)
                .foregroundColor(challenge.difficulty.color)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(challenge.difficulty.color.opacity(0.1))
                .cornerRadius(20)
        }
    }
    
    /// Requirements section
    private var requirementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Requirements")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            ForEach(challenge.requirements, id: \.self) { requirement in
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.quantumGreen)
                    
                    Text(requirement)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
    
    /// Rewards section
    private var rewardsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Rewards")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            HStack(spacing: 16) {
                RewardItem(
                    icon: "star.fill",
                    value: "+\(challenge.xpReward)",
                    label: "XP",
                    color: .quantumYellow
                )
                
                if challenge.streakBonus > 0 {
                    RewardItem(
                        icon: "flame.fill",
                        value: "+\(challenge.streakBonus)",
                        label: "Streak",
                        color: .quantumOrange
                    )
                }
                
                if let achievementId = challenge.achievementId {
                    RewardItem(
                        icon: "trophy.fill",
                        value: "New",
                        label: "Badge",
                        color: .quantumPurple
                    )
                }
            }
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
    
    /// Start button
    private var startButton: some View {
        Button(action: { showingQuiz = true }) {
            Text("Start Challenge")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.quantumYellow, .quantumOrange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
        }
        .sheet(isPresented: $showingQuiz) {
            // Challenge implementation would go here
            Text("Challenge Quiz/Activity")
                .onDisappear {
                    progressViewModel.completeDailyChallenge()
                    dismiss()
                }
        }
    }
}

// MARK: - Reward Item Component
/// Individual reward display
struct RewardItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline.bold())
                .foregroundColor(.textPrimary)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Preview
#Preview {
    DailyChallengeView()
        .environmentObject(ProgressViewModel())
        .padding()
        .background(Color.bgDark)
        .preferredColorScheme(.dark)
}
