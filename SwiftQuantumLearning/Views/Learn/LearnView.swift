//
//  LearnView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//
//  MARK: - Learn Screen View
//  The main learning hub where users select tracks and levels.
//  Displays learning paths with Duolingo-style progression.
//

import SwiftUI

// MARK: - Learn Screen View
/// Main learning hub with track selection and level progression
struct LearnView: View {
    
    // MARK: - Environment
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @EnvironmentObject var learningViewModel: LearningViewModel
    
    // MARK: - State
    @State private var selectedTrack: LearningTrack?
    @State private var showTrackSelector = false
    @State private var animateLevels = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.bgDark.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Track selector header
                    trackSelectorHeader
                    
                    // Levels scroll view
                    levelsScrollView
                }
            }
            .navigationTitle("Learn")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showTrackSelector = true }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.quantumCyan)
                    }
                }
            }
            .sheet(isPresented: $showTrackSelector) {
                TrackSelectorSheet(selectedTrack: $selectedTrack)
            }
            .onAppear {
                // Set default track if none selected
                if selectedTrack == nil {
                    selectedTrack = learningViewModel.tracks.first
                }
                
                // Animate levels
                withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                    animateLevels = true
                }
            }
        }
    }
    
    // MARK: - Track Selector Header
    /// Header showing current track with change option
    private var trackSelectorHeader: some View {
        VStack(spacing: 16) {
            // Current track info
            if let track = selectedTrack {
                Button(action: { showTrackSelector = true }) {
                    HStack(spacing: 12) {
                        // Track icon
                        Image(systemName: track.iconName)
                            .font(.title2)
                            .foregroundColor(.quantumCyan)
                            .frame(width: 44, height: 44)
                            .background(Color.quantumCyan.opacity(0.1))
                            .cornerRadius(12)
                        
                        // Track info
                        VStack(alignment: .leading, spacing: 2) {
                            Text(track.name)
                                .font(.headline)
                                .foregroundColor(.textPrimary)
                            
                            Text("\(track.levels.count) levels • \(track.completedCount) completed")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                        
                        Spacer()
                        
                        // Change indicator
                        Image(systemName: "chevron.down")
                            .foregroundColor(.textTertiary)
                    }
                    .padding(16)
                    .background(Color.bgCard)
                    .cornerRadius(16)
                }
                .buttonStyle(.plain)
                
                // Track progress bar
                trackProgressBar(track: track)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    /// Progress bar for current track
    private func trackProgressBar(track: LearningTrack) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Track Progress")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                Text("\(track.progressPercentage)%")
                    .font(.caption.bold())
                    .foregroundColor(.quantumCyan)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 6)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.quantumCyan, .quantumPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * CGFloat(track.progressPercentage) / 100,
                            height: 6
                        )
                }
            }
            .frame(height: 6)
        }
    }
    
    // MARK: - Levels Scroll View
    /// Scrollable list of levels in the selected track
    private var levelsScrollView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                if let track = selectedTrack {
                    ForEach(Array(track.levels.enumerated()), id: \.element.id) { index, level in
                        LevelRowView(
                            level: level,
                            index: index,
                            isUnlocked: isLevelUnlocked(level, at: index, in: track)
                        )
                        .offset(y: animateLevels ? 0 : 30)
                        .opacity(animateLevels ? 1 : 0)
                        .animation(
                            .easeOut(duration: 0.4).delay(Double(index) * 0.05),
                            value: animateLevels
                        )
                    }
                }
                
                // Bottom padding for tab bar
                Spacer()
                    .frame(height: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }
    
    /// Check if a level is unlocked
    private func isLevelUnlocked(_ level: LearningLevel, at index: Int, in track: LearningTrack) -> Bool {
        // First level is always unlocked
        if index == 0 { return true }
        
        // Level is unlocked if previous level is completed
        let previousLevel = track.levels[index - 1]
        return previousLevel.status == .completed
    }
}

// MARK: - Level Row View
/// Row component for a single level
struct LevelRowView: View {
    let level: LearningLevel
    let index: Int
    let isUnlocked: Bool
    
    var body: some View {
        NavigationLink(destination: LevelDetailView(level: level)) {
            HStack(spacing: 16) {
                // Level number indicator
                levelIndicator
                
                // Level info
                VStack(alignment: .leading, spacing: 4) {
                    Text("Level \(level.number)")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    Text(level.name)
                        .font(.headline)
                        .foregroundColor(isUnlocked ? .textPrimary : .textTertiary)
                    
                    Text(level.description)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                    
                    // Concepts tags
                    conceptTags
                }
                
                Spacer()
                
                // Status indicator
                statusIndicator
            }
            .padding(16)
            .background(Color.bgCard)
            .cornerRadius(16)
            .opacity(isUnlocked ? 1 : 0.6)
        }
        .buttonStyle(.plain)
        .disabled(!isUnlocked)
    }
    
