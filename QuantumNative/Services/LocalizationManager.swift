//
//  LocalizationManager.swift
//  QuantumNative
//
//  Dynamic localization manager that enables instant language switching
//  without requiring app restart.
//
//  Created by SwiftQuantum Team
//  Copyright © 2026 SwiftQuantum. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

/// Supported languages in the app
enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case korean = "ko"
    case japanese = "ja"
    case chinese = "zh-Hans"
    case german = "de"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .korean: return "한국어"
        case .japanese: return "日本語"
        case .chinese: return "简体中文"
        case .german: return "Deutsch"
        }
    }

    var localizedName: String {
        switch self {
        case .english: return "English"
        case .korean: return "Korean"
        case .japanese: return "Japanese"
        case .chinese: return "Chinese"
        case .german: return "German"
        }
    }

    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .korean: return "🇰🇷"
        case .japanese: return "🇯🇵"
        case .chinese: return "🇨🇳"
        case .german: return "🇩🇪"
        }
    }
}

/// Manages app localization with instant language switching
@MainActor
class LocalizationManager: ObservableObject {

    // MARK: - Singleton
    static let shared = LocalizationManager()

    // MARK: - Published Properties
    @Published private(set) var currentLanguage: AppLanguage
    @Published private(set) var bundle: Bundle

    // MARK: - Private Properties
    private let defaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    private init() {
        // Load saved language or detect system language
        let savedCode = defaults.string(forKey: AppConfiguration.UserDefaultsKeys.selectedLanguage)
        let systemCode = Locale.current.language.languageCode?.identifier ?? "en"
        let code = savedCode ?? systemCode

        // Find matching language or default to English
        let language = AppLanguage.allCases.first { $0.rawValue == code || code.hasPrefix($0.rawValue) } ?? .english
        self.currentLanguage = language
        self.bundle = Self.loadBundle(for: language)
    }

    // MARK: - Bundle Loading
    private static func loadBundle(for language: AppLanguage) -> Bundle {
        guard let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            // Fallback to main bundle
            return Bundle.main
        }
        return bundle
    }

    // MARK: - Language Switching
    func setLanguage(_ language: AppLanguage) {
        guard language != currentLanguage else { return }

        // Update current language
        currentLanguage = language
        bundle = Self.loadBundle(for: language)

        // Persist selection
        defaults.set(language.rawValue, forKey: AppConfiguration.UserDefaultsKeys.selectedLanguage)
        defaults.set([language.rawValue], forKey: "AppleLanguages")
        defaults.synchronize()

        // Notify observers
        objectWillChange.send()

        print("🌐 Language changed to: \(language.displayName)")
    }

    // MARK: - Localized String Retrieval
    func localizedString(_ key: String, comment: String = "") -> String {
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }

    func localizedString(_ key: String, arguments: CVarArg...) -> String {
        let format = localizedString(key)
        return String(format: format, arguments: arguments)
    }

    // MARK: - Convenience Accessors
    var locale: Locale {
        Locale(identifier: currentLanguage.rawValue)
    }

    var isRTL: Bool {
        // None of our supported languages are RTL
        return false
    }
}

// MARK: - SwiftUI Environment

private struct LocalizationManagerKey: EnvironmentKey {
    static let defaultValue = LocalizationManager.shared
}

extension EnvironmentValues {
    var localization: LocalizationManager {
        get { self[LocalizationManagerKey.self] }
        set { self[LocalizationManagerKey.self] = newValue }
    }
}

// MARK: - Localized String View Extension

extension String {
    /// Returns the localized version of this string using the current language
    var localized: String {
        return LocalizationManager.shared.localizedString(self)
    }

    /// Returns the localized version with format arguments
    func localized(_ args: CVarArg...) -> String {
        let format = LocalizationManager.shared.localizedString(self)
        return String(format: format, arguments: args)
    }
}

// MARK: - Text Extension for Dynamic Localization

extension Text {
    /// Creates a Text view with dynamic localization support
    init(localizedKey key: String) {
        self.init(LocalizationManager.shared.localizedString(key))
    }
}

// MARK: - View Modifier for Language Updates

struct LocalizationUpdater: ViewModifier {
    @ObservedObject var localizationManager = LocalizationManager.shared

    func body(content: Content) -> some View {
        content
            .environment(\.locale, localizationManager.locale)
            .id(localizationManager.currentLanguage) // Force view refresh on language change
    }
}

extension View {
    /// Applies dynamic localization updates to this view
    func withDynamicLocalization() -> some View {
        modifier(LocalizationUpdater())
    }
}
