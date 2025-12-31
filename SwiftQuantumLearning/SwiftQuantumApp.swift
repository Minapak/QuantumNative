//
//  SwiftQuantumLearningApp.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

@main
struct SwiftQuantumLearningApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var progressViewModel = ProgressViewModel()
    @StateObject private var achievementViewModel = AchievementViewModel()
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var learnViewModel = LearnViewModel()
    @StateObject private var practiceViewModel = PracticeViewModel()
    @StateObject private var exploreViewModel = ExploreViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.isLoggedIn {
                MainTabView()
                    .environmentObject(authViewModel)    
                    .environmentObject(progressViewModel)
                    .environmentObject(achievementViewModel)
                    .environmentObject(homeViewModel)
                    .environmentObject(learnViewModel)
                    .environmentObject(practiceViewModel)
                    .environmentObject(exploreViewModel)
                    .environmentObject(profileViewModel)
                    .preferredColorScheme(.dark)
            } else {
                AuthenticationView()
                    .environmentObject(authViewModel)
                    .preferredColorScheme(.dark)
            }
        }
    }
}
