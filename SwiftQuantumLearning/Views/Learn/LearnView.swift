//
//  LearnView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

// MARK: - Learn View
struct LearnView: View {
    @StateObject private var progressViewModel = ProgressViewModel()
    @StateObject private var learningViewModel = LearnViewModel()
    @State private var selectedTrack: LearningTrack?
    @State private var showTrackSelector = false
    @State private var animateLevels = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgDark.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if selectedTrack != nil {
                        trackSelectorHeader
                    }
                    
                    levelsScrollView
                }
            }
            .navigationTitle("Learn")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: { showTrackSelector = true }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.quantumCyan)
                    }
                }
            }
            .sheet(isPresented: $showTrackSelector) {
                TrackSelectorSheet(
                    selectedTrack: $selectedTrack,
                    tracks: learningViewModel.tracks
                )
            }
            .onAppear {
                if selectedTrack == nil && !learningViewModel.tracks.isEmpty {
                    selectedTrack = learningViewModel.tracks.first
                }
                withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                    animateLevels = true
                }
            }
        }
    }
    
    private var trackSelectorHeader: some View {
        VStack(spacing: 16) {
            if let track = selectedTrack {
                Button(action: { showTrackSelector = true }) {
                    HStack(spacing: 12) {
                        Image(systemName: track.iconName)
                            .font(.title2)
                            .foregroundColor(.quantumCyan)
                            .frame(width: 44, height: 44)
                            .background(Color.quantumCyan.opacity(0.1))
                            .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(track.name)
                                .font(.headline)
                                .foregroundColor(.textPrimary)
                            
                            Text("\(track.levels.count) levels")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(.textTertiary)
                    }
                    .padding(16)
                    .background(Color.bgCard)
                    .cornerRadius(16)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    private var levelsScrollView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                if let track = selectedTrack {
                    ForEach(track.levels) { level in
                        LevelRowView(
                            level: level,
                            isCompleted: learningViewModel.completedLevels.contains(level.id),
                            isUnlocked: learningViewModel.isLevelUnlocked(level.id)
                        )
                        .offset(y: animateLevels ? 0 : 30)
                        .opacity(animateLevels ? 1 : 0)
                        .animation(
                            .easeOut(duration: 0.4),
                            value: animateLevels
                        )
                    }
                }
                
                Spacer()
                    .frame(height: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }
}

// MARK: - Level Row View
struct LevelRowView: View {
    let level: LearningLevel
    let isCompleted: Bool
    let isUnlocked: Bool
    
    var body: some View {
        NavigationLink(destination: LevelDetailView(level: level)) {
            HStack(spacing: 16) {
                // Level indicator
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.completed :
                              isUnlocked ? Color.bgCard :
                              Color.locked.opacity(0.3))
                        .frame(width: 56, height: 56)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                    } else if isUnlocked {
                        Text("\(level.number)")
                            .font(.headline.bold())
                            .foregroundColor(.textPrimary)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.title3)
                            .foregroundColor(.textTertiary)
                    }
                }
                
                // Level info
                VStack(alignment: .leading, spacing: 4) {
                    Text("Level \(level.number)")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    Text(level.title)
                        .font(.headline)
                        .foregroundColor(isUnlocked ? .textPrimary : .textTertiary)
                    
                    Text(level.description)
                        .font(.caption)
                        .foregroundColor(isUnlocked ? .textSecondary : .textTertiary)
                        .lineLimit(2)
                    
                    // XP reward
                    if isUnlocked && !isCompleted {
                        Label("\(level.xpReward) XP", systemImage: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.quantumYellow)
                    }
                }
                
                Spacer()
                
                if isUnlocked {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.textTertiary)
                }
            }
            .padding(16)
            .background(Color.bgCard)
            .cornerRadius(16)
            .opacity(isUnlocked ? 1 : 0.6)
        }
        .buttonStyle(.plain)
        .disabled(!isUnlocked)
    }
}

// MARK: - Track Selector Sheet
struct TrackSelectorSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedTrack: LearningTrack?
    let tracks: [LearningTrack]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Choose your learning path")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                            .padding(.bottom, 8)
                        
                        ForEach(tracks) { track in
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
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.quantumCyan)
                }
            }
        }
        #if os(iOS)
        .presentationDetents([.medium, .large])
        #endif
    }
}

// MARK: - Track Option Row
struct TrackOptionRow: View {
    let track: LearningTrack
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
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
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(track.name)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    Text(track.description)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                    
                    // Track stats
                    HStack(spacing: 16) {
                        Label("\(track.levels.count) levels", systemImage: "square.stack.3d.up")
                            .font(.caption2)
                            .foregroundColor(.textTertiary)
                        
                        Label("\(track.totalXP) XP", systemImage: "star")
                            .font(.caption2)
                            .foregroundColor(.quantumYellow)
                    }
                }
                
                Spacer()
                
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
