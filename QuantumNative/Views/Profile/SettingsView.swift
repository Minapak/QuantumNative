//
//  SettingsView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("enableNotifications") private var enableNotifications = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = true
    @AppStorage("hapticFeedback") private var hapticFeedback = true
    @AppStorage("soundEffects") private var soundEffects = true
    @AppStorage(OnboardingKeys.selectedLanguage) private var selectedLanguageCode: String = ""
    @AppStorage(OnboardingKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @Environment(\.dismiss) var dismiss
    @State private var showLanguagePicker = false
    @State private var showRestartAlert = false

    // Get current selected language using LocalizationManager
    @StateObject private var localizationManager = LocalizationManager.shared

    private var currentLanguage: AppLanguage {
        localizationManager.currentLanguage
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Language Settings
                        settingsSection(title: NSLocalizedString("settings.language", comment: "")) {
                            Button(action: { showLanguagePicker = true }) {
                                HStack {
                                    Image(systemName: "globe")
                                        .foregroundColor(.quantumCyan)
                                        .frame(width: 24)

                                    Text(NSLocalizedString("settings.language.current", comment: ""))
                                        .foregroundColor(.textPrimary)

                                    Spacer()

                                    HStack(spacing: 6) {
                                        Text(currentLanguage.flag)
                                        Text(currentLanguage.displayName)
                                            .foregroundColor(.textSecondary)
                                    }

                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.textTertiary)
                                }
                                .padding(.vertical, 4)
                            }
                        }

                        // Learning Preferences
                        settingsSection(title: "Learning") {
                            ToggleRow(
                                title: "Daily Reminders",
                                icon: "bell.fill",
                                isOn: $enableNotifications
                            )
                            
                            ToggleRow(
                                title: "Sound Effects",
                                icon: "speaker.wave.2.fill",
                                isOn: $soundEffects
                            )
                            
                            #if os(iOS)
                            ToggleRow(
                                title: "Haptic Feedback",
                                icon: "hand.tap.fill",
                                isOn: $hapticFeedback
                            )
                            #endif
                        }
                        
                        // Appearance
                        settingsSection(title: "Appearance") {
                            ToggleRow(
                                title: "Dark Mode",
                                icon: "moon.fill",
                                isOn: $darkModeEnabled
                            )
                        }
                        
                        // About
                        settingsSection(title: "About") {
                            InfoRow(
                                title: "Version",
                                icon: "info.circle.fill",
                                value: "1.0.0"
                            )
                            
                            LinkRow(
                                title: "Privacy Policy",
                                icon: "lock.fill",
                                url: URL(string: "https://swiftquantum.tech/legal/privacy-policy.html")!
                            )

                            LinkRow(
                                title: "Terms of Service",
                                icon: "doc.text.fill",
                                url: URL(string: "https://swiftquantum.tech/legal/terms-of-service.html")!
                            )
                        }
                        
                        // Account Actions
                        settingsSection(title: "Account") {
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "arrow.up.doc.fill")
                                        .foregroundColor(.quantumCyan)
                                    Text("Export Data")
                                        .foregroundColor(.textPrimary)
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }

                            Button(action: { showRestartAlert = true }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                        .foregroundColor(.quantumOrange)
                                    Text(NSLocalizedString("settings.restartTutorial", comment: ""))
                                        .foregroundColor(.quantumOrange)
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }

                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "trash.fill")
                                        .foregroundColor(.red)
                                    Text("Reset Progress")
                                        .foregroundColor(.red)
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showLanguagePicker) {
                LanguagePickerSheet(selectedLanguageCode: $selectedLanguageCode)
            }
            .alert(NSLocalizedString("settings.restartTutorial.title", comment: ""), isPresented: $showRestartAlert) {
                Button(NSLocalizedString("common.cancel", comment: ""), role: .cancel) {}
                Button(NSLocalizedString("common.confirm", comment: ""), role: .destructive) {
                    hasCompletedOnboarding = false
                    dismiss()
                }
            } message: {
                Text(NSLocalizedString("settings.restartTutorial.message", comment: ""))
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.quantumCyan)
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.quantumCyan)
                }
                #endif
            }
        }
    }
    
    private func settingsSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                content()
            }
            .padding(16)
            .background(Color.bgCard)
            .cornerRadius(12)
        }
    }
}

// MARK: - Toggle Row
struct ToggleRow: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.quantumCyan)
                .frame(width: 24)
            
            Text(title)
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.quantumCyan)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let title: String
    let icon: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.quantumCyan)
                .frame(width: 24)
            
            Text(title)
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.textSecondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Link Row
struct LinkRow: View {
    let title: String
    let icon: String
    let url: URL

    var body: some View {
        Link(destination: url) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.quantumCyan)
                    .frame(width: 24)

                Text(title)
                    .foregroundColor(.textPrimary)

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Language Picker Sheet
struct LanguagePickerSheet: View {
    @Binding var selectedLanguageCode: String
    @Environment(\.dismiss) var dismiss
    @StateObject private var localizationManager = LocalizationManager.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgDark.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 12) {
                        // Info banner
                        HStack(spacing: 12) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.quantumCyan)

                            Text(localizationManager.localizedString("settings.language.instant"))
                                .font(.system(size: 14))
                                .foregroundColor(.textSecondary)
                                .multilineTextAlignment(.leading)

                            Spacer()
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.quantumCyan.opacity(0.1))
                        )
                        .padding(.bottom, 8)

                        ForEach(AppLanguage.allCases) { language in
                            Button(action: {
                                QuantumTheme.Haptics.selection()
                                selectedLanguageCode = language.rawValue
                                localizationManager.setLanguage(language)
                                dismiss()
                            }) {
                                HStack(spacing: 16) {
                                    Text(language.flag)
                                        .font(.system(size: 32))

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(language.displayName)
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundColor(.white)

                                        Text(language.localizedName)
                                            .font(.system(size: 14))
                                            .foregroundColor(.textSecondary)
                                    }

                                    Spacer()

                                    if selectedLanguageCode == language.rawValue || localizationManager.currentLanguage == language {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.quantumCyan)
                                    }
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(localizationManager.currentLanguage == language ? Color.quantumCyan.opacity(0.15) : Color.bgCard)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(localizationManager.currentLanguage == language ? Color.quantumCyan : Color.white.opacity(0.1), lineWidth: 1)
                                        )
                                )
                            }
                            .scaleEffect(localizationManager.currentLanguage == language ? 1.02 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: localizationManager.currentLanguage)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(NSLocalizedString("settings.language.select", comment: ""))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("common.cancel", comment: "")) {
                        dismiss()
                    }
                    .foregroundColor(.quantumCyan)
                }
            }
        }
    }
}
