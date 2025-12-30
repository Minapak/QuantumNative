//
//  HomeView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//
//  MARK: - Home Screen View
//  The main landing screen showing user progress, daily challenge,
//  and quick access to continue learning.
//

import SwiftUI

// MARK: - Home Screen View
/// Main home screen displaying user progress and daily activities
struct HomeView: View {
    
    // MARK: - Environment
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @EnvironmentObject var learningViewModel: LearningViewModel
    @EnvironmentObject var achievementViewModel: AchievementViewModel
    
    // MARK: - State
    @State private var showDailyChallenge = false
    @State private var animateCards = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                backgroundGradient
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Welcome header
                        headerSection
                        
                        // Progress overview card
                        progressOverviewCard
                            .offset(y: animateCards ? 0 : 20)
                            .opacity(animateCards ? 1 : 0)
                        
                        // Daily challenge card
                        dailyChallengeCard
                            .offset(y: animateCards ? 0 : 20)
                            .opacity(animateCards ? 1 : 0)
                            .animation(.easeOut(duration: 0.5).delay(0.1), value: animateCards)
                        
                        // Continue learning section
                        continueLearningSection
                            .offset(y: animateCards ? 0 : 20)
                            .opacity(animateCards ? 1 : 0)
                            .animation(.easeOut(duration: 0.5).delay(0.2), value: animateCards)
                        
                        // Recent achievements
                        recentAchievementsSection
                            .offset(y: animateCards ? 0 : 20)
                            .opacity(animateCards ? 1 : 0)
                            .animation(.easeOut(duration: 0.5).delay(0.3), value: animateCards)
                        
                        // Bottom padding for tab bar
                        Spacer()
                            .frame(height: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Left: App logo
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 8) {
                        Image(systemName: "atom")
                            .font(.title2)
                            .foregroundColor(.quantumCyan)
                        
                        Text("SwiftQuantum")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                    }
                }
                
                // Right: Streak indicator
                ToolbarItem(placement: .navigationBarTrailing) {
                    streakIndicator
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    animateCards = true
                }
            }
        }
    }
    
    // MARK: - Background
    /// Dark gradient background
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.bgDark,
                Color.bgDark.opacity(0.95),
                Color(red: 0.05, green: 0.05, blue: 0.15)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Header Section
    /// Welcome message with user name
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(greetingMessage)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
            
            Text("Welcome back, \(progressViewModel.userName)!")
                .font(.title2.bold())
                .foregroundColor(.textPrimary)
            
            Text("Ready to explore quantum computing?")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    /// Dynamic greeting based on time of day
    private var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Good morning ☀️"
        case 12..<17:
            return "Good afternoon 🌤️"
        case 17..<21:
            return "Good evening 🌅"
        default:
            return "Good night 🌙"
        }
    }
    
    // MARK: - Streak Indicator
    /// Shows current learning streak
    private var streakIndicator: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .foregroundColor(.quantumOrange)
            
            Text("\(progressViewModel.currentStreak)")
                .font(.subheadline.bold())
                .foregroundColor(.textPrimary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.bgCard)
        .cornerRadius(12)
    }
    
    // MARK: - Progress Overview Card
    /// Card showing overall learning progress
    private var progressOverviewCard: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Your Progress")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                NavigationLink(destination: Text("Full Stats")) {
                    Text("See All")
                        .font(.caption)
                        .foregroundColor(.quantumCyan)
                }
            }
            
            // Stats row
            HStack(spacing: 0) {
                // Level
                StatItemView(
                    icon: "star.fill",
                    value: "\(progressViewModel.userLevel)",
                    label: "Level",
                    color: .quantumCyan
                )
                
                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 1, height: 40)
                
                // XP
                StatItemView(
                    icon: "bolt.fill",
                    value: "\(progressViewModel.totalXP)",
                    label: "XP",
                    color: .quantumOrange
                )
                
                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 1, height: 40)
                
                // Completed
                StatItemView(
                    icon: "checkmark.circle.fill",
                    value: "\(progressViewModel.completedLevelsCount)",
                    label: "Completed",
                    color: .completed
                )
            }
            
            // Progress bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Overall Progress")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                    
                    Text("\(progressViewModel.overallProgressPercentage)%")
                        .font(.caption.bold())
                        .foregroundColor(.quantumCyan)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 8)
                        
                        // Progress fill
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [.quantumCyan, .quantumPurple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geometry.size.width * CGFloat(progressViewModel.overallProgressPercentage) / 100,
                                height: 8
                            )
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(20)
        .background(Color.bgCard)
        .cornerRadius(16)
    }
    
    // MARK: - Daily Challenge Card
    /// Card showing today's challenge
    private var dailyChallengeCard: some View {
        Button(action: { showDailyChallenge = true }) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.quantumCyan.opacity(0.3), .quantumPurple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "target")
                        .font(.title2)
                        .foregroundColor(.quantumCyan)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Challenge")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    Text("Complete today's quantum puzzle")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    // Reward badge
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .font(.caption2)
                        Text("+50 XP")
                            .font(.caption.bold())
                    }
                    .foregroundColor(.quantumOrange)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .foregroundColor(.textTertiary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.bgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [.quantumCyan.opacity(0.5), .quantumPurple.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDailyChallenge) {
            DailyChallengeView()
        }
    }
    
    // MARK: - Continue Learning Section
    /// Section showing current level to continue
    private var continueLearningSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Continue Learning")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
            }
            
            // Current level card
            if let currentLevel = learningViewModel.currentLevel {
                NavigationLink(destination: LevelDetailView(level: currentLevel)) {
                    ContinueLevelCardView(level: currentLevel)
                }
                .buttonStyle(.plain)
            } else {
                // No level in progress - show start message
                StartLearningCardView()
            }
        }
    }
    
    // MARK: - Recent Achievements Section
    /// Section showing recently unlocked achievements
    private var recentAchievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Recent Achievements")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                NavigationLink(destination: AchievementsListView()) {
                    Text("See All")
                        .font(.caption)
                        .foregroundColor(.quantumCyan)
                }
            }
            
            // Achievement badges
            if achievementViewModel.recentAchievements.isEmpty {
                // Empty state
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "trophy")
                            .font(.title)
                            .foregroundColor(.textTertiary)
                        Text("Complete lessons to earn achievements!")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
                .background(Color.bgCard)
                .cornerRadius(12)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(achievementViewModel.recentAchievements.prefix(5)) { achievement in
                            AchievementBadgeView(achievement: achievement)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Stat Item View
/// Reusable component for displaying a stat with icon
struct StatItemView: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline.bold())
                .foregroundColor(.textPrimary)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Continue Level Card View
