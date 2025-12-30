//
//  ProfileScreenView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//
//  MARK: - Profile Screen View
//  User profile with statistics, achievements, and settings
//

import SwiftUI

// MARK: - Profile Screen View
struct ProfileScreenView: View {
    
    // MARK: - Properties
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @EnvironmentObject var achievementViewModel: AchievementViewModel
    @State private var showSettings = false
    @State private var showAllAchievements = false
    @State private var selectedTab: ProfileTab = .overview
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.bgDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile header
                        profileHeader
                        
                        // Tab selector
                        tabSelector
                        
                        // Tab content
                        switch selectedTab {
                        case .overview:
                            overviewContent
                        case .achievements:
                            achievementsContent
                        case .statistics:
                            statisticsContent
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.quantumCyan)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showAllAchievements) {
                AchievementsView()
            }
        }
    }
    
    // MARK: - Subviews
    
    /// Profile header with avatar and basic info
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.quantumCyan, .quantumPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Text(progressViewModel.userName.prefix(2).uppercased())
                    .font(.title.bold())
                    .foregroundColor(.white)
            }
            
            // Name and level
            VStack(spacing: 8) {
                Text(progressViewModel.userName)
                    .font(.title2.bold())
                    .foregroundColor(.textPrimary)
                
                HStack(spacing: 12) {
                    Label("Level \(progressViewModel.userLevel)", systemImage: "star.fill")
                        .font(.subheadline)
                        .foregroundColor(.quantumCyan)
                    
                    Text("•")
                        .foregroundColor(.textTertiary)
                    
                    Text("\(progressViewModel.totalXP) XP")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
            }
            
            // Quick stats
            HStack(spacing: 24) {
                QuickStat(value: "\(progressViewModel.currentStreak)", label: "Streak", icon: "flame.fill")
                QuickStat(value: "\(progressViewModel.completedLevelsCount)", label: "Levels", icon: "checkmark.circle.fill")
                QuickStat(value: "\(achievementViewModel.unlockedCount)", label: "Badges", icon: "trophy.fill")
            }
            .padding()
            .background(Color.bgCard)
            .cornerRadius(12)
        }
    }
    
    /// Tab selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(ProfileTab.allCases) { tab in
                Button(action: { selectedTab = tab }) {
                    VStack(spacing: 8) {
                        Text(tab.title)
                            .font(.subheadline.bold())
                            .foregroundColor(selectedTab == tab ? .quantumCyan : .textSecondary)
                        
                        Rectangle()
                            .fill(selectedTab == tab ? Color.quantumCyan : Color.clear)
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    /// Overview content
    private var overviewContent: some View {
        VStack(spacing: 16) {
            // Progress summary
            ProgressSummaryCard(progressViewModel: progressViewModel)
            
            // Recent achievements
            RecentAchievementsCard(
                achievements: achievementViewModel.recentUnlocks,
                onSeeAll: { showAllAchievements = true }
            )
            
            // Learning streak
            StreakCard(currentStreak: progressViewModel.currentStreak, longestStreak: progressViewModel.longestStreak)
        }
    }
    
    /// Achievements content
    private var achievementsContent: some View {
        VStack(spacing: 16) {
            // Achievement stats
            AchievementStatsCard(viewModel: achievementViewModel)
            
            // Achievement categories
            ForEach(Category.allCases, id: \.self) { category in
                CategoryAchievementsCard(
                    category: category,
                    achievements: achievementViewModel.achievements(for: category)
                )
            }
        }
    }
    
    /// Statistics content
    private var statisticsContent: some View {
        UserStatsView()
    }
}

// MARK: - Profile Tab
enum ProfileTab: String, CaseIterable, Identifiable {
    case overview, achievements, statistics
    
    var id: String { rawValue }
    
    var title: String {
        rawValue.capitalized
    }
}

// MARK: - Supporting Views

/// Quick stat display
struct QuickStat: View {
    let value: String
    let label: String
    let icon: String
    
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
    }
}

/// Progress summary card
struct ProgressSummaryCard: View {
    let progressViewModel: ProgressViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Learning Progress")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            // Level progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Level \(progressViewModel.userLevel)")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                    
                    Text("\(progressViewModel.xpUntilNextLevel) XP to next")
                        .font(.caption)
                        .foregroundColor(.quantumCyan)
                }
                
                ProgressView(value: progressViewModel.levelProgress)
                    .tint(.quantumCyan)
            }
            
            // Completion stats
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(progressViewModel.completedLevelsCount)/\(progressViewModel.totalLevelsCount)")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    Text("Levels Complete")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(progressViewModel.studyTimeText)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    Text("Study Time")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
}

/// Recent achievements card
struct RecentAchievementsCard: View {
    let achievements: [Achievement]
    let onSeeAll: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Achievements")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button("See All", action: onSeeAll)
                    .font(.caption)
                    .foregroundColor(.quantumCyan)
            }
            
            if achievements.isEmpty {
                Text("Keep learning to unlock achievements!")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(achievements) { achievement in
                            MiniAchievementView(achievement: achievement)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
}

/// Mini achievement view
struct MiniAchievementView: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            Text(achievement.emoji)
                .font(.title2)
            
            Text(achievement.title)
                .font(.caption2)
                .foregroundColor(.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 70)
        }
        .padding(8)
        .background(achievement.rarity.color.opacity(0.1))
        .cornerRadius(8)
    }
}

/// Streak card
struct StreakCard: View {
    let currentStreak: Int
    let longestStreak: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Label("Learning Streak", systemImage: "flame.fill")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Text("Keep your daily streak going!")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(currentStreak)")
                    .font(.title.bold())
                    .foregroundColor(.quantumOrange)
                
                Text("Best: \(longestStreak)")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.quantumOrange.opacity(0.1), Color.quantumYellow.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
    }
}

/// Achievement stats card
struct AchievementStatsCard: View {
    let viewModel: AchievementViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Achievement Progress")
                .font(.headline)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("\(viewModel.unlockedCount)")
                        .font(.title2.bold())
                        .foregroundColor(.quantumCyan)
                    Text("Unlocked")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                VStack(spacing: 4) {
                    Text("\(viewModel.completionPercentage)%")
                        .font(.title2.bold())
                        .foregroundColor(.quantumPurple)
                    Text("Complete")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                VStack(spacing: 4) {
                    Text("\(viewModel.totalAchievementXP)")
                        .font(.title2.bold())
                        .foregroundColor(.quantumYellow)
                    Text("XP Earned")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
}

/// Category achievements card
struct CategoryAchievementsCard: View {
    let category: Category
    let achievements: [Achievement]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: category.iconName)
                    .foregroundColor(category.color)
                
                Text(category.displayName)
                    .font(.subheadline.bold())
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                let unlocked = achievements.filter { $0.isUnlocked }.count
                Text("\(unlocked)/\(achievements.count)")
                    .font(.caption.bold())
                    .foregroundColor(.textSecondary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(achievements) { achievement in
                        Image(systemName: achievement.isUnlocked ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(achievement.isUnlocked ? category.color : .textTertiary)
                            .font(.title3)
                    }
                }
            }
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
}

// MARK: - Preview
#Preview {
    ProfileScreenView()
        .environmentObject(ProgressViewModel())
        .environmentObject(AchievementViewModel())
        .preferredColorScheme(.dark)
}
