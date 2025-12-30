//
//  SwiftQuantumApp.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//
//  MARK: - App Entry Point
//  Main entry point for the SwiftQuantum Learning App.
//  Sets up global state and environment objects.
//

import SwiftUI

// MARK: - Main App
@main
struct SwiftQuantumApp: App {
    
    // MARK: - State Objects
    /// Global progress tracking ViewModel
    @StateObject private var progressViewModel = ProgressViewModel()
    
    /// Learning content ViewModel
    @StateObject private var learningViewModel = LearningViewModel()
    
    /// Achievements ViewModel
    @StateObject private var achievementViewModel = AchievementViewModel()
    
    // MARK: - App Scene
    var body: some Scene {
        WindowGroup {
            MainTabView()
                // Inject ViewModels as environment objects
                .environmentObject(progressViewModel)
                .environmentObject(learningViewModel)
                .environmentObject(achievementViewModel)
                // Force dark mode for consistent experience
                .preferredColorScheme(.dark)
                // Handle app lifecycle
                .onAppear {
                    setupApp()
                }
                .onChange(of: scenePhase) { _, newPhase in
                    handleScenePhaseChange(newPhase)
                }
        }
    }
    
    // MARK: - Scene Phase
    @Environment(\.scenePhase) private var scenePhase
    
    // MARK: - Setup Methods
    
    /// Initial app setup
    private func setupApp() {
        // Load user progress
        progressViewModel.loadProgress()
        
        // Sync learning content with user progress
        learningViewModel.syncWithUserProgress(progressViewModel.userProgress)
        
        // Sync achievements with user progress
        achievementViewModel.syncWithUnlockedIds(progressViewModel.userProgress.unlockedAchievementIds)
        
        // Configure appearance
        configureAppearance()
        
        print("📱 SwiftQuantum App launched successfully")
    }
    
    /// Handle scene phase changes (background, active, inactive)
    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .active:
            // App became active
            progressViewModel.userProgress.checkDailyChallengeReset()
            print("📱 App became active")
            
        case .inactive:
            // App is transitioning
            break
            
        case .background:
            // App went to background - save data
            progressViewModel.userProgress.save()
            print("💾 Saved progress to storage")
            
        @unknown default:
            break
        }
    }
    
    /// Configure global UI appearance
    private func configureAppearance() {
        // Configure navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(Color.bgDark)
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color.textPrimary)
        ]
        navBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(Color.textPrimary)
        ]
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        
        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color.bgDark)
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        
        // Configure table view appearance
        UITableView.appearance().backgroundColor = UIColor(Color.bgDark)
        
        // Configure scroll view indicators
        UIScrollView.appearance().indicatorStyle = .white
    }
}

// MARK: - App Constants
/// Global app constants
enum AppConstants {
    /// App name
    static let appName = "SwiftQuantum"
    
    /// App version
    static let version = "1.1.0"
    
    /// Build number
    static let build = "1"
    
    /// Full version string
    static var fullVersion: String {
        "\(version) (\(build))"
    }
    
    /// GitHub URL
    static let githubURL = URL(string: "https://github.com/Minapak/SwiftQuantum")!
    
    /// Documentation URL
    static let docsURL = URL(string: "https://swiftquantum.dev")!
    
    /// Blog URL
    static let blogURL = URL(string: "https://eunminpark.hashnode.dev")!
}

// MARK: - Debug Helpers
#if DEBUG
extension SwiftQuantumApp {
    /// Reset all user data (for testing)
    static func resetAllData() {
        UserDefaults.standard.removeObject(forKey: "SwiftQuantum_UserProgress")
        print("🗑️ All user data reset")
    }
    
    /// Print current progress (for debugging)
    static func printProgress(_ progress: UserProgress) {
        print("""
        
        📊 Current Progress:
        ├── User: \(progress.userName)
        ├── Level: \(progress.userLevel)
        ├── XP: \(progress.totalXP)
        ├── Streak: \(progress.currentStreak) days
        ├── Completed: \(progress.completedLevelsCount) levels
        └── Study Time: \(progress.studyTimeText)
        
        """)
    }
}
#endif

// MARK: - Preview Provider
#Preview("App Launch") {
    MainTabView()
        .environmentObject(ProgressViewModel.sample)
        .environmentObject(LearningViewModel.sample)
        .environmentObject(AchievementViewModel.sample)
        .preferredColorScheme(.dark)
}