/// Card showing the current level to continue
struct ContinueLevelCardView: View {
    let level: LearningLevel
    
    var body: some View {
        HStack(spacing: 16) {
            // Progress circle
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 4)
                    .frame(width: 56, height: 56)
                
                Circle()
                    .trim(from: 0, to: CGFloat(level.progressPercentage) / 100)
                    .stroke(
                        LinearGradient(
                            colors: [.quantumCyan, .quantumPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 56, height: 56)
                    .rotationEffect(.degrees(-90))
                
                Text("\(level.progressPercentage)%")
                    .font(.caption.bold())
                    .foregroundColor(.textPrimary)
            }
            
            // Level info
            VStack(alignment: .leading, spacing: 4) {
                Text("Level \(level.number)")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                Text(level.name)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Text(level.description)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Continue button
            Image(systemName: "play.fill")
                .font(.title3)
                .foregroundColor(.quantumCyan)
                .padding(12)
                .background(Color.quantumCyan.opacity(0.1))
                .clipShape(Circle())
        }
        .padding(16)
        .background(Color.bgCard)
        .cornerRadius(16)
    }
}

// MARK: - Start Learning Card View
/// Card shown when no level is in progress
struct StartLearningCardView: View {
    var body: some View {
        NavigationLink(destination: LearnScreenView()) {
            HStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.title)
                    .foregroundColor(.quantumCyan)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Start Your Journey")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    Text("Begin learning quantum computing basics")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.quantumCyan)
            }
            .padding(16)
            .background(Color.bgCard)
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Achievement Badge View
/// Small badge showing an achievement
struct AchievementBadgeView: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            Text(achievement.emoji)
                .font(.title)
            
            Text(achievement.title)
                .font(.caption2)
                .foregroundColor(.textSecondary)
                .lineLimit(1)
        }
        .frame(width: 80)
        .padding(.vertical, 12)
        .background(Color.bgCard)
        .cornerRadius(12)
    }
}

// MARK: - Daily Challenge View (Placeholder)
/// Sheet view for daily challenge
struct DailyChallengeView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgDark.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Image(systemName: "target")
                        .font(.system(size: 64))
                        .foregroundColor(.quantumCyan)
                    
                    Text("Daily Challenge")
                        .font(.title.bold())
                        .foregroundColor(.textPrimary)
                    
                    Text("Complete a quantum measurement challenge!")
                        .font(.body)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    // Placeholder for challenge content
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.bgCard)
                        .frame(height: 200)
                        .overlay(
                            Text("Challenge Content Here")
                                .foregroundColor(.textTertiary)
                        )
                    
                    Spacer()
                }
                .padding(24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.quantumCyan)
                }
            }
        }
    }
}

// MARK: - Achievements List View (Placeholder)
/// Full list of achievements
struct AchievementsListView: View {
    @EnvironmentObject var achievementViewModel: AchievementViewModel
    
    var body: some View {
        ZStack {
            Color.bgDark.ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(achievementViewModel.allAchievements) { achievement in
                        AchievementRowView(achievement: achievement)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Achievement Row View
/// Row item for achievement list
struct AchievementRowView: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 16) {
            // Emoji/Icon
            Text(achievement.emoji)
                .font(.title)
                .frame(width: 50, height: 50)
                .background(
                    achievement.isUnlocked
                        ? Color.quantumCyan.opacity(0.1)
                        : Color.white.opacity(0.05)
                )
                .cornerRadius(12)
                .opacity(achievement.isUnlocked ? 1 : 0.5)
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(achievement.isUnlocked ? .textPrimary : .textTertiary)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            // Status
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.completed)
            } else {
                Image(systemName: "lock.fill")
                    .foregroundColor(.textTertiary)
            }
        }
        .padding(16)
        .background(Color.bgCard)
        .cornerRadius(12)
    }
}

// MARK: - Preview Provider
#Preview("Home") {
    HomeView()
        .environmentObject(ProgressViewModel.sample)
        .environmentObject(LearningViewModel.sample)
        .environmentObject(AchievementViewModel.sample)
        .preferredColorScheme(.dark)
}

#Preview("Progress Card") {
    ZStack {
        Color.bgDark.ignoresSafeArea()
        
        VStack(spacing: 16) {
            // Stats row preview
            HStack(spacing: 0) {
                StatItemView(
                    icon: "star.fill",
                    value: "5",
                    label: "Level",
                    color: .quantumCyan
                )
                
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 1, height: 40)
                
                StatItemView(
                    icon: "bolt.fill",
                    value: "1,250",
                    label: "XP",
                    color: .quantumOrange
                )
                
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 1, height: 40)
                
                StatItemView(
                    icon: "checkmark.circle.fill",
                    value: "12",
                    label: "Completed",
                    color: .completed
                )
            }
            .padding()
            .background(Color.bgCard)
            .cornerRadius(16)
        }
        .padding()
    }
}
