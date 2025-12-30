//
//  HomeView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @EnvironmentObject var learningViewModel: LearnViewModel  // LearningViewModel 대신 LearnViewModel
    @EnvironmentObject var achievementViewModel: AchievementViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        progressCard
                        recentAchievements
                    }
                    .padding()
                }
            }
            .navigationTitle("Home")
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome back!")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
            
            Text(progressViewModel.userName)
                .font(.title2.bold())
                .foregroundColor(.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var progressCard: some View {
        VStack(spacing: 16) {
            Text("Level \(progressViewModel.userLevel)")
                .font(.headline)
                .foregroundColor(.quantumCyan)
            
            Text("\(progressViewModel.totalXP) XP")
                .font(.title2.bold())
                .foregroundColor(.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
    
    private var recentAchievements: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Achievements")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            if achievementViewModel.achievements.isEmpty {
                Text("Start learning to earn achievements!")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
