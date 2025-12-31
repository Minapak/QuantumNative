//
//  MainTabView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

enum AppTab: String, CaseIterable {
    case home = "Home"
    case learn = "Learn"
    case practice = "Practice"
    case explore = "Explore"
    case profile = "Profile"
    
    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .learn: return "book.fill"
        case .practice: return "flask.fill"
        case .explore: return "binoculars.fill"
        case .profile: return "person.fill"
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home
    
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
            
            PracticeView()
                .environmentObject(practiceViewModel)
                .environmentObject(progressViewModel)
                .tabItem {
                    Label(AppTab.practice.rawValue, systemImage: AppTab.practice.iconName)
                }
                .tag(AppTab.practice)
            
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
    }
}
