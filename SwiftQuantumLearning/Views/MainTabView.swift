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
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(AppTab.home.rawValue, systemImage: AppTab.home.iconName)
                }
                .tag(AppTab.home)
            
            LearnView()
                .tabItem {
                    Label(AppTab.learn.rawValue, systemImage: AppTab.learn.iconName)
                }
                .tag(AppTab.learn)
            
            PracticeView()
                .tabItem {
                    Label(AppTab.practice.rawValue, systemImage: AppTab.practice.iconName)
                }
                .tag(AppTab.practice)
            
            ExploreView()
                .tabItem {
                    Label(AppTab.explore.rawValue, systemImage: AppTab.explore.iconName)
                }
                .tag(AppTab.explore)
            
            ProfileView()
                .tabItem {
                    Label(AppTab.profile.rawValue, systemImage: AppTab.profile.iconName)
                }
                .tag(AppTab.profile)
        }
        .tint(.quantumCyan)
    }
}