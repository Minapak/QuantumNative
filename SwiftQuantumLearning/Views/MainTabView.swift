//
//  MainTabView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//
//  MARK: - Main Tab View
//  Container view that manages the 5 main tabs of the app.
//  Uses a custom tab bar for better styling control.
//

import SwiftUI

// MARK: - Tab Enum
/// Represents the five main tabs of the app
enum AppTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case learn = "Learn"
    case practice = "Practice"
    case explore = "Explore"
    case profile = "Profile"
    
    var id: String { rawValue }
    
    /// SF Symbol icon name for each tab
    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .learn: return "book.fill"
        case .practice: return "flask.fill"
        case .explore: return "binoculars.fill"
        case .profile: return "person.fill"
        }
    }
    
    /// Tab label text
    var label: String { rawValue }
}

// MARK: - Main Tab View
/// The main container view with custom tab bar
struct MainTabView: View {
    
    // MARK: - State
    /// Currently selected tab
    @State private var selectedTab: AppTab = .home
    
    /// Animation namespace for tab transitions
    @Namespace private var tabAnimation
    
    // MARK: - Environment
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @EnvironmentObject var learningViewModel: LearningViewModel
    @EnvironmentObject var achievementViewModel: AchievementViewModel
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background
            Color.bgDark
                .ignoresSafeArea()
            
            // Tab Content
            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            customTabBar
        }
        .ignoresSafeArea(.keyboard)
    }
    
    // MARK: - Tab Content
    /// Content view for each tab
    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .home:
            HomeScreenView()
                .transition(.opacity)
            
        case .learn:
            LearnScreenView()
                .transition(.opacity)
            
        case .practice:
            PracticeScreenView()
                .transition(.opacity)
            
        case .explore:
            ExploreScreenView()
                .transition(.opacity)
            
        case .profile:
            ProfileScreenView()
                .transition(.opacity)
        }
    }
    
    // MARK: - Custom Tab Bar
    /// Custom styled bottom tab bar
    private var customTabBar: some View {
        VStack(spacing: 0) {
            // Top divider
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 0.5)
            
            // Tab items
            HStack(spacing: 0) {
                ForEach(AppTab.allCases) { tab in
                    TabBarItemView(
                        tab: tab,
                        isSelected: selectedTab == tab,
                        namespace: tabAnimation
                    ) {
                        withAnimation(QuantumTheme.Animation.quick) {
                            selectedTab = tab
                        }
                        QuantumTheme.Haptics.selection()
                    }
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 8)
            .padding(.horizontal, 16)
            // Safe area padding for devices with home indicator
            .background(
                Color.bgDark
                    .shadow(color: Color.black.opacity(0.3), radius: 8, y: -4)
            )
        }
    }
}

// MARK: - Tab Bar Item View
/// Individual tab bar item with animation
struct TabBarItemView: View {
    let tab: AppTab
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    // MARK: - Constants
    private let iconSize: CGFloat = 22
    private let labelSize: CGFloat = 10
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                // Icon with selection indicator
                ZStack {
                    // Selection background pill
                    if isSelected {
                        Capsule()
                            .fill(Color.quantumCyan.opacity(0.2))
                            .frame(width: 56, height: 28)
                            .matchedGeometryEffect(id: "tabIndicator", in: namespace)
                    }
                    
                    // Tab icon
                    Image(systemName: tab.iconName)
                        .font(.system(size: iconSize, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? .quantumCyan : .textTertiary)
                }
                .frame(height: 28)
                
                // Tab label
                Text(tab.label)
                    .font(.system(size: labelSize, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .quantumCyan : .textTertiary)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Alternative System Tab Bar Implementation
/// Use this if you prefer the native TabView
struct SystemTabBarView: View {
    @State private var selectedTab: AppTab = .home
    
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @EnvironmentObject var learningViewModel: LearningViewModel
    @EnvironmentObject var achievementViewModel: AchievementViewModel
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeScreenView()
                .tabItem {
                    Label(AppTab.home.label, systemImage: AppTab.home.iconName)
                }
                .tag(AppTab.home)
            
            LearnScreenView()
                .tabItem {
                    Label(AppTab.learn.label, systemImage: AppTab.learn.iconName)
                }
                .tag(AppTab.learn)
            
            PracticeScreenView()
                .tabItem {
                    Label(AppTab.practice.label, systemImage: AppTab.practice.iconName)
                }
                .tag(AppTab.practice)
            
            ExploreScreenView()
                .tabItem {
                    Label(AppTab.explore.label, systemImage: AppTab.explore.iconName)
                }
                .tag(AppTab.explore)
            
            ProfileScreenView()
                .tabItem {
                    Label(AppTab.profile.label, systemImage: AppTab.profile.iconName)
                }
                .tag(AppTab.profile)
        }
        .tint(.quantumCyan)
    }
}

// MARK: - Placeholder Views
/// Placeholder for screens not yet implemented

struct PracticeScreenView: View {
    var body: some View {
        ZStack {
            Color.bgDark.ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(systemName: "flask.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.quantumCyan)
                
                Text("Practice")
                    .font(.title2.bold())
                    .foregroundColor(.textPrimary)
                
                Text("Coming Soon")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
        }
    }
}

struct ExploreScreenView: View {
    var body: some View {
        ZStack {
            Color.bgDark.ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(systemName: "binoculars.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.quantumCyan)
                
                Text("Explore")
                    .font(.title2.bold())
                    .foregroundColor(.textPrimary)
                
                Text("Coming Soon")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
        }
    }
}

struct ProfileScreenView: View {
    @EnvironmentObject var progressViewModel: ProgressViewModel
    
    var body: some View {
        ZStack {
            Color.bgDark.ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(systemName: "person.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.quantumCyan)
                
                Text("Profile")
                    .font(.title2.bold())
                    .foregroundColor(.textPrimary)
                
                Text("Level \(progressViewModel.userLevel)")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                
                Text("\(progressViewModel.totalXP) XP")
                    .font(.headline)
                    .foregroundColor(.quantumCyan)
            }
        }
    }
}

// MARK: - Preview Provider
#Preview("Main Tab View") {
    MainTabView()
        .environmentObject(ProgressViewModel.sample)
        .environmentObject(LearningViewModel.sample)
        .environmentObject(AchievementViewModel.sample)
}

#Preview("Tab Bar Only") {
    VStack {
        Spacer()
        
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 0.5)
            
            HStack(spacing: 0) {
                ForEach(AppTab.allCases) { tab in
                    VStack(spacing: 4) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 22))
                        
                        Text(tab.label)
                            .font(.system(size: 10))
                    }
                    .foregroundColor(tab == .home ? .quantumCyan : .textTertiary)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 12)
            .background(Color.bgDark)
        }
    }
    .background(Color.bgDark)
}
