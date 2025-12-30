//
//  LevelListView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//
//  MARK: - Level List View
//  Displays a list of learning levels with progress and navigation
//

import SwiftUI

// MARK: - Level List View
/// Scrollable list of learning levels
struct LevelListView: View {
    
    // MARK: - Properties
    @EnvironmentObject var learningViewModel: LearningViewModel
    @EnvironmentObject var progressViewModel: ProgressViewModel
    let track: LearningLevel.Track
    @State private var selectedLevel: LearningLevel?
    @State private var animateLevels = false
    
    // MARK: - Computed Properties
    var filteredLevels: [LearningLevel] {
        learningViewModel.getLevels(for: track)
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                // Track header
                trackHeader
                
                // Levels list
                if filteredLevels.isEmpty {
                    emptyState
                } else {
                    levelsContent
                }
            }
            .padding()
        }
        .onAppear {
            withAnimation(.spring()) {
                animateLevels = true
            }
        }
        .sheet(item: $selectedLevel) { level in
            LevelDetailView(level: level)
        }
    }
    
    // MARK: - Subviews
    
    /// Track header with stats
    private var trackHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Track badge
                HStack(spacing: 8) {
                    Image(systemName: track.iconName)
                        .foregroundColor(track.primaryColor)
                    
                    Text("\(track.title) Track")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                }
                
                Spacer()
                
                // Progress indicator
                Text("\(learningViewModel.getCompletedCount(for: track))/\(filteredLevels.count)")
                    .font(.subheadline.bold())
                    .foregroundColor(.quantumCyan)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.textTertiary.opacity(0.2))
                        .frame(height: 6)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [track.primaryColor, track.secondaryColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * learningViewModel.getProgress(for: track),
                            height: 6
                        )
                        .animation(.spring(), value: learningViewModel.getProgress(for: track))
                }
            }
            .frame(height: 6)
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
    
    /// Levels content
    private var levelsContent: some View {
        LazyVStack(spacing: 12) {
            ForEach(Array(filteredLevels.enumerated()), id: \.element.id) { index, level in
                LevelRowView(
                    level: level,
                    isCompleted: progressViewModel.levelsCompleted.contains(level.id),
                    isLocked: !isLevelUnlocked(level),
                    index: index
                ) {
                    if isLevelUnlocked(level) {
                        selectedLevel = level
                    }
                }
                .opacity(animateLevels ? 1 : 0)
                .offset(y: animateLevels ? 0 : 20)
                .animation(
                    .spring().delay(Double(index) * 0.05),
                    value: animateLevels
                )
            }
        }
    }
    
    /// Empty state view
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.textTertiary)
            
            Text("No levels available")
                .font(.headline)
                .foregroundColor(.textSecondary)
            
            Text("Check back later for new content")
                .font(.subheadline)
                .foregroundColor(.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Helper Methods
    
    /// Check if level is unlocked
    private func isLevelUnlocked(_ level: LearningLevel) -> Bool {
        // First level is always unlocked
        guard let index = filteredLevels.firstIndex(where: { $0.id == level.id }),
              index > 0 else { return true }
        
        // Check if previous level is completed
        let previousLevel = filteredLevels[index - 1]
        return progressViewModel.levelsCompleted.contains(previousLevel.id)
    }
}

// MARK: - Level Row View
/// Individual level row component
struct LevelRowView: View {
    
    // MARK: - Properties
    let level: LearningLevel
    let isCompleted: Bool
    let isLocked: Bool
    let index: Int
    let action: () -> Void
    
    @State private var isPressed = false
    
    // MARK: - Body
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Level number/status indicator
                levelIndicator
                
                // Level information
                VStack(alignment: .leading, spacing: 6) {
                    // Title
                    Text(level.name)
                        .font(.subheadline.bold())
                        .foregroundColor(isLocked ? .textTertiary : .textPrimary)
                        .lineLimit(1)
                    
                    // Description
                    Text(level.description)
                        .font(.caption)
                        .foregroundColor(isLocked ? .textTertiary.opacity(0.7) : .textSecondary)
                        .lineLimit(2)
                    
                    // Bottom info
                    HStack(spacing: 12) {
                        // Duration
                        Label("\(level.estimatedDurationMinutes) min", systemImage: "clock")
                            .font(.caption2)
                            .foregroundColor(.textTertiary)
                        
                        // XP reward
                        if !isLocked {
                            Label("+\(level.xpReward) XP", systemImage: "star.fill")
                                .font(.caption2.bold())
                                .foregroundColor(.quantumYellow)
                        }
                        
                        // Topics count
                        Text("\(level.topics.count) topics")
                            .font(.caption2)
                            .foregroundColor(.textTertiary)
                    }
                }
                
                Spacer()
                
                // Right indicator
                rightIndicator
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isCompleted ?
                        Color.quantumGreen.opacity(0.05) :
                        (isLocked ? Color.bgCard.opacity(0.5) : Color.bgCard)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isCompleted ?
                                Color.quantumGreen.opacity(0.2) :
                                Color.clear,
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLocked)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { _ in
            isPressed = true
        } onPressingChanged: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }
    }
    
    // MARK: - Subviews
    
    /// Level number/status indicator
    private var levelIndicator: some View {
        ZStack {
            Circle()
                .fill(
                    isCompleted ?
                    Color.quantumGreen :
                    (isLocked ? Color.textTertiary.opacity(0.2) : levelGradient)
                )
                .frame(width: 44, height: 44)
            
            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            } else if isLocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.textTertiary)
            } else {
                Text("\(level.number)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
    
    /// Level gradient based on track
    private var levelGradient: some View {
        LinearGradient(
            colors: [
                level.track.primaryColor,
                level.track.secondaryColor
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Right side indicator
    private var rightIndicator: some View {
        Group {
            if isCompleted {
                VStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.quantumGreen)
                    
                    Text("Complete")
                        .font(.caption2)
                        .foregroundColor(.quantumGreen)
                }
            } else if isLocked {
                Image(systemName: "lock.circle")
                    .font(.title2)
                    .foregroundColor(.textTertiary)
            } else if level.progressPercentage > 0 {
                VStack(spacing: 4) {
                    Text("\(level.progressPercentage)%")
                        .font(.headline.bold())
                        .foregroundColor(.quantumCyan)
                    
                    Text("Progress")
                        .font(.caption2)
                        .foregroundColor(.textSecondary)
                }
            } else {
                Image(systemName: "chevron.right.circle")
                    .font(.title2)
                    .foregroundColor(.textTertiary)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        LevelListView(track: .beginner)
            .environmentObject(LearningViewModel())
            .environmentObject(ProgressViewModel())
            .navigationTitle("Beginner Levels")
            .background(Color.bgDark)
            .preferredColorScheme(.dark)
    }
}
