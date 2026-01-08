//
//  OnboardingView.swift
//  SwiftQuantum Learning App
//
//  First-time user onboarding flow:
//  1. Welcome
//  2. Language Selection
//  3. User Type Selection (personalization)
//  4. Quick Tutorial (how to use the app)
//  5. Ready to start!
//
//  Created by SwiftQuantum Team
//  Copyright © 2026 SwiftQuantum. All rights reserved.
//

import SwiftUI

// MARK: - Onboarding Keys
enum OnboardingKeys {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let selectedUserType = "selectedUserType"
    static let selectedLanguage = "selectedLanguage"
}

// MARK: - Language Model
struct AppLanguage: Identifiable, Equatable {
    let id: String
    let code: String
    let name: String
    let nativeName: String
    let flag: String

    static let supported: [AppLanguage] = [
        AppLanguage(id: "en", code: "en", name: "English", nativeName: "English", flag: "🇺🇸"),
        AppLanguage(id: "ko", code: "ko", name: "Korean", nativeName: "한국어", flag: "🇰🇷"),
        AppLanguage(id: "ja", code: "ja", name: "Japanese", nativeName: "日本語", flag: "🇯🇵"),
        AppLanguage(id: "zh-Hans", code: "zh-Hans", name: "Chinese", nativeName: "简体中文", flag: "🇨🇳"),
        AppLanguage(id: "de", code: "de", name: "German", nativeName: "Deutsch", flag: "🇩🇪")
    ]
}

// MARK: - User Type Model
struct UserType: Identifiable, Equatable {
    let id: String
    let icon: String
    let titleKey: String
    let descKey: String
    let gradient: [Color]

    static let types: [UserType] = [
        UserType(id: "student", icon: "graduationcap.fill", titleKey: "userType.student", descKey: "userType.student.desc", gradient: [.quantumCyan, .blue]),
        UserType(id: "developer", icon: "chevron.left.forwardslash.chevron.right", titleKey: "userType.developer", descKey: "userType.developer.desc", gradient: [.quantumPurple, .purple]),
        UserType(id: "parent", icon: "figure.2.and.child.holdinghands", titleKey: "userType.parent", descKey: "userType.parent.desc", gradient: [.quantumOrange, .orange]),
        UserType(id: "sciFan", icon: "sparkles", titleKey: "userType.sciFan", descKey: "userType.sciFan.desc", gradient: [.pink, .quantumPurple]),
        UserType(id: "investor", icon: "chart.line.uptrend.xyaxis", titleKey: "userType.investor", descKey: "userType.investor.desc", gradient: [.quantumGreen, .green])
    ]
}

// MARK: - Onboarding View
struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentStep: OnboardingStep = .welcome
    @State private var selectedLanguage: AppLanguage? = nil
    @State private var selectedUserType: UserType? = nil

    enum OnboardingStep: Int, CaseIterable {
        case welcome = 0
        case language = 1
        case userType = 2
        case tutorial = 3
        case ready = 4
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color(hex: "0A0E27"), Color(hex: "16213E")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Floating particles
                FloatingParticlesView()

                VStack(spacing: 0) {
                    // Progress indicator (visible on steps 1-2 only, not tutorial/ready)
                    if currentStep == .language || currentStep == .userType {
                        OnboardingProgressView(currentStep: currentStep)
                            .padding(.top, geometry.safeAreaInsets.top + 16)
                            .padding(.horizontal, 40)
                    } else {
                        Spacer().frame(height: geometry.safeAreaInsets.top + 16)
                    }

                    // Content
                    TabView(selection: $currentStep) {
                        WelcomeStepView(onNext: { currentStep = .language })
                            .tag(OnboardingStep.welcome)

                        LanguageSelectionStepView(
                            selectedLanguage: $selectedLanguage,
                            onNext: { currentStep = .userType }
                        )
                        .tag(OnboardingStep.language)

                        UserTypeSelectionStepView(
                            selectedUserType: $selectedUserType,
                            onNext: { currentStep = .tutorial }
                        )
                        .tag(OnboardingStep.userType)

                        TutorialStepView(onNext: { currentStep = .ready })
                            .tag(OnboardingStep.tutorial)

                        ReadyStepView(
                            selectedUserType: selectedUserType,
                            onStart: { completeOnboarding() }
                        )
                        .tag(OnboardingStep.ready)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
            }
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
    }

    private func completeOnboarding() {
        if let language = selectedLanguage {
            UserDefaults.standard.set(language.code, forKey: OnboardingKeys.selectedLanguage)
            UserDefaults.standard.set([language.code], forKey: "AppleLanguages")
        }
        if let userType = selectedUserType {
            UserDefaults.standard.set(userType.id, forKey: OnboardingKeys.selectedUserType)
        }
        hasCompletedOnboarding = true
    }
}

