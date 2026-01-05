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
    @StateObject private var learningViewModel = LearnViewModel()
    @StateObject private var storeKitService = StoreKitService.shared
    @State private var selectedTrack: LearningTrack?
    @State private var showTrackSelector = false
    @State private var showPaywall = false
    @State private var animateLevels = false
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgDark.ignoresSafeArea()
                
                if isLoading {
                    loadingView
                } else if learningViewModel.tracks.isEmpty {
                    emptyStateView
                } else {
                    VStack(spacing: 0) {
                        if selectedTrack != nil {
                            trackSelectorHeader
                        }
                        
                        levelsScrollView
                    }
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
                    tracks: learningViewModel.tracks,
                    isPremium: storeKitService.isPremium,
                    onPremiumRequired: {
                        showTrackSelector = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showPaywall = true
                        }
                    }
                )
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .onAppear {
                Task {
                    // ✅ 데이터 로드 (약 0.5초 시뮬레이션)
                    if learningViewModel.tracks.isEmpty {
                        learningViewModel.loadTracks()
                    }
                    
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    
                    // ✅ 첫 track 자동 선택
                    if selectedTrack == nil && !learningViewModel.tracks.isEmpty {
                        selectedTrack = learningViewModel.tracks.first
                    }
                    
                    // ✅ 애니메이션 시작
                    withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                        animateLevels = true
                    }
                    
                    // ✅ 로딩 완료
                    isLoading = false
                }
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .tint(.quantumCyan)
            
            Text("Loading Learning Tracks...")
                .font(.headline)
                .foregroundColor(.textPrimary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.quantumCyan.opacity(0.5))
            
            Text("No Learning Tracks Available")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            Text("Learning tracks will appear here once loaded.")
                .font(.caption)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                isLoading = true
                Task {
                    learningViewModel.loadTracks()
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    if !learningViewModel.tracks.isEmpty {
                        selectedTrack = learningViewModel.tracks.first
                    }
                    isLoading = false
                }
            }) {
                Text("Retry")
                    .font(.headline)
                    .foregroundColor(.bgDark)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color.quantumCyan)
                    .cornerRadius(12)
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    if track.levels.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "list.bullet.indent")
                                .font(.system(size: 40))
                                .foregroundColor(.textSecondary.opacity(0.5))
                            
                            Text("No Levels in This Track")
                                .font(.subheadline)
                                .foregroundColor(.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(40)
                    } else {
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
    var isPremiumLocked: Bool = false
    var onPremiumTap: (() -> Void)? = nil

    var body: some View {
        Group {
            if isPremiumLocked {
                Button(action: { onPremiumTap?() }) {
                    levelContent
                        .overlay(alignment: .topTrailing) {
                            premiumBadge
                        }
                }
                .buttonStyle(.plain)
            } else {
                NavigationLink(destination: LevelDetailView(level: level)) {
                    levelContent
                }
                .buttonStyle(.plain)
                .disabled(!isUnlocked)
            }
        }
    }

    private var premiumBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "crown.fill")
                .font(.caption2)
            Text("PRO")
                .font(.caption2.bold())
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(LinearGradient(
                    colors: [.quantumOrange, .quantumPurple],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
        )
        .padding(8)
    }

    private var levelContent: some View {
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
            .opacity(isUnlocked && !isPremiumLocked ? 1 : 0.6)
    }
}

// MARK: - Track Selector Sheet
struct TrackSelectorSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedTrack: LearningTrack?
    let tracks: [LearningTrack]
    var isPremium: Bool = false
    var onPremiumRequired: (() -> Void)? = nil

    private let subscriptionManager = SubscriptionManager.shared

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

                        // 프리미엄 배너 (무료 사용자만)
                        if !isPremium {
                            premiumBanner
                        }

                        ForEach(Array(tracks.enumerated()), id: \.element.id) { index, track in
                            let isPremiumTrack = subscriptionManager.isPremiumContent(trackIndex: index)

                            TrackOptionRow(
                                track: track,
                                isSelected: selectedTrack?.id == track.id,
                                isPremiumLocked: isPremiumTrack && !isPremium
                            ) {
                                if isPremiumTrack && !isPremium {
                                    onPremiumRequired?()
                                } else {
                                    selectedTrack = track
                                    dismiss()
                                }
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

    private var premiumBanner: some View {
        Button(action: { onPremiumRequired?() }) {
            HStack(spacing: 12) {
                Image(systemName: "crown.fill")
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.quantumOrange, .quantumPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "premium.upgrade"))
                        .font(.headline)
                        .foregroundColor(.textPrimary)

                    Text(String(localized: "premium.locked.message"))
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.quantumCyan)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.bgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [.quantumCyan.opacity(0.5), .quantumPurple.opacity(0.5)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Track Option Row
struct TrackOptionRow: View {
    let track: LearningTrack
    let isSelected: Bool
    var isPremiumLocked: Bool = false
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                ZStack {
                    Image(systemName: track.iconName)
                        .font(.title2)
                        .foregroundColor(isPremiumLocked ? .textTertiary : (isSelected ? .quantumCyan : .textSecondary))
                        .frame(width: 50, height: 50)
                        .background(
                            isPremiumLocked
                                ? Color.white.opacity(0.03)
                                : (isSelected ? Color.quantumCyan.opacity(0.1) : Color.white.opacity(0.05))
                        )
                        .cornerRadius(12)

                    // 프리미엄 잠금 아이콘
                    if isPremiumLocked {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(.quantumOrange)
                            .padding(4)
                            .background(Circle().fill(Color.bgDark))
                            .offset(x: 18, y: 18)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(track.name)
                            .font(.headline)
                            .foregroundColor(isPremiumLocked ? .textTertiary : .textPrimary)

                        if isPremiumLocked {
                            Text("PRO")
                                .font(.caption2.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(LinearGradient(
                                            colors: [.quantumOrange, .quantumPurple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ))
                                )
                        }
                    }

                    Text(track.description)
                        .font(.caption)
                        .foregroundColor(isPremiumLocked ? .textTertiary : .textSecondary)
                        .lineLimit(2)

                    // Track stats
                    HStack(spacing: 16) {
                        Label("\(track.levels.count) levels", systemImage: "square.stack.3d.up")
                            .font(.caption2)
                            .foregroundColor(.textTertiary)

                        Label("\(track.totalXP) XP", systemImage: "star")
                            .font(.caption2)
                            .foregroundColor(isPremiumLocked ? .textTertiary : .quantumYellow)
                    }
                }

                Spacer()

                if isPremiumLocked {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.quantumOrange)
                } else if isSelected {
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
                                isPremiumLocked
                                    ? Color.quantumOrange.opacity(0.3)
                                    : (isSelected ? Color.quantumCyan : Color.clear),
                                lineWidth: isPremiumLocked ? 1 : 2
                            )
                    )
            )
            .opacity(isPremiumLocked ? 0.8 : 1)
        }
        .buttonStyle(.plain)
    }
}
