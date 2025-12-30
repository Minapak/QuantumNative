//
//  ProgressView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//
//  MARK: - Progress View
//  Displays user learning progress, statistics, and achievements overview
//

import SwiftUI
import Charts

// MARK: - Progress View
/// Comprehensive view of user's learning progress
struct ProgressView: View {
    
    // MARK: - Properties
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @EnvironmentObject var achievementViewModel: AchievementViewModel
    @State private var selectedTimeRange: TimeRange = .week
    @State private var showDetailedStats = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.bgDark.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Overall progress card
                        overallProgressCard
                            .padding(.horizontal)
                        
                        // Time range selector
                        timeRangeSelector
                            .padding(.horizontal)
                        
                        // Progress chart
                        progressChart
                            .padding(.horizontal)
                        
                        // Statistics grid
                        statisticsGrid
                            .padding(.horizontal)
                        
                        // Recent achievements
                        recentAchievementsSection
                            .padding(.horizontal)
                        
                        // Study streak
                        studyStreakCard
                            .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Your Progress")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Subviews
    
    /// Overall progress summary card
    private var overallProgressCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Level \(progressViewModel.userLevel)")
                        .font(.title.bold())
                        .foregroundColor(.textPrimary)
                    
                    Text("\(progressViewModel.totalXP) Total XP")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                // Progress ring
                ZStack {
                    Circle()
                        .stroke(Color.textTertiary.opacity(0.2), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: progressViewModel.levelProgress)
                        .stroke(
                            LinearGradient(
                                colors: [.quantumCyan, .quantumPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(progressViewModel.levelProgress * 100))%")
                        .font(.caption.bold())
                        .foregroundColor(.textPrimary)
                }
            }
            
            // XP progress bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Next Level")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    Spacer()
                    Text("\(progressViewModel.xpUntilNextLevel) XP to go")
                        .font(.caption.bold())
                        .foregroundColor(.quantumCyan)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.textTertiary.opacity(0.2))
                            .frame(height: 8)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.quantumCyan, .quantumPurple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progressViewModel.levelProgress, height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(16)
    }
    
    /// Time range selector
    private var timeRangeSelector: some View {
        HStack(spacing: 8) {
            ForEach(TimeRange.allCases) { range in
                Button(action: { selectedTimeRange = range }) {
                    Text(range.label)
                        .font(.caption.bold())
                        .foregroundColor(selectedTimeRange == range ? .white : .textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            selectedTimeRange == range ?
                            Color.quantumCyan : Color.bgCard
                        )
                        .cornerRadius(20)
                }
            }
        }
    }
    
    /// Progress chart
    private var progressChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("XP Progress")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            // Chart placeholder
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.bgCard)
                .frame(height: 200)
                .overlay(
                    progressChartContent
                )
        }
    }
    
    /// Chart content
    private var progressChartContent: some View {
        GeometryReader { geometry in
            let data = progressViewModel.getProgressData(for: selectedTimeRange)
            let maxValue = data.map { $0.value }.max() ?? 100
            
            HStack(alignment: .bottom, spacing: geometry.size.width / CGFloat(data.count * 2)) {
                ForEach(data) { point in
                    VStack {
                        Spacer()
                        
                        // Bar
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [.quantumCyan, .quantumPurple],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(
                                width: geometry.size.width / CGFloat(data.count * 2),
                                height: geometry.size.height * 0.7 * (CGFloat(point.value) / CGFloat(maxValue))
                            )
                        
                        // Label
                        Text(point.label)
                            .font(.system(size: 9))
                            .foregroundColor(.textTertiary)
                            .lineLimit(1)
                    }
                }
            }
            .padding()
        }
    }
    
    /// Statistics grid
    private var statisticsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(
                icon: "book.fill",
                value: "\(progressViewModel.lessonsCompleted)",
                label: "Lessons Completed",
                color: .quantumCyan
            )
            
            StatCard(
                icon: "clock.fill",
                value: "\(progressViewModel.totalStudyMinutes)m",
                label: "Study Time",
                color: .quantumPurple
            )
            
            StatCard(
                icon: "checkmark.circle.fill",
                value: "\(progressViewModel.levelsCompleted.count)",
                label: "Levels Complete",
                color: .quantumGreen
            )
            
            StatCard(
                icon: "trophy.fill",
                value: "\(achievementViewModel.unlockedAchievements.count)",
                label: "Achievements",
                color: .quantumYellow
            )
        }
    }
    
    /// Recent achievements section
    private var recentAchievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Achievements")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button(action: {}) {
                    Text("See All")
                        .font(.caption)
                        .foregroundColor(.quantumCyan)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(achievementViewModel.recentAchievements.prefix(5)) { achievement in
                        AchievementBadgeCompact(achievement: achievement)
                    }
                }
            }
        }
    }
    
    /// Study streak card
    private var studyStreakCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text("🔥")
                        .font(.title)
                    Text("\(progressViewModel.currentStreak) Day Streak")
                        .font(.headline.bold())
                        .foregroundColor(.textPrimary)
                }
                
                Text("Keep learning daily to maintain your streak!")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("Best")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
                Text("\(progressViewModel.longestStreak)")
                    .font(.title2.bold())
                    .foregroundColor(.quantumYellow)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.quantumYellow.opacity(0.1), Color.quantumOrange.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
}

// MARK: - Supporting Views

/// Statistics card component
struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Text(value)
                    .font(.title2.bold())
                    .foregroundColor(.textPrimary)
            }
            
            Text(label)
                .font(.caption)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
}

/// Compact achievement badge
struct AchievementBadgeCompact: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 4) {
            Text(achievement.icon)
                .font(.title)
            
            Text(achievement.title)
                .font(.caption2)
                .foregroundColor(.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80, height: 80)
        .background(Color.bgCard)
        .cornerRadius(12)
    }
}

// MARK: - Supporting Types

/// Time range for progress display
enum TimeRange: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    case all = "All Time"
    
    var id: String { rawValue }
    var label: String { rawValue }
}

/// Progress data point
struct ProgressDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: Int
}

// MARK: - Preview
#Preview {
    ProgressView()
        .environmentObject(ProgressViewModel())
        .environmentObject(AchievementViewModel())
        .preferredColorScheme(.dark)
}