// MARK: - Progress View
struct OnboardingProgressView: View {
    let currentStep: OnboardingView.OnboardingStep

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1..<4) { step in
                Capsule()
                    .fill(step <= currentStep.rawValue ? Color.quantumCyan : Color.white.opacity(0.2))
                    .frame(height: 4)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentStep)
    }
}

// MARK: - Floating Particles Background
struct FloatingParticlesView: View {
    @State private var animate = false

    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<15, id: \.self) { i in
                Circle()
                    .fill(
                        [Color.quantumCyan, Color.quantumPurple, Color.quantumOrange][i % 3]
                            .opacity(Double.random(in: 0.1...0.25))
                    )
                    .frame(width: CGFloat.random(in: 4...10))
                    .position(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: 0...geometry.size.height)
                    )
                    .offset(y: animate ? -15 : 15)
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 2.5...4))
                            .repeatForever(autoreverses: true)
                            .delay(Double.random(in: 0...2)),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
    }
}

// MARK: - Step 1: Welcome
struct WelcomeStepView: View {
    let onNext: () -> Void
    @State private var showContent = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top spacing
                Spacer()
                    .frame(height: geometry.size.height * 0.12)

                // Logo section - centered
                VStack(spacing: 28) {
                    // Logo with rings
                    ZStack {
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .stroke(
                                    Color.quantumCyan.opacity(0.25 - Double(i) * 0.08),
                                    lineWidth: 1.5
                                )
                                .frame(width: 120 + CGFloat(i) * 28, height: 120 + CGFloat(i) * 28)
                                .scaleEffect(showContent ? 1 : 0.6)
                                .opacity(showContent ? 1 : 0)
                                .animation(.easeOut(duration: 0.7).delay(Double(i) * 0.1), value: showContent)
                        }

                        Image(systemName: "atom")
                            .font(.system(size: 64, weight: .thin))
                            .foregroundStyle(
                                LinearGradient(colors: [.quantumCyan, .quantumPurple], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .scaleEffect(showContent ? 1 : 0.5)
                            .opacity(showContent ? 1 : 0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showContent)
                    }
                    .frame(height: 180)

                    // App name and tagline
                    VStack(spacing: 12) {
                        Text("SwiftQuantum")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)

                        Text("The Quantum Odyssey")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(colors: [.quantumCyan, .quantumPurple], startPoint: .leading, endPoint: .trailing)
                            )

                        Text("Harvard-MIT 2026 Research")
                            .font(.system(size: 13))
                            .foregroundColor(.textSecondary)
                            .padding(.top, 4)
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 16)
                    .animation(.easeOut(duration: 0.5).delay(0.25), value: showContent)
                }

                Spacer()

                // Start button
                Button(action: onNext) {
                    HStack(spacing: 10) {
                        Text("Get Started")
                            .font(.system(size: 17, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        LinearGradient(colors: [.quantumCyan, .quantumPurple], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(14)
                }
                .padding(.horizontal, 24)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)

                // Bottom safe area
                Spacer()
                    .frame(height: max(geometry.safeAreaInsets.bottom + 20, 40))
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                showContent = true
            }
        }
    }
}

