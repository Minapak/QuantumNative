//
//  SwiftQuantumLearningApp.swift
//  SwiftQuantum Learning App
//
//  The Quantum Odyssey - 2026 Premium Platform
//  Optional login flow: Basic content accessible without login
//  Premium features require login + subscription
//
//  Created by SwiftQuantum Team
//  Copyright © 2026 SwiftQuantum. All rights reserved.
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

    // Translation Manager for Solar Agent
    @ObservedObject private var translationManager = QuantumTranslationManager.shared

    var body: some Scene {
        WindowGroup {
            // Always show MainTabView - login is optional for basic content
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
                .onAppear {
                    setupAppearance()
                    initializeOdyssey()
                }
        }
    }

    // MARK: - Setup
    private func setupAppearance() {
        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color.bgCard)
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

        // Configure navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(Color.bgDark)
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }

    private func initializeOdyssey() {
        print("The Quantum Odyssey - Starting...")
        print("Login status: \(authViewModel.isLoggedIn ? "Logged in" : "Guest mode")")
        print("Premium status: \(StoreKitService.shared.isPremium ? "Premium" : "Free")")
        print("Expertise level: \(translationManager.currentExpertiseLevel.rawValue)")
        print("Fire energy: \(String(format: "%.0f%%", translationManager.fireEnergyLevel * 100))")

        // Trigger daily login bonus for Solar Agent
        translationManager.onDailyLogin()
    }
}

// MARK: - App Configuration
extension SwiftQuantumLearningApp {
    static let appVersion = "2.0.0"
    static let buildNumber = "2026.01"
    static let platformName = "The Quantum Odyssey"

    static var isDebugMode: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
}
