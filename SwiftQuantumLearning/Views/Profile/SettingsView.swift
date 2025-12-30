//
//  SettingsView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

// MARK: - Settings View
/// App settings and preferences
struct SettingsView: View {
    
    // MARK: - Properties
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @State private var settings = AppSettings()
    @State private var showResetAlert = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Section
                        profileSection
                        
                        // Preferences
                        preferencesSection
                        
                        // Learning Settings
                        learningSection
                        
                        // About
                        aboutSection
                        
                        // Danger Zone
                        dangerZone
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.quantumCyan)
                }
            }
            .alert("Reset Progress?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    progressViewModel.resetProgress()
                }
            } message: {
                Text("This will delete all your progress and cannot be undone.")
            }
        }
    }
    
    // MARK: - Sections
    
    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Profile")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                SettingRow(
                    icon: "person.fill",
                    title: "Name",
                    value: progressViewModel.userName
                )
                
                SettingRow(
                    icon: "envelope.fill",
                    title: "Email",
                    value: "user@example.com"
                )
            }
            .padding()
            .background(Color.bgCard)
            .cornerRadius(12)
        }
    }
    
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Preferences")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 0) {
                ToggleRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    isOn: $settings.notificationsEnabled
                )
                
                Divider().background(Color.white.opacity(0.1))
                
                ToggleRow(
                    icon: "speaker.wave.2.fill",
                    title: "Sound Effects",
                    isOn: $settings.soundEnabled
                )
                
                Divider().background(Color.white.opacity(0.1))
                
                ToggleRow(
                    icon: "iphone.radiowaves.left.and.right",
                    title: "Haptic Feedback",
                    isOn: $settings.hapticEnabled
                )
            }
            .padding()
            .background(Color.bgCard)
            .cornerRadius(12)
        }
    }
    
    private var learningSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Learning")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                SettingRow(
                    icon: "target",
                    title: "Daily Goal",
                    value: "50 XP"
                )
                
                SettingRow(
                    icon: "clock",
                    title: "Reminder",
                    value: "6:00 PM"
                )
            }
            .padding()
            .background(Color.bgCard)
            .cornerRadius(12)
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                SettingRow(
                    icon: "info.circle",
                    title: "Version",
                    value: "1.1.0"
                )
                
                NavigationLink(destination: Text("Terms")) {
                    SettingRow(
                        icon: "doc.text",
                        title: "Terms of Service",
                        showChevron: true
                    )
                }
                .buttonStyle(.plain)
                
                NavigationLink(destination: Text("Privacy")) {
                    SettingRow(
                        icon: "lock.shield",
                        title: "Privacy Policy",
                        showChevron: true
                    )
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color.bgCard)
            .cornerRadius(12)
        }
    }
    
    private var dangerZone: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Danger Zone")
                .font(.headline)
                .foregroundColor(.red)
            
            Button(action: { showResetAlert = true }) {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                    Text("Reset All Progress")
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Setting Row
struct SettingRow: View {
    let icon: String
    let title: String
    var value: String? = nil
    var showChevron: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.quantumCyan)
                .frame(width: 24)
            
            Text(title)
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            if let value = value {
                Text(value)
                    .foregroundColor(.textSecondary)
            }
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
            }
        }
    }
}

// MARK: - Toggle Row
struct ToggleRow: View {
    let icon: String
    let title: String
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
                .tint(.quantumCyan)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
        .environmentObject(ProgressViewModel.sample)
}