// MARK: - Step 2: Language Selection
struct LanguageSelectionStepView: View {
    @Binding var selectedLanguage: AppLanguage?
    let onNext: () -> Void
    @State private var showContent = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 14) {
                    Image(systemName: "globe")
                        .font(.system(size: 44))
                        .foregroundStyle(
                            LinearGradient(colors: [.quantumCyan, .quantumPurple], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )

                    Text("Choose Your Language")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)

                    Text("Select your preferred language")
                        .font(.system(size: 15))
                        .foregroundColor(.textSecondary)
                }
                .padding(.top, 24)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 16)
                .animation(.easeOut(duration: 0.4), value: showContent)

                // Language grid
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                        ForEach(AppLanguage.supported) { language in
                            LanguageCard(
                                language: language,
                                isSelected: selectedLanguage == language,
                                onSelect: { selectedLanguage = language }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 24)
                .animation(.easeOut(duration: 0.4).delay(0.15), value: showContent)

                // Continue button
                Button(action: onNext) {
                    HStack(spacing: 10) {
                        Text("Continue")
                            .font(.system(size: 17, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(selectedLanguage != nil ? .white : .white.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        LinearGradient(
                            colors: selectedLanguage != nil ? [.quantumCyan, .quantumPurple] : [.gray.opacity(0.4), .gray.opacity(0.4)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                }
                .disabled(selectedLanguage == nil)
                .padding(.horizontal, 24)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.3), value: showContent)

                // Bottom safe area
                Spacer()
                    .frame(height: max(geometry.safeAreaInsets.bottom + 20, 40))
            }
        }
        .onAppear {
            if selectedLanguage == nil {
                let systemLang = Locale.current.language.languageCode?.identifier ?? "en"
                selectedLanguage = AppLanguage.supported.first { $0.code.hasPrefix(systemLang) } ?? AppLanguage.supported.first
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showContent = true
            }
        }
    }
}

struct LanguageCard: View {
    let language: AppLanguage
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: {
            QuantumTheme.Haptics.selection()
            onSelect()
        }) {
            VStack(spacing: 6) {
                Text(language.flag)
                    .font(.system(size: 36))

                Text(language.nativeName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)

                Text(language.name)
                    .font(.system(size: 12))
                    .foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.quantumCyan.opacity(0.2) : Color.bgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? Color.quantumCyan : Color.white.opacity(0.08), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Step 3: User Type Selection
struct UserTypeSelectionStepView: View {
    @Binding var selectedUserType: UserType?
    let onNext: () -> Void
    @State private var showContent = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.system(size: 44))
                        .foregroundStyle(
                            LinearGradient(colors: [.quantumPurple, .quantumOrange], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )

                    Text(NSLocalizedString("userType.title", comment: ""))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Text(NSLocalizedString("userType.subtitle", comment: ""))
                        .font(.system(size: 14))
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.4), value: showContent)

                // User type cards
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(UserType.types) { type in
                            UserTypeCard(
                                userType: type,
                                isSelected: selectedUserType == type,
                                onSelect: { selectedUserType = type }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 12)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 24)
                .animation(.easeOut(duration: 0.4).delay(0.15), value: showContent)

                // Continue button
                Button(action: onNext) {
                    HStack(spacing: 10) {
                        Text("Continue")
                            .font(.system(size: 17, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(selectedUserType != nil ? .white : .white.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        LinearGradient(
                            colors: selectedUserType != nil ? [.quantumCyan, .quantumPurple] : [.gray.opacity(0.4), .gray.opacity(0.4)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
                }
                .disabled(selectedUserType == nil)
                .padding(.horizontal, 24)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.3), value: showContent)

                // Bottom safe area
                Spacer()
                    .frame(height: max(geometry.safeAreaInsets.bottom + 20, 40))
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showContent = true
            }
        }
    }
}

struct UserTypeCard: View {
    let userType: UserType
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: {
            QuantumTheme.Haptics.selection()
            onSelect()
        }) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(colors: userType.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 46, height: 46)

                    Image(systemName: userType.icon)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(NSLocalizedString(userType.titleKey, comment: ""))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    Text(NSLocalizedString(userType.descKey, comment: ""))
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.quantumCyan)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.quantumCyan.opacity(0.15) : Color.bgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? Color.quantumCyan : Color.white.opacity(0.08), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .scaleEffect(isSelected ? 1.01 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Step 4: Tutorial
struct TutorialStepView: View {
    let onNext: () -> Void
    @State private var currentPage = 0
    @State private var showContent = false

    let tutorials: [TutorialPage] = [
        TutorialPage(
            icon: "building.columns.fill",
            iconColors: [.quantumCyan, .blue],
            title: "Campus Hub",
            subtitle: "Your Learning Journey",
            description: "Progress through 13 levels of quantum mastery. Each level unlocks new concepts.",
            tip: "Tap any level card to begin!"
        ),
        TutorialPage(
            icon: "flask.fill",
            iconColors: [.quantumPurple, .purple],
            title: "Laboratory",
            subtitle: "Hands-On Practice",
            description: "Build quantum circuits and watch the Bloch sphere respond in real-time.",
            tip: "Try the Hadamard gate first!"
        ),
        TutorialPage(
            icon: "network",
            iconColors: [.quantumOrange, .orange],
            title: "Bridge Terminal",
            subtitle: "Real Quantum Hardware",
            description: "Connect to IBM's real quantum computers and deploy your circuits.",
            tip: "Premium feature - upgrade to access!"
        ),
        TutorialPage(
            icon: "chart.bar.doc.horizontal.fill",
            iconColors: [.quantumGreen, .green],
            title: "Portfolio",
            subtitle: "Track Your Progress",
            description: "Build your portfolio with certificates. Perfect for career advancement.",
            tip: "Share achievements on LinkedIn!"
        )
    ]

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Tutorial pages
                TabView(selection: $currentPage) {
                    ForEach(Array(tutorials.enumerated()), id: \.offset) { index, tutorial in
                        TutorialPageView(tutorial: tutorial, geometry: geometry)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<tutorials.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.quantumCyan : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentPage ? 1.2 : 1.0)
                    }
                }
                .animation(.spring(response: 0.3), value: currentPage)
                .padding(.bottom, 20)

                // Buttons
                HStack(spacing: 16) {
                    if currentPage > 0 {
                        Button(action: {
                            withAnimation { currentPage -= 1 }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 14))
                                Text("Back")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .foregroundColor(.textSecondary)
                        }
                    } else {
                        Spacer()
                    }

                    Spacer()

                    Button(action: {
                        if currentPage < tutorials.count - 1 {
                            withAnimation { currentPage += 1 }
                        } else {
                            onNext()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Text(currentPage < tutorials.count - 1 ? "Next" : "Let's Go!")
                                .font(.system(size: 17, weight: .semibold))
                            Image(systemName: currentPage < tutorials.count - 1 ? "arrow.right" : "sparkles")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .frame(height: 50)
                        .background(
                            LinearGradient(colors: [.quantumCyan, .quantumPurple], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 24)

                // Bottom safe area
                Spacer()
                    .frame(height: max(geometry.safeAreaInsets.bottom + 20, 40))
            }
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showContent = true
            }
        }
    }
}

struct TutorialPage: Identifiable {
    let id = UUID()
    let icon: String
    let iconColors: [Color]
    let title: String
    let subtitle: String
    let description: String
    let tip: String
}

struct TutorialPageView: View {
    let tutorial: TutorialPage
    let geometry: GeometryProxy

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // Icon with glow
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: tutorial.iconColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 88, height: 88)
                    .shadow(color: tutorial.iconColors[0].opacity(0.4), radius: 16)

                Image(systemName: tutorial.icon)
                    .font(.system(size: 38))
                    .foregroundColor(.white)
            }

            // Title
            VStack(spacing: 6) {
                Text(tutorial.title)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)

                Text(tutorial.subtitle)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(colors: tutorial.iconColors, startPoint: .leading, endPoint: .trailing)
                    )
            }

            // Description
            Text(tutorial.description)
                .font(.system(size: 15))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, 28)

            // Tip box
            HStack(spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.quantumOrange)

                Text(tutorial.tip)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.quantumOrange.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.quantumOrange.opacity(0.25), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 28)

            Spacer()
            Spacer()
        }
    }
}

