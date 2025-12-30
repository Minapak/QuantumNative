//
//  AchievementsView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

// MARK: - Achievements View
/// Full achievements gallery view
struct AchievementsView: View {
    
    // MARK: - Properties
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var achievementViewModel: AchievementViewModel
    @State private var selectedCategory: Category?
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Progress overview
                        achievementProgress
                        
                        // Category filter
                        categoryFilter
                        
                        // Achievements grid
                        achievementsGrid
                    }
                    .padding()
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.quantumCyan)
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var achievementProgress: some View {
        VStack(spacing: 16) {
            // Progress ring
            ProgressRing(
                progress: Double(achievementViewModel.completionPercentage) / 100,
                size: 120,
                showPercentage: false
            )
            .overlay(
                VStack(spacing: 4) {
                    Text("\(achievementViewModel.unlockedCount)")
                        .font(.title.bold())
                        .foregroundColor(.textPrimary)
                    Text("of \(achievementViewModel.totalCount)")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            )
            
            // Stats
            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text("\(achievementViewModel.completionPercentage)%")
                        .font(.headline.bold())
                        .foregroundColor(.quantumCyan)
                    Text("Complete")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                VStack(spacing: 4) {
                    Text("\(achievementViewModel.totalAchievementXP)")
                        .font(.headline.bold())
                        .foregroundColor(.quantumYellow)
                    Text("XP Earned")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.bgCard)
        .cornerRadius(16)
    }
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    title: "All",
                    isSelected: selectedCategory == nil,
                    color: .quantumCyan
                ) {
                    selectedCategory = nil
                }
                
                ForEach(Category.allCases, id: \.self) { category in
                    FilterChip(
                        title: category.displayName,
                        isSelected: selectedCategory == category,
                        color: category.color
                    ) {
                        selectedCategory = category
                    }
                }
            }
        }
    }
    
    private var achievementsGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 16) {
            ForEach(filteredAchievements) { achievement in
                AchievementGridItem(achievement: achievement)
            }
        }
    }
    
    private var filteredAchievements: [Achievement] {
        if let category = selectedCategory {
            return achievementViewModel.achievements.filter { $0.category == category }
        }
        return achievementViewModel.achievements
    }
}

// MARK: - Achievement Grid Item
struct AchievementGridItem: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        achievement.isUnlocked
                            ? achievement.rarity.gradient
                            : LinearGradient(colors: [Color.gray], startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: 60, height: 60)
                
                Text(achievement.emoji)
                    .font(.title)
                    .opacity(achievement.isUnlocked ? 1 : 0.3)
            }
            
            // Title
            Text(achievement.title)
                .font(.caption.bold())
                .foregroundColor(achievement.isUnlocked ? .textPrimary : .textTertiary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 32)
            
            // XP Badge
            if achievement.isUnlocked {
                Text("+\(achievement.xpReward) XP")
                    .font(.caption2)
                    .foregroundColor(.quantumYellow)
            } else {
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview
#Preview {
    AchievementsView()
        .environmentObject(AchievementViewModel.sample)
}