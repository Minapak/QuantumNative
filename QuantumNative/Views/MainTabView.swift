//
//  MainTabView.swift
//  SwiftQuantum Learning App
//
//  2026 Premium Platform - The Quantum Odyssey
//  4-Hub Navigation Structure:
//  1. Campus Hub (Beginner Roadmap)
//  2. Laboratory (Interactive Learning)
//  3. Bridge Terminal (IBM QPU Integration)
//  4. Portfolio (O1 Visa Evidence)
//
//  Created by SwiftQuantum Team
//  Copyright © 2026 SwiftQuantum. All rights reserved.
//

import SwiftUI

// MARK: - Odyssey Tab Enum
enum OdysseyTab: String, CaseIterable {
    case campus = "Campus"
    case laboratory = "Laboratory"
    case bridge = "Bridge"
    case portfolio = "Portfolio"

    var iconName: String {
        switch self {
        case .campus: return "graduationcap.fill"
        case .laboratory: return "atom"
        case .bridge: return "server.rack"
        case .portfolio: return "briefcase.fill"
        }
    }

    var displayName: String {
        let manager = LocalizationManager.shared
        switch self {
        case .campus: return manager.localizedString("tab.campus")
        case .laboratory: return manager.localizedString("tab.laboratory")
        case .bridge: return manager.localizedString("tab.bridge")
        case .portfolio: return manager.localizedString("tab.portfolio")
        }
    }

    var color: Color {
        switch self {
        case .campus: return .quantumCyan
        case .laboratory: return .quantumPurple
        case .bridge: return .solarGold
        case .portfolio: return .miamiSunrise
        }
    }

    // Premium requirement for each tab
    var requiresPremium: Bool {
        switch self {
        case .campus, .laboratory: return false
        case .bridge, .portfolio: return true
        }
    }