// MARK: - Step 5: Ready
struct ReadyStepView: View {
    let selectedUserType: UserType?
    let onStart: () -> Void
    @State private var showContent = false
    @State private var pulseAnimation = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()

                // Success animation
                ZStack {
                    // Pulse rings
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .stroke(Color.quantumGreen.opacity(0.25 - Double(i) * 0.08), lineWidth: 2)
                            .frame(width: 100 + CGFloat(i) * 36, height: 100 + CGFloat(i) * 36)
                            .scaleEffect(pulseAnimation ? 1.08 : 1.0)
                            .opacity(pulseAnimation ? 0.5 : 1.0)
                            .animation(
                                Animation.easeInOut(duration: 1.4)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(i) * 0.2),
                                value: pulseAnimation
                            )
                    }

                    // Checkmark
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(colors: [.quantumGreen, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .frame(width: 88, height: 88)

                        Image(systemName: "checkmark")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(showContent ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showContent)
                }
                .frame(height: 180)

                // Message
                VStack(spacing: 14) {
                    Text("You're All Set!")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)

                    if let userType = selectedUserType {
                        Text("Personalized for \(NSLocalizedString(userType.titleKey, comment: ""))")
                            .font(.system(size: 15))
                            .foregroundColor(.textSecondary)
                    }

                    Text("Your quantum journey begins now")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(colors: [.quantumCyan, .quantumPurple], startPoint: .leading, endPoint: .trailing)
                        )
                        .padding(.top, 6)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 16)
                .animation(.easeOut(duration: 0.5).delay(0.25), value: showContent)

                Spacer()

                // Start button
                Button(action: {
                    QuantumTheme.Haptics.success()
                    onStart()
                }) {
                    HStack(spacing: 10) {
                        Text("Start Learning")
                            .font(.system(size: 18, weight: .bold))
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 20))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(colors: [.quantumCyan, .quantumPurple], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(16)
                    .shadow(color: .quantumCyan.opacity(0.35), radius: 16, y: 8)
                }
                .padding(.horizontal, 24)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)

                // Bottom safe area
                Spacer()
                    .frame(height: max(geometry.safeAreaInsets.bottom + 20, 40))
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showContent = true
                pulseAnimation = true
            }
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var hasCompleted = false
    OnboardingView(hasCompletedOnboarding: $hasCompleted)
}
