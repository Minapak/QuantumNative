//
//  MainTabView.swift
//  SwiftQuantum Learning App
//
//  2026 Premium Platform with QuantumBridge Integration
//
//  Created by SwiftQuantum Team
//  Copyright © 2026 SwiftQuantum. All rights reserved.
//

import SwiftUI

enum AppTab: String, CaseIterable {
    case home = "Home"
    case learn = "Learn"
    case factory = "Factory"  // Changed from Practice
    case explore = "Explore"
    case profile = "Profile"

    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .learn: return "book.fill"
        case .factory: return "cpu.fill"  // Updated icon for Quantum Factory
        case .explore: return "binoculars.fill"
        case .profile: return "person.fill"
        }
    }

    var displayName: String {
        switch self {
        case .factory: return "Quantum Factory"
        default: return self.rawValue
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home
    @State private var showPremiumUpgrade = false

    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @EnvironmentObject var learnViewModel: LearnViewModel
    @EnvironmentObject var achievementViewModel: AchievementViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    @EnvironmentObject var practiceViewModel: PracticeViewModel
    @EnvironmentObject var exploreViewModel: ExploreViewModel
    @EnvironmentObject var profileViewModel: ProfileViewModel

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .environmentObject(homeViewModel)
                .environmentObject(progressViewModel)
                .tabItem {
                    Label(AppTab.home.rawValue, systemImage: AppTab.home.iconName)
                }
                .tag(AppTab.home)

            LearnView()
                .environmentObject(learnViewModel)
                .environmentObject(progressViewModel)
                .tabItem {
                    Label(AppTab.learn.rawValue, systemImage: AppTab.learn.iconName)
                }
                .tag(AppTab.learn)

            // Quantum Factory (기존 Practice 탭 대체)
            QuantumFactoryView()
                .environmentObject(progressViewModel)
                .tabItem {
                    Label(AppTab.factory.displayName, systemImage: AppTab.factory.iconName)
                }
                .tag(AppTab.factory)

            ExploreView()
                .environmentObject(exploreViewModel)
                .tabItem {
                    Label(AppTab.explore.rawValue, systemImage: AppTab.explore.iconName)
                }
                .tag(AppTab.explore)

            ProfileView()
                .environmentObject(profileViewModel)
                .environmentObject(authViewModel)
                .environmentObject(progressViewModel)
                .tabItem {
                    Label(AppTab.profile.rawValue, systemImage: AppTab.profile.iconName)
                }
                .tag(AppTab.profile)
        }
        .tint(.quantumCyan)
        .onAppear {
            print("🔄 MainTabView appeared - loading data")

            // 로그인 후 데이터 로드
            progressViewModel.loadProgress()
            learnViewModel.loadTracks()
            achievementViewModel.loadAchievements()

            print("✅ Data loading initiated")
        }
        .sheet(isPresented: $showPremiumUpgrade) {
            PremiumUpgradeView()
                .environmentObject(progressViewModel)
        }
    }
}
