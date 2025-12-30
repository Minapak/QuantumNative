//
//  ProfileView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

// MARK: - Stat Item Component
struct StatItem: View {
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
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @EnvironmentObject var achievementViewModel: AchievementViewModel
    @State private var showSettings = false
    @State private var showAllAchievements = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        profileHeader
                        statsSection
                        achievementsPreview
                    }
                    .padding()
                }
            }
            .navigationTitle("Profile")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
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
                
                Text("Level \(progressViewModel.userLevel) • \(progressViewModel.totalXP) XP")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
        }
    }
    
    private var statsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                StatItem(
                    value: "\(progressViewModel.currentStreak)",
                    label: "Streak",
                    icon: "flame.fill"
                )
                
                StatItem(
                    value: "\(progressViewModel.completedLevelsCount)",
                    label: "Levels",
                    icon: "checkmark.circle.fill"
                )
                
                StatItem(
                    value: "\(achievementViewModel.unlockedCount)",
                    label: "Badges",
                    icon: "trophy.fill"
                )
            }
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
    
    private var achievementsPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Achievements")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button("See All") {
                    showAllAchievements = true
                }
                .font(.caption)
                .foregroundColor(.quantumCyan)
            }
            
            if achievementViewModel.recentUnlocks.isEmpty {
                Text("Start learning to unlock achievements!")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(achievementViewModel.recentUnlocks) { achievement in
                            MiniAchievementCard(achievement: achievement)
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

// MARK: - Mini Achievement Card
struct MiniAchievementCard: View {
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
        .background(Color.bgCard)
        .cornerRadius(8)
    }
}

// ProfileScreenView는 ProfileView의 별칭
typealias ProfileScreenView = ProfileView
