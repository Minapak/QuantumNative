//
//  QuantumNativeApp.swift
//  QuantumNative
//
//  The Quantum Odyssey - 2026 Premium Platform
//  Optional login flow: Basic content accessible without login
//  Premium features require login + subscription
//
//  Created by QuantumNative Team
//  Copyright © 2026 QuantumNative. All rights reserved.
//

import SwiftUI

@main
struct QuantumNativeApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var progressViewModel = ProgressViewModel()
    @StateObject private var achievementViewModel = AchievementViewModel()
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var learnViewModel = LearnViewModel()
    @StateObject private var practiceViewModel = PracticeViewModel()
    @StateObject private var exploreViewModel = ExploreViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()

    // Onboarding state for first-time users
    @AppStorage(OnboardingKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false

    // Selected language for immediate locale change
    @AppStorage(OnboardingKeys.selectedLanguage) private var selectedLanguage = "en"

    // Translation Manager for Solar Agent
    @ObservedObject private var translationManager = QuantumTranslationManager.shared

    // Computed locale based on selected language
    private var currentLocale: Locale {
        Locale(identifier: selectedLanguage)
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    // Main app for returning users
                    MainTabView()
                        .environmentObject(authViewModel)
                        .environmentObject(progressViewModel)
                        .environmentObject(achievementViewModel)
                        .environmentObject(homeViewModel)
                        .environmentObject(learnViewModel)
                        .environmentObject(practiceViewModel)
                        .environmentObject(exploreViewModel)
                        .environmentObject(profileViewModel)
                } else {
                    // Onboarding flow for first-time users
                    OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                }
            }
            .environment(\.locale, currentLocale)
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
extension QuantumNativeApp {
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
