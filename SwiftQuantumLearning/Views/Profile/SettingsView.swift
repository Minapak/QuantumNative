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
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
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
                                url: URL(string: "https://example.com/privacy")!
                            )
                            
                            LinkRow(
                                title: "Terms of Service",
                                icon: "doc.text.fill",
                                url: URL(string: "https://example.com/terms")!
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
