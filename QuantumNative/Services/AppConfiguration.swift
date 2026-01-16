//
//  AppConfiguration.swift
//  QuantumNative
//
//  Centralized configuration for all URLs, API endpoints, and app settings.
//  This eliminates hardcoded values throughout the codebase.
//
//  Created by SwiftQuantum Team
//  Copyright © 2026 SwiftQuantum. All rights reserved.
//

import Foundation

/// Centralized app configuration
enum AppConfiguration {

    // MARK: - API Configuration
    enum API {
        #if DEBUG
        static let baseURL = "http://localhost:8000"
        static let bridgeURL = "http://localhost:8001"
        static let bridgeWebSocketURL = "ws://localhost:8001"
        #else
        static let baseURL = "https://api.swiftquantum.tech"
        static let bridgeURL = "https://bridge.swiftquantum.tech"
        static let bridgeWebSocketURL = "wss://bridge.swiftquantum.tech"
        #endif

        // API Endpoints
        static let authLogin = "/api/v1/auth/login"
        static let authSignup = "/api/v1/auth/signup"
        static let authRefresh = "/api/v1/auth/refresh"
        static let userMe = "/api/v1/users/me"
        static let paymentVerify = "/api/v1/payment/verify"
        static let jobs = "/api/v1/jobs"

        // Bridge Endpoints
        static let bridgeHealth = "/health"
        static let bridgeBellState = "/bell-state"
        static let bridgeGrover = "/grover"
        static let bridgeDeutschJozsa = "/deutsch-jozsa"
    }

    // MARK: - External URLs
    enum URLs {
        // Legal
        static let privacyPolicy = "https://swiftquantum.tech/legal/privacy-policy.html"
        static let termsOfService = "https://swiftquantum.tech/legal/terms-of-service.html"

        // Social & Resources
        static let github = "https://github.com/eunmin-park/SwiftQuantum"
        static let blog = "https://eunminpark.hashnode.dev"
        static let qiskitDocs = "https://qiskit.org/documentation"
        static let qiskitTextbook = "https://qiskit.org/textbook"
        static let arxiv = "https://arxiv.org"

        // Support
        static let support = "mailto:support@swiftquantum.io"
        static let feedback = "mailto:feedback@swiftquantum.io"
    }

    // MARK: - StoreKit Product IDs
    enum Products {
        static let proMonthly = "com.quantumnative.pro.monthly"
        static let proYearly = "com.quantumnative.pro.yearly"
        static let premiumMonthly = "com.quantumnative.premium.monthly"
        static let premiumYearly = "com.quantumnative.premium.yearly"
    }

    // MARK: - Feature Flags
    enum Features {
        #if DEBUG
        static let enableDevMode = true
        static let bypassPremium = true
        static let enableDebugLogs = true
        #else
        static let enableDevMode = false
        static let bypassPremium = false
        static let enableDebugLogs = false
        #endif

        static let enableOfflineMode = true
        static let enableAnalytics = true
        static let enableCrashReporting = true
    }

    // MARK: - App Limits
    enum Limits {
        static let freeMaxQubits = 8
        static let proMaxQubits = 64
        static let premiumMaxQubits = 256

        static let freeCreditsPerMonth = 0
        static let proCreditsPerMonth = 100
        static let premiumCreditsPerMonth = 1000

        static let maxMessageHistory = 50
        static let maxJobHistory = 100
    }

    // MARK: - Default Values
    enum Defaults {
        static let defaultLanguage = "en"
        static let defaultExpertiseLevel = "beginner"
        static let initialFireEnergy = 0.5
    }

    // MARK: - Hardware Specs (Harvard-MIT 2026)
    enum HardwareSpecs {
        static let maxQubits = 3000
        static let continuousOperationHours = 2.0
        static let faultTolerantLogicalQubits = 96
        static let atomReplenishmentLatencyMs = 50.0
        static let averageFidelity = 0.9985
    }

    // MARK: - Keychain Keys
    enum KeychainKeys {
        static let accessToken = "quantum_access_token"
        static let refreshToken = "quantum_refresh_token"
        static let userId = "quantum_user_id"
    }

    // MARK: - UserDefaults Keys
    enum UserDefaultsKeys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let selectedLanguage = "selectedLanguage"
        static let selectedUserType = "selectedUserType"
        static let expertiseLevel = "quantum_expertise_level"
        static let solarAgentEnabled = "solar_agent_enabled"
        static let fireEnergyLevel = "fire_energy_level"
        static let lastSyncDate = "last_sync_date"
    }
}