    /// Level number indicator with status styling
    private var levelIndicator: some View {
        ZStack {
            Circle()
                .fill(indicatorBackgroundColor)
                .frame(width: 56, height: 56)
            
            if level.status == .completed {
                Image(systemName: "checkmark")
                    .font(.title3.bold())
                    .foregroundColor(.bgDark)
            } else if level.status == .inProgress {
                // Progress ring
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 3)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: CGFloat(level.progressPercentage) / 100)
                    .stroke(Color.quantumCyan, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                
                Text("\(level.number)")
                    .font(.headline.bold())
                    .foregroundColor(.textPrimary)
            } else if isUnlocked {
                Text("\(level.number)")
                    .font(.headline.bold())
                    .foregroundColor(.textPrimary)
            } else {
                Image(systemName: "lock.fill")
                    .font(.body)
                    .foregroundColor(.textTertiary)
            }
        }
    }
    
    /// Background color for level indicator
    private var indicatorBackgroundColor: Color {
        switch level.status {
        case .completed:
            return .completed
        case .inProgress:
            return Color.quantumCyan.opacity(0.1)
        case .locked:
            return Color.white.opacity(0.05)
        case .available:
            return isUnlocked ? Color.white.opacity(0.1) : Color.white.opacity(0.05)
        }
    }
    
    /// Tags showing concepts covered in level
    private var conceptTags: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(level.concepts.prefix(3), id: \.self) { concept in
                    Text(concept)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.quantumCyan.opacity(0.1))
                        .foregroundColor(.quantumCyan)
                        .cornerRadius(6)
                }
                
                if level.concepts.count > 3 {
                    Text("+\(level.concepts.count - 3)")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.05))
                        .foregroundColor(.textTertiary)
                        .cornerRadius(6)
                }
            }
        }
    }
    
    /// Status indicator showing completion or lock state
    private var statusIndicator: some View {
        Group {
            switch level.status {
            case .completed:
                Image(systemName: "star.fill")
                    .foregroundColor(.quantumOrange)
                
            case .inProgress:
                Text("\(level.progressPercentage)%")
                    .font(.caption.bold())
                    .foregroundColor(.quantumCyan)
                
            case .available:
                if isUnlocked {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.textTertiary)
                }
                
            case .locked:
                EmptyView()
            }
        }
    }
}

// MARK: - Track Selector Sheet
/// Bottom sheet for selecting learning tracks
struct TrackSelectorSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var learningViewModel: LearningViewModel
    @Binding var selectedTrack: LearningTrack?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Description
                        Text("Choose your learning path")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                            .padding(.bottom, 8)
                        
                        // Track options
                        ForEach(learningViewModel.tracks) { track in
                            TrackOptionRow(
                                track: track,
                                isSelected: selectedTrack?.id == track.id
                            ) {
                                selectedTrack = track
                                dismiss()
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Learning Tracks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.quantumCyan)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Track Option Row
/// Row component for track selection
struct TrackOptionRow: View {
    let track: LearningTrack
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: track.iconName)
                    .font(.title2)
                    .foregroundColor(isSelected ? .quantumCyan : .textSecondary)
                    .frame(width: 50, height: 50)
                    .background(
                        isSelected
                            ? Color.quantumCyan.opacity(0.1)
                            : Color.white.opacity(0.05)
                    )
                    .cornerRadius(12)
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(track.name)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    Text(track.description)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                    
                    // Stats
                    HStack(spacing: 12) {
                        Label("\(track.levels.count) levels", systemImage: "square.stack.fill")
                        Label("\(track.totalXP) XP", systemImage: "bolt.fill")
                    }
                    .font(.caption2)
                    .foregroundColor(.textTertiary)
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.quantumCyan)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.bgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? Color.quantumCyan : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview Provider
#Preview("Learn") {
    LearnView()
        .environmentObject(ProgressViewModel.sample)
        .environmentObject(LearningViewModel.sample)
        .preferredColorScheme(.dark)
}

#Preview("Level Row - Completed") {
    ZStack {
        Color.bgDark.ignoresSafeArea()
        
        LevelRowView(
            level: LearningLevel(
                id: "1",
                number: 1,
                name: "Quantum Basics",
                description: "Learn what makes quantum computing different from classical computing.",
                concepts: ["Qubit", "Superposition", "Classical vs Quantum"],
                status: .completed,
                progressPercentage: 100,
                xpReward: 100,
                estimatedMinutes: 15,
                sections: []
            ),
            index: 0,
            isUnlocked: true
        )
        .padding()
    }
}

#Preview("Level Row - In Progress") {
    ZStack {
        Color.bgDark.ignoresSafeArea()
        
        LevelRowView(
            level: LearningLevel(
                id: "2",
                number: 2,
                name: "Superposition",
                description: "Explore the fundamental principle of quantum mechanics.",
                concepts: ["Hadamard Gate", "Probability", "Measurement"],
                status: .inProgress,
                progressPercentage: 65,
                xpReward: 150,
                estimatedMinutes: 20,
                sections: []
            ),
            index: 1,
            isUnlocked: true
        )
        .padding()
    }
}

#Preview("Level Row - Locked") {
    ZStack {
        Color.bgDark.ignoresSafeArea()
        
        LevelRowView(
            level: LearningLevel(
                id: "3",
                number: 3,
                name: "Entanglement",
                description: "Discover the mysterious quantum connection between particles.",
                concepts: ["Bell State", "EPR Paradox", "Correlation"],
                status: .locked,
                progressPercentage: 0,
                xpReward: 200,
                estimatedMinutes: 25,
                sections: []
            ),
            index: 2,
            isUnlocked: false
        )
        .padding()
    }
}

#Preview("Track Selector") {
    TrackSelectorSheet(selectedTrack: .constant(nil))
        .environmentObject(LearningViewModel.sample)
        .preferredColorScheme(.dark)
}