    // Login requirement - Basic content doesn't require login
    var requiresLogin: Bool {
        switch self {
        case .campus, .laboratory: return false // Basic content is free
        case .bridge, .portfolio: return true   // Premium features require login
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @State private var selectedTab: OdysseyTab = .campus
    @State private var showPremiumUpgrade = false
    @State private var showLoginPrompt = false

    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @EnvironmentObject var learnViewModel: LearnViewModel
    @EnvironmentObject var achievementViewModel: AchievementViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var practiceViewModel: PracticeViewModel
    @EnvironmentObject var exploreViewModel: ExploreViewModel
    @EnvironmentObject var profileViewModel: ProfileViewModel

    @StateObject private var storeKitService = StoreKitService.shared
    @StateObject private var localizationManager = LocalizationManager.shared
    @ObservedObject var translationManager = QuantumTranslationManager.shared

    var body: some View {
        ZStack(alignment: .bottom) {
            // Content based on selected tab
            Group {
                switch selectedTab {
                case .campus:
                    CampusHubView()
                        .environmentObject(progressViewModel)
                case .laboratory:
                    InteractiveOdysseyView()
                case .bridge:
                    if canAccessPremiumTab {
                        GlobalBridgeConsoleView()
                    } else {
                        LockedTabView(tab: .bridge, onUnlock: handleUnlockTap)
                    }
                case .portfolio:
                    if canAccessPremiumTab {
                        QuantumCareerPassportView()
                    } else {
                        LockedTabView(tab: .portfolio, onUnlock: handleUnlockTap)
                    }
                }
            }

            // Custom Tab Bar
            OdysseyTabBar(
                selectedTab: $selectedTab,
                isPremium: storeKitService.isPremium,
                isLoggedIn: authViewModel.isLoggedIn
            )

            // Admin Badge - Only for admin users (not for DEBUG mode)
            // DEV mode badge removed for production release
        }
        .ignoresSafeArea(.keyboard)
        .environment(\.locale, localizationManager.locale)
        .id(localizationManager.currentLanguage) // Force view refresh on language change
        .onAppear {
            setupInitialData()
            translationManager.onDailyLogin()
        }
        .sheet(isPresented: $showPremiumUpgrade) {
            PremiumUpgradeView()
                .environmentObject(progressViewModel)
                .environment(\.locale, localizationManager.locale)
        }
        .sheet(isPresented: $showLoginPrompt) {
            LoginPromptSheet(onLogin: {
                showLoginPrompt = false
            })
            .environment(\.locale, localizationManager.locale)
        }
    }

    // MARK: - Access Control
    private var canAccessPremiumTab: Bool {
        // Premium tabs require login AND premium subscription
        return authViewModel.isLoggedIn && storeKitService.isPremium
    }

    private func handleUnlockTap() {
        if !authViewModel.isLoggedIn {
            showLoginPrompt = true
        } else if !storeKitService.isPremium {
            showPremiumUpgrade = true
        }
    }

    private func setupInitialData() {
        print("The Quantum Odyssey - Initializing...")

        progressViewModel.loadProgress()
        learnViewModel.loadTracks()
        achievementViewModel.loadAchievements()

        print("Odyssey data loading initiated")
    }
}

// MARK: - Odyssey Tab Bar
struct OdysseyTabBar: View {
    @Binding var selectedTab: OdysseyTab
    let isPremium: Bool
    let isLoggedIn: Bool

    var body: some View {
        HStack(spacing: 0) {
            ForEach(OdysseyTab.allCases, id: \.rawValue) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    isPremium: isPremium,
                    isLoggedIn: isLoggedIn,
                    onTap: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                    }
                )
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background(
            Rectangle()
                .fill(Color.bgCard)
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: -5)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - Tab Bar Button
struct TabBarButton: View {
    let tab: OdysseyTab
    let isSelected: Bool
    let isPremium: Bool
    let isLoggedIn: Bool
    let onTap: () -> Void

    private var isLocked: Bool {
        tab.requiresPremium && (!isLoggedIn || !isPremium)
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                ZStack {
                    // Background circle for selected state
                    if isSelected {
                        Circle()
                            .fill(tab.color.opacity(0.2))
                            .frame(width: 48, height: 48)
                    }

                    // Icon
                    Image(systemName: tab.iconName)
                        .font(.system(size: isSelected ? 24 : 20))
                        .foregroundColor(isSelected ? tab.color : (isLocked ? .textTertiary : .textSecondary))

                    // Lock badge for premium tabs
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.solarGold)
                            .padding(3)
                            .background(Circle().fill(Color.bgDark))
                            .offset(x: 14, y: -14)
                    }
                }
                .frame(height: 48)

                // Tab name
                Text(tab.displayName)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? tab.color : (isLocked ? .textTertiary : .textSecondary))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Locked Tab View
struct LockedTabView: View {
    let tab: OdysseyTab
    let onUnlock: () -> Void

    var body: some View {
        ZStack {
            Color.bgDark.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Lock Icon with Glow
                ZStack {
                    Circle()
                        .fill(tab.color.opacity(0.1))
                        .frame(width: 120, height: 120)

                    Circle()
                        .fill(tab.color.opacity(0.05))
                        .frame(width: 160, height: 160)

                    Image(systemName: "lock.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [tab.color, .solarGold],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(spacing: 12) {
                    Text(tab.displayName)
                        .font(.title.bold())
                        .foregroundColor(.white)

                    Text(NSLocalizedString("locked.premium.description", comment: ""))
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                // Features Preview
                VStack(alignment: .leading, spacing: 16) {
                    featureRow(icon: "checkmark.circle.fill", text: featureText(for: tab, index: 0))
                    featureRow(icon: "checkmark.circle.fill", text: featureText(for: tab, index: 1))
                    featureRow(icon: "checkmark.circle.fill", text: featureText(for: tab, index: 2))
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.bgCard)
                )
                .padding(.horizontal, 24)

                Spacer()

                // Unlock Button
                Button(action: onUnlock) {
                    HStack {
                        Image(systemName: "crown.fill")
                        Text(NSLocalizedString("locked.unlockPremium", comment: ""))
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [.solarGold, .miamiGlow],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 120)
            }
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.completed)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
        }
    }

    private func featureText(for tab: OdysseyTab, index: Int) -> String {
        switch tab {
        case .bridge:
            let features = [
                NSLocalizedString("bridge.feature1", comment: ""),
                NSLocalizedString("bridge.feature2", comment: ""),
                NSLocalizedString("bridge.feature3", comment: "")
            ]
            return features[index]
        case .portfolio:
            let features = [
                NSLocalizedString("portfolio.feature1", comment: ""),
                NSLocalizedString("portfolio.feature2", comment: ""),
                NSLocalizedString("portfolio.feature3", comment: "")
            ]
            return features[index]
        default:
            return ""
        }
    }
}

// MARK: - Login Prompt Sheet
struct LoginPromptSheet: View {
    @Environment(\.dismiss) var dismiss
    let onLogin: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgDark.ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer()

                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color.quantumCyan.opacity(0.1))
                            .frame(width: 100, height: 100)

                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.quantumCyan, .quantumPurple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }

                    VStack(spacing: 12) {
                        Text(NSLocalizedString("login.prompt.title", comment: ""))
                            .font(.title2.bold())
                            .foregroundColor(.white)

                        Text(NSLocalizedString("login.prompt.subtitle", comment: ""))
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    Spacer()

                    VStack(spacing: 16) {
                        // Login Button
                        NavigationLink {
                            AuthenticationView()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                Text(NSLocalizedString("login.signIn", comment: ""))
                            }
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.quantumCyan)
                            )
                        }

                        // Continue as Guest Button
                        Button {
                            dismiss()
                        } label: {
                            Text(NSLocalizedString("login.continueAsGuest", comment: ""))
                                .font(.subheadline)
                                .foregroundColor(.textSecondary)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.textTertiary)
                    }
                }
            }
        }
    }
}

// MARK: - Glass Morphism Extension
extension View {
    func glassMorphism() -> some View {
        self
            .background(.ultraThinMaterial)
            .environment(\.colorScheme, .dark)
    }
}

// MARK: - DEV Mode Badge
struct DevModeBadge: View {
    @State private var isExpanded = false

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                isExpanded.toggle()
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "hammer.fill")
                    .font(.system(size: 12, weight: .bold))

                if isExpanded {
                    Text("개발모드")
                        .font(.system(size: 11, weight: .bold))
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, isExpanded ? 12 : 8)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.fireRed, .miamiSunrise],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .fireRed.opacity(0.5), radius: 8, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
        .environmentObject(ProgressViewModel())
        .environmentObject(LearnViewModel())
        .environmentObject(AchievementViewModel())
        .environmentObject(HomeViewModel())
        .environmentObject(PracticeViewModel())
        .environmentObject(ExploreViewModel())
        .environmentObject(ProfileViewModel())
}
