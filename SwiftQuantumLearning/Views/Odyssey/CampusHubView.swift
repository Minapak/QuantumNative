//
//  CampusHubView.swift
//  SwiftQuantumLearning
//
//  Frame 1: Campus Hub - Quantum Adventure Path
//  Beginner-friendly bento roadmap with Miami Sunrise gradients
//  Levels 1-13 with visual icons prioritized over complex formulas
//
//  Created by SwiftQuantum Team
//  Copyright © 2026 SwiftQuantum. All rights reserved.
//

import SwiftUI

// MARK: - Level Item for Campus Hub
struct CampusLevel: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let xpReward: Int
    let isPremium: Bool
    let isLocked: Bool
    let progress: Double // 0.0 ~ 1.0

    static let allLevels: [CampusLevel] = [
        CampusLevel(id: 1, title: "campus.level1.title", subtitle: "campus.level1.subtitle", icon: "atom", color: .quantumCyan, xpReward: 100, isPremium: false, isLocked: false, progress: 1.0),
        CampusLevel(id: 2, title: "campus.level2.title", subtitle: "campus.level2.subtitle", icon: "waveform", color: .quantumPurple, xpReward: 150, isPremium: false, isLocked: false, progress: 0.7),
        CampusLevel(id: 3, title: "campus.level3.title", subtitle: "campus.level3.subtitle", icon: "link", color: .miamiSunrise, xpReward: 200, isPremium: false, isLocked: false, progress: 0.3),
        CampusLevel(id: 4, title: "campus.level4.title", subtitle: "campus.level4.subtitle", icon: "square.grid.3x3", color: .quantumOrange, xpReward: 250, isPremium: false, isLocked: true, progress: 0),
        CampusLevel(id: 5, title: "campus.level5.title", subtitle: "campus.level5.subtitle", icon: "chart.line.uptrend.xyaxis", color: .solarGold, xpReward: 300, isPremium: false, isLocked: true, progress: 0),
        CampusLevel(id: 6, title: "campus.level6.title", subtitle: "campus.level6.subtitle", icon: "cpu", color: .quantumGreen, xpReward: 350, isPremium: true, isLocked: true, progress: 0),
        CampusLevel(id: 7, title: "campus.level7.title", subtitle: "campus.level7.subtitle", icon: "shield.checkered", color: .fireRed, xpReward: 400, isPremium: true, isLocked: true, progress: 0),
        CampusLevel(id: 8, title: "campus.level8.title", subtitle: "campus.level8.subtitle", icon: "magnifyingglass", color: .quantumCyan, xpReward: 450, isPremium: true, isLocked: true, progress: 0),
        CampusLevel(id: 9, title: "campus.level9.title", subtitle: "campus.level9.subtitle", icon: "waveform.path.ecg", color: .quantumPurple, xpReward: 500, isPremium: true, isLocked: true, progress: 0),
        CampusLevel(id: 10, title: "campus.level10.title", subtitle: "campus.level10.subtitle", icon: "function", color: .miamiGlow, xpReward: 550, isPremium: true, isLocked: true, progress: 0),
        CampusLevel(id: 11, title: "campus.level11.title", subtitle: "campus.level11.subtitle", icon: "leaf.arrow.triangle.circlepath", color: .quantumGreen, xpReward: 600, isPremium: true, isLocked: true, progress: 0),
        CampusLevel(id: 12, title: "campus.level12.title", subtitle: "campus.level12.subtitle", icon: "exclamationmark.triangle.fill", color: .quantumOrange, xpReward: 650, isPremium: true, isLocked: true, progress: 0),
        CampusLevel(id: 13, title: "campus.level13.title", subtitle: "campus.level13.subtitle", icon: "server.rack", color: .solarGold, xpReward: 1000, isPremium: true, isLocked: true, progress: 0)
    ]
}

// MARK: - Campus Hub View
struct CampusHubView: View {
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @StateObject private var storeKitService = StoreKitService.shared
    @ObservedObject var translationManager = QuantumTranslationManager.shared

    @State private var selectedLevel: CampusLevel?
    @State private var showPaywall = false
    @State private var animateXP = false
    @State private var xpPulseScale: CGFloat = 1.0

