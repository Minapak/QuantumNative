//
//  UserStatsView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI
import Charts

// MARK: - User Stats View
/// Detailed statistics and analytics view
struct UserStatsView: View {
    
    // MARK: - Properties
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @State private var selectedTimeRange = 0
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Time range selector
                Picker("Time Range", selection: $selectedTimeRange) {
                    Text("Week").tag(0)
                    Text("Month").tag(1)
                    Text("All Time").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // XP Chart
                xpChart
                
                // Stats Grid
                statsGrid
                
                // Learning Patterns
                learningPatterns
                
                // Level Progress
                levelProgress
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - Subviews
    
    private var xpChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("XP Progress")
                .font(.headline)
                .foregroundColor(.textPrimary)
                .padding(.horizontal)
            
            // Placeholder chart
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.bgCard)
                .frame(height: 200)
                .overlay(
                    VStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.largeTitle)
                            .foregroundColor(.quantumCyan)
                        Text("XP Chart")
                            .foregroundColor(.textSecondary)
                    }
                )
                .padding(.horizontal)
        }
    }
    
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(title: "Total XP", value: "\(progressViewModel.totalXP)", icon: "star.fill")
            StatCard(title: "Levels", value: "\(progressViewModel.completedLevelsCount)", icon: "checkmark.circle.fill")
            StatCard(title: "Study Time", value: progressViewModel.studyTimeText, icon: "clock.fill")
            StatCard(title: "Best Streak", value: "\(progressViewModel.longestStreak) days", icon: "flame.fill")
        }
        .padding(.horizontal)
    }
    
    private var learningPatterns: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Learning Patterns")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            // Weekly activity
            HStack(spacing: 8) {
                ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { day in
                    VStack(spacing: 4) {
                        Text(day)
                            .font(.caption2)
                            .foregroundColor(.textTertiary)
                        
                        Circle()
                            .fill(Bool.random() ? Color.quantumCyan : Color.white.opacity(0.1))
                            .frame(width: 32, height: 32)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.bgCard)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
    
    private var levelProgress: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Track Progress")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                TrackProgressRow(track: "Beginner", progress: 0.8, color: .quantumGreen)
                TrackProgressRow(track: "Intermediate", progress: 0.4, color: .quantumCyan)
                TrackProgressRow(track: "Advanced", progress: 0.1, color: .quantumPurple)
            }
            .padding()
            .background(Color.bgCard)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.quantumCyan)
            
            Text(value)
                .font(.headline.bold())
                .foregroundColor(.textPrimary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
}

// MARK: - Track Progress Row
struct TrackProgressRow: View {
    let track: String
    let progress: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(track)
                    .font(.subheadline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.caption.bold())
                    .foregroundColor(color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 6)
                    
                    Capsule()
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 6)
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Preview
#Preview {
    UserStatsView()
        .environmentObject(ProgressViewModel.sample)
        .background(Color.bgDark)
}