//
//  CurrentLevelView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//
//  MARK: - Current Level View
//  Displays the current learning level with progress and next steps
//

import SwiftUI

// MARK: - Current Level View
/// Shows the current level the user is working on
struct CurrentLevelView: View {
    
    // MARK: - Properties
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @EnvironmentObject var learningViewModel: LearningViewModel
    @State private var showLevelDetail = false
    @State private var animateCard = false
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            sectionHeader
            
            // Level card
            if let currentLevel = progressViewModel.currentLevel {
                levelCard(for: currentLevel)
            } else {
                completionCard
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animateCard = true
            }
        }
    }
    
    // MARK: - Subviews
    
    /// Section header
    private var sectionHeader: some View {
        HStack {
            Text("Continue Learning")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Button(action: { showLevelDetail = true }) {
                Text("View All")
                    .font(.caption)
                    .foregroundColor(.quantumCyan)
            }
        }
    }
    
    /// Level card for current level
    private func levelCard(for level: LearningLevel) -> some View {
        Button(action: { showLevelDetail = true }) {
            VStack(spacing: 0) {
                // Top section with level info
                HStack(spacing: 16) {
                    // Level icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.quantumCyan.opacity(0.2), Color.quantumPurple.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                        
                        Text("\(level.number)")
                            .font(.title2.bold())
                            .foregroundColor(.quantumCyan)
                    }
                    .scaleEffect(animateCard ? 1 : 0.8)
                    .opacity(animateCard ? 1 : 0)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Level \(level.number)")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                        
                        Text(level.name)
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                            .lineLimit(1)
                        
                        HStack(spacing: 8) {
                            // Difficulty badge
                            Label(level.track.rawValue.capitalized, systemImage: "star.fill")
                                .font(.caption)
                                .foregroundColor(level.difficultyColor)
                            
                            // Time estimate
                            Label("\(level.estimatedDurationMinutes) min", systemImage: "clock")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Progress indicator
                    VStack(spacing: 4) {
                        Text("\(progressViewModel.currentLevelProgressPercent)%")
                            .font(.headline.bold())
                            .foregroundColor(.quantumCyan)
                        
                        Text("Complete")
                            .font(.caption2)
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding()
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.textTertiary.opacity(0.1))
                            .frame(height: 4)
                        
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.quantumCyan, .quantumPurple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geometry.size.width * (Double(progressViewModel.currentLevelProgressPercent) / 100),
                                height: 4
                            )
                            .animation(.spring(), value: progressViewModel.currentLevelProgressPercent)
                    }
                }
                .frame(height: 4)
                
                // Bottom section with description
                VStack(alignment: .leading, spacing: 8) {
                    Text(level.description)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                    
                    HStack {
                        // Topics preview
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(level.topics.prefix(3), id: \.self) { topic in
                                    Text(topic)
                                        .font(.caption2)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.quantumCyan.opacity(0.1))
                                        .foregroundColor(.quantumCyan)
                                        .cornerRadius(6)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(.quantumCyan)
                            .font(.title3)
                    }
                }
                .padding()
                .background(Color.bgDark.opacity(0.5))
            }
        }
        .background(Color.bgCard)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showLevelDetail) {
            LevelDetailView(level: level)
        }
    }
    
    /// Completion card when all levels are done
    private var completionCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 48))
                .foregroundColor(.quantumYellow)
                .scaleEffect(animateCard ? 1 : 0.5)
                .opacity(animateCard ? 1 : 0)
            
            VStack(spacing: 8) {
                Text("🎉 Congratulations!")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Text("You've completed all available levels")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {}) {
                Text("Explore Practice Mode")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.quantumCyan, .quantumPurple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            LinearGradient(
                colors: [Color.quantumYellow.opacity(0.05), Color.quantumPurple.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
}

// MARK: - Level Difficulty Extension
extension LearningLevel {
    /// Color based on difficulty/track
    var difficultyColor: Color {
        switch track {
        case .beginner: return .quantumGreen
        case .intermediate: return .quantumYellow
        case .advanced: return .quantumOrange
        case .expert: return .quantumRed
        }
    }
}

// MARK: - Preview
#Preview {
    CurrentLevelView()
        .environmentObject(ProgressViewModel())
        .environmentObject(LearningViewModel())
        .padding()
        .background(Color.bgDark)
        .preferredColorScheme(.dark)
}
