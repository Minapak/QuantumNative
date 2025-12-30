//
//  ProgressCard.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//
//  MARK: - Progress Card Component
//  Displays user's current progress with XP, level, and streak information
//

import SwiftUI

// MARK: - Progress Card
/// Main progress display card for the home screen
struct ProgressCard: View {
    
    // MARK: - Properties
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @State private var animateProgress = false
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 20) {
            // Header with level and XP
            headerSection
            
            // Progress ring visualization
            progressRingSection
            
            // Stats grid
            statsGrid
            
            // Streak indicator
            streakSection
        }
        .padding()
        .background(backgroundGradient)
        .cornerRadius(20)
        .shadow(color: Color.quantumCyan.opacity(0.1), radius: 10, x: 0, y: 5)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateProgress = true
            }
        }
    }
    
    // MARK: - Subviews
    
    /// Header section with level and XP
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Progress")
                    .font(.headline)
                    .foregroundColor(.textSecondary)
                
                HStack(spacing: 8) {
                    Text("Level \(progressViewModel.userLevel)")
                        .font(.title2.bold())
                        .foregroundColor(.textPrimary)
                    
                    Image(systemName: "chevron.up.circle.fill")
                        .foregroundColor(.quantumGreen)
                        .opacity(progressViewModel.recentlyLeveledUp ? 1 : 0)
                        .scaleEffect(animateProgress ? 1 : 0)
                        .animation(.spring().delay(0.3), value: animateProgress)
                }
            }
            
            Spacer()
            
            // XP badge
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundColor(.quantumYellow)
                    .font(.caption)
                
                Text("\(progressViewModel.totalXP)")
                    .font(.headline.bold())
                    .foregroundColor(.textPrimary)
                
                Text("XP")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.quantumYellow.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    /// Progress ring visualization
    private var progressRingSection: some View {
        HStack(spacing: 24) {
            // Main progress ring
            ZStack {
                Circle()
                    .stroke(Color.textTertiary.opacity(0.1), lineWidth: 12)
                    .frame(width: 100, height: 100)
                
                Circle()
                    .trim(from: 0, to: animateProgress ? progressViewModel.levelProgress : 0)
                    .stroke(
                        LinearGradient(
                            colors: [.quantumCyan, .quantumPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 2) {
                    Text("\(Int(progressViewModel.levelProgress * 100))")
                        .font(.title.bold())
                        .foregroundColor(.textPrimary)
                    
                    Text("%")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
            
            // Progress details
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Next Level")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    Text("\(progressViewModel.xpUntilNextLevel) XP")
                        .font(.headline)
                        .foregroundColor(.quantumCyan)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Goal")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    Text(progressViewModel.currentLevelName)
                        .font(.subheadline.bold())
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
    }
    
    /// Statistics grid
    private var statsGrid: some View {
        HStack(spacing: 16) {
            StatItem(
                icon: "book.fill",
                value: "\(progressViewModel.lessonsCompleted)",
                label: "Lessons"
            )
            
            StatItem(
                icon: "checkmark.circle.fill",
                value: "\(progressViewModel.levelsCompleted.count)",
                label: "Levels"
            )
            
            StatItem(
                icon: "clock.fill",
                value: progressViewModel.studyTimeText,
                label: "Study Time"
            )
        }
    }
    
    /// Streak section
    private var streakSection: some View {
        HStack {
            HStack(spacing: 8) {
                Text(progressViewModel.streakEmoji)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(progressViewModel.currentStreak) Day Streak")
                        .font(.subheadline.bold())
                        .foregroundColor(.textPrimary)
                    
                    Text("Keep it going!")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
            
            Spacer()
            
            // Streak calendar preview
            HStack(spacing: 2) {
                ForEach(0..<7, id: \.self) { day in
                    Circle()
                        .fill(day < progressViewModel.currentStreak % 7 ?
                              Color.quantumYellow : Color.textTertiary.opacity(0.2))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding(12)
        .background(Color.quantumYellow.opacity(0.05))
        .cornerRadius(12)
    }
    
    /// Background gradient
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: Color.bgCard, location: 0),
                .init(color: Color.bgCard.opacity(0.95), location: 1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Stat Item Component
/// Individual statistic item
struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.quantumCyan)
            
            Text(value)
                .font(.headline.bold())
                .foregroundColor(.textPrimary)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.bgDark.opacity(0.5))
        .cornerRadius(8)
    }
}

// MARK: - Preview
#Preview {
    ProgressCard()
        .environmentObject(ProgressViewModel())
        .padding()
        .background(Color.bgDark)
        .preferredColorScheme(.dark)
}