    // Bento grid columns
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                // Miami Sunrise Gradient Background
                LinearGradient(
                    colors: [.deepSeaNight, Color(red: 0.08, green: 0.1, blue: 0.2), .miamiSunrise.opacity(0.15)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header with XP Display
                        campusHeader

                        // Solar Agent Bubble
                        SolarAgentBubble()
                            .padding(.horizontal)

                        // Adventure Path Title
                        adventurePathHeader

                        // Bento Grid Levels
                        bentoGrid

                        // Bottom spacing
                        Spacer().frame(height: 100)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .navigationTitle(NSLocalizedString("campus.title", comment: ""))
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
        .onAppear {
            translationManager.onDailyLogin()
            startXPAnimation()
        }
    }

    // MARK: - Campus Header
    private var campusHeader: some View {
        VStack(spacing: 12) {
            // Top Row: Welcome + XP
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(NSLocalizedString("campus.welcome", comment: ""))
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                    Text(progressViewModel.userName)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .lineLimit(1)
                }

                Spacer()

                // XP Display
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.solarGold.opacity(0.3))
                            .frame(width: 50, height: 50)
                            .scaleEffect(xpPulseScale)

                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.miamiSunrise, .solarGold],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 42, height: 42)

                        Text("\(progressViewModel.totalXP)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("XP")
                            .font(.caption.bold())
                            .foregroundColor(.solarGold)
                        FireEnergyIndicator()
                    }
                }
            }

            // Bottom Row: Progress Bar
            HStack(spacing: 12) {
                // Progress info
                HStack(spacing: 8) {
                    Text("\(progressViewModel.completedLevelsCount)")
                        .font(.title.bold())
                        .foregroundColor(.white)
                    Text("/ 13 Levels")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                // Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [.miamiSunrise, .solarGold],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * (Double(progressViewModel.completedLevelsCount) / 13.0), height: 8)
                    }
                }
                .frame(width: 120, height: 8)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.miamiSunrise.opacity(0.3), lineWidth: 1)
                )
        )
    }

    // MARK: - Adventure Path Header
    private var adventurePathHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "map.fill")
                    .foregroundColor(.solarGold)
                Text(NSLocalizedString("campus.adventurePath", comment: ""))
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }

            Text(NSLocalizedString("campus.adventurePath.subtitle", comment: ""))
                .font(.subheadline)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Bento Grid
    private var bentoGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(CampusLevel.allLevels) { level in
                BentoLevelCard(
                    level: level,
                    isPremium: storeKitService.isPremium,
                    onTap: {
                        handleLevelTap(level)
                    }
                )
            }
        }
    }

    // MARK: - Actions
    private func handleLevelTap(_ level: CampusLevel) {
        if level.isPremium && !storeKitService.isPremium {
            showPaywall = true
        } else if !level.isLocked {
            selectedLevel = level
            // Navigate to level detail
        }
    }

    private func startXPAnimation() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            xpPulseScale = 1.15
        }
    }
}

// MARK: - Bento Level Card
struct BentoLevelCard: View {
    let level: CampusLevel
    let isPremium: Bool
    let onTap: () -> Void

    @State private var isPressed = false

    private var isAccessible: Bool {
        !level.isLocked && (!level.isPremium || isPremium)
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Top Row: Icon and Lock/Premium Badge
                HStack {
                    ZStack {
                        Circle()
                            .fill(level.color.opacity(0.2))
                            .frame(width: 44, height: 44)

                        Image(systemName: level.icon)
                            .font(.title2)
                            .foregroundColor(isAccessible ? level.color : .textTertiary)
                    }

                    Spacer()

                    if level.isLocked {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundColor(.textTertiary)
                    } else if level.isPremium && !isPremium {
                        Text("PRO")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.fireGradient)
                            )
                    } else if level.progress > 0 && level.progress < 1 {
                        // Progress indicator
                        CircularProgressView(progress: level.progress, color: level.color)
                            .frame(width: 24, height: 24)
                    } else if level.progress >= 1 {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.completed)
                    }
                }

                // Title
                Text(NSLocalizedString(level.title, comment: ""))
                    .font(.headline)
                    .foregroundColor(isAccessible ? .white : .textTertiary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                // Subtitle
                Text(NSLocalizedString(level.subtitle, comment: ""))
                    .font(.caption)
                    .foregroundColor(isAccessible ? .textSecondary : .textTertiary)
                    .lineLimit(2)

                Spacer()

                // XP Reward
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(isAccessible ? .solarGold : .textTertiary)
                    Text("\(level.xpReward) XP")
                        .font(.caption2.bold())
                        .foregroundColor(isAccessible ? .solarGold : .textTertiary)
                }
            }
            .padding(16)
            .frame(height: 160)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.bgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                level.progress >= 1 ? Color.completed.opacity(0.5) :
                                    (isAccessible ? level.color.opacity(0.3) : Color.clear),
                                lineWidth: 1.5
                            )
                    )
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .opacity(isAccessible ? 1 : 0.6)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Circular Progress View
struct CircularProgressView: View {
    let progress: Double
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 3)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text("\(Int(progress * 100))")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(color)
        }
    }
}

// MARK: - Preview
#Preview {
    CampusHubView()
        .environmentObject(ProgressViewModel())
}
