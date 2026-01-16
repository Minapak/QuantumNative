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
// Now using LocalizationManager.AppLanguage instead
typealias OnboardingLanguage = AppLanguage

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
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var currentStep: OnboardingStep = .language
    @State private var selectedLanguageEnum: AppLanguage? = nil
    @State private var selectedUserType: UserType? = nil
    @State private var languageRefreshKey = UUID()

    enum OnboardingStep: Int, CaseIterable {
        case language = 0
        case welcome = 1
        case userType = 2
        case tutorial = 3
        case ready = 4
    }

    // Computed locale for real-time language change
    private var currentLocale: Locale {
        localizationManager.locale
    }

    var body: some View {
        ZStack {
            // Background - Deep space with quantum energy colors
            LinearGradient(
                colors: [
                    Color(red: 0.03, green: 0.03, blue: 0.08),
                    Color(red: 0.08, green: 0.04, blue: 0.15),
                    Color(red: 0.05, green: 0.02, blue: 0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Floating particles
            FloatingParticlesView()
                .ignoresSafeArea()

            // Main content respects safe area
            VStack(spacing: 0) {
                // Progress indicator (visible on steps 1-2 only, not tutorial/ready)
                if currentStep == .welcome || currentStep == .userType {
                    OnboardingProgressView(currentStep: currentStep)
                        .padding(.top, 16)
                        .padding(.horizontal, 40)
                }

                // Content
                TabView(selection: $currentStep) {
                    LanguageSelectionStepView(
                        selectedLanguage: $selectedLanguageEnum,
                        localizationManager: localizationManager,
                        onNext: {
                            languageRefreshKey = UUID()
                            currentStep = .welcome
                        }
                    )
                    .tag(OnboardingStep.language)

                    WelcomeStepView(onNext: { currentStep = .userType })
                        .tag(OnboardingStep.welcome)
                        .id(languageRefreshKey)

                    UserTypeSelectionStepView(
                        selectedUserType: $selectedUserType,
                        onNext: { currentStep = .tutorial }
                    )
                    .tag(OnboardingStep.userType)
                    .id(languageRefreshKey)

                    TutorialStepView(onNext: { currentStep = .ready })
                        .tag(OnboardingStep.tutorial)
                        .id(languageRefreshKey)

                    ReadyStepView(
                        selectedUserType: selectedUserType,
                        onStart: { completeOnboarding() }
                    )
                    .tag(OnboardingStep.ready)
                    .id(languageRefreshKey)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
        .environment(\.locale, currentLocale)
        .preferredColorScheme(.dark)
    }

    private func completeOnboarding() {
        // Language is already set via LocalizationManager during selection
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
                    .fill(step < currentStep.rawValue ? Color.quantumCyan : Color.white.opacity(0.2))
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

// MARK: - Step 2: Welcome (after language selection)
struct WelcomeStepView: View {
    let onNext: () -> Void
    @State private var showContent = false
    @State private var rotationAngle: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Logo section - centered
            VStack(spacing: 28) {
                // App Logo with orbital rings
                ZStack {
                    // Outer glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.quantumPurple.opacity(0.3),
                                    Color.quantumOrange.opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 60,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                        .blur(radius: 20)
                        .scaleEffect(showContent ? 1 : 0.5)
                        .opacity(showContent ? 1 : 0)

                    // Orbital rings
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.quantumPurple.opacity(0.4 - Double(i) * 0.1),
                                        Color.quantumOrange.opacity(0.3 - Double(i) * 0.08),
                                        Color.quantumCyan.opacity(0.2 - Double(i) * 0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                            .frame(width: 140 + CGFloat(i) * 30, height: 140 + CGFloat(i) * 30)
                            .rotationEffect(.degrees(rotationAngle + Double(i) * 30))
                            .scaleEffect(showContent ? 1 : 0.6)
                            .opacity(showContent ? 1 : 0)
                            .animation(.easeOut(duration: 0.7).delay(Double(i) * 0.1), value: showContent)
                    }

                    // App Logo Image
                    Image("AppLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .shadow(color: Color.quantumPurple.opacity(0.5), radius: 20, x: 0, y: 0)
                        .shadow(color: Color.quantumOrange.opacity(0.3), radius: 30, x: 0, y: 10)
                        .scaleEffect(showContent ? 1 : 0.5)
                        .opacity(showContent ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showContent)
                }
                .frame(height: 200)

                // App name and tagline
                VStack(spacing: 12) {
                    Text("QuantumNative")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.9)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    Text(NSLocalizedString("onboarding.welcome.subtitle", comment: ""))
                        .font(.system(size: 14))
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 16)
                .animation(.easeOut(duration: 0.5).delay(0.25), value: showContent)
            }

            Spacer()

            // Start button
            Button(action: onNext) {
                HStack(spacing: 10) {
                    Text(NSLocalizedString("onboarding.welcome.button", comment: ""))
                        .font(.system(size: 17, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        colors: [.quantumOrange, .quantumPurple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(14)
                .shadow(color: Color.quantumOrange.opacity(0.4), radius: 12, x: 0, y: 6)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
            .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                showContent = true
            }
            // Start subtle rotation animation
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
}

// MARK: - Step 1: Language Selection (First screen)
struct LanguageSelectionStepView: View {
    @Binding var selectedLanguage: AppLanguage?
    @ObservedObject var localizationManager: LocalizationManager
    let onNext: () -> Void
    @State private var showContent = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 40)

            // App Logo at top
            VStack(spacing: 16) {
                Image("AppLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: Color.quantumPurple.opacity(0.4), radius: 12, x: 0, y: 4)

                Text("QuantumNative")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            .opacity(showContent ? 1 : 0)
            .scaleEffect(showContent ? 1 : 0.9)
            .animation(.easeOut(duration: 0.4), value: showContent)

            // Header
            VStack(spacing: 10) {
                Image(systemName: "globe")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(colors: [.quantumOrange, .quantumPurple], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )

                Text("Choose Your Language")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                Text("Select your preferred language\nto personalize your experience")
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 24)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 16)
            .animation(.easeOut(duration: 0.4).delay(0.1), value: showContent)

            // Language grid
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                    ForEach(AppLanguage.allCases) { language in
                        LanguageCardNew(
                            language: language,
                            isSelected: selectedLanguage == language,
                            onSelect: {
                                selectedLanguage = language
                                // Apply language immediately via LocalizationManager
                                localizationManager.setLanguage(language)
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
            }
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 24)
            .animation(.easeOut(duration: 0.4).delay(0.2), value: showContent)

            // Continue button
            Button(action: onNext) {
                HStack(spacing: 10) {
                    Text(localizationManager.localizedString("common.continue"))
                        .font(.system(size: 17, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(selectedLanguage != nil ? .white : .white.opacity(0.5))
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        colors: selectedLanguage != nil ? [.quantumOrange, .quantumPurple] : [.gray.opacity(0.4), .gray.opacity(0.4)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(14)
                .shadow(color: selectedLanguage != nil ? Color.quantumOrange.opacity(0.3) : Color.clear, radius: 10, x: 0, y: 5)
            }
            .disabled(selectedLanguage == nil)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .opacity(showContent ? 1 : 0)
            .animation(.easeOut(duration: 0.4).delay(0.3), value: showContent)
        }
        .onAppear {
            if selectedLanguage == nil {
                // Set default language based on LocalizationManager's current selection
                selectedLanguage = localizationManager.currentLanguage
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showContent = true
            }
        }
    }
}

struct LanguageCardNew: View {
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

                Text(language.displayName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)

                Text(language.localizedName)
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
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "person.crop.circle.badge.questionmark")
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(colors: [.quantumPurple, .quantumOrange], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )

                Text(NSLocalizedString("onboarding.userType.title", comment: ""))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                Text(NSLocalizedString("onboarding.userType.subtitle", comment: ""))
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
                    Text(NSLocalizedString("common.continue", comment: ""))
                        .font(.system(size: 17, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(selectedUserType != nil ? .white : .white.opacity(0.5))
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        colors: selectedUserType != nil ? [.quantumOrange, .quantumPurple] : [.gray.opacity(0.4), .gray.opacity(0.4)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(14)
                .shadow(color: selectedUserType != nil ? Color.quantumOrange.opacity(0.3) : Color.clear, radius: 10, x: 0, y: 5)
            }
            .disabled(selectedUserType == nil)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .opacity(showContent ? 1 : 0)
            .animation(.easeOut(duration: 0.4).delay(0.3), value: showContent)
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

    var tutorials: [TutorialPage] {
        [
            TutorialPage(
                icon: "building.columns.fill",
                iconColors: [.quantumCyan, .blue],
                titleKey: "onboarding.tutorial.campus.title",
                subtitleKey: "onboarding.tutorial.campus.subtitle",
                descriptionKey: "onboarding.tutorial.campus.description",
                tipKey: "onboarding.tutorial.campus.tip"
            ),
            TutorialPage(
                icon: "flask.fill",
                iconColors: [.quantumPurple, .purple],
                titleKey: "onboarding.tutorial.lab.title",
                subtitleKey: "onboarding.tutorial.lab.subtitle",
                descriptionKey: "onboarding.tutorial.lab.description",
                tipKey: "onboarding.tutorial.lab.tip"
            ),
            TutorialPage(
                icon: "network",
                iconColors: [.quantumOrange, .orange],
                titleKey: "onboarding.tutorial.bridge.title",
                subtitleKey: "onboarding.tutorial.bridge.subtitle",
                descriptionKey: "onboarding.tutorial.bridge.description",
                tipKey: "onboarding.tutorial.bridge.tip"
            ),
            TutorialPage(
                icon: "chart.bar.doc.horizontal.fill",
                iconColors: [.quantumGreen, .green],
                titleKey: "onboarding.tutorial.portfolio.title",
                subtitleKey: "onboarding.tutorial.portfolio.subtitle",
                descriptionKey: "onboarding.tutorial.portfolio.description",
                tipKey: "onboarding.tutorial.portfolio.tip"
            )
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            // Tutorial pages
            TabView(selection: $currentPage) {
                ForEach(Array(tutorials.enumerated()), id: \.offset) { index, tutorial in
                    TutorialPageView(tutorial: tutorial)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Page indicators
            HStack(spacing: 8) {
                ForEach(0..<tutorials.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color.quantumOrange : Color.white.opacity(0.3))
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
                            Text(NSLocalizedString("common.back", comment: ""))
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
                        Text(currentPage < tutorials.count - 1 ? NSLocalizedString("common.next", comment: "") : NSLocalizedString("onboarding.tutorial.letsgo", comment: ""))
                            .font(.system(size: 17, weight: .semibold))
                        Image(systemName: currentPage < tutorials.count - 1 ? "arrow.right" : "sparkles")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .frame(height: 50)
                    .background(
                        LinearGradient(colors: [.quantumOrange, .quantumPurple], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(12)
                    .shadow(color: Color.quantumOrange.opacity(0.3), radius: 10, x: 0, y: 5)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .opacity(showContent ? 1 : 0)
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
    let titleKey: String
    let subtitleKey: String
    let descriptionKey: String
    let tipKey: String

    var title: String { NSLocalizedString(titleKey, comment: "") }
    var subtitle: String { NSLocalizedString(subtitleKey, comment: "") }
    var description: String { NSLocalizedString(descriptionKey, comment: "") }
    var tip: String { NSLocalizedString(tipKey, comment: "") }
}

struct TutorialPageView: View {
    let tutorial: TutorialPage

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
        VStack(spacing: 0) {
            Spacer()

            // Success animation
            ZStack {
                // Pulse rings with gradient colors
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.quantumGreen.opacity(0.3 - Double(i) * 0.08),
                                    Color.quantumCyan.opacity(0.2 - Double(i) * 0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
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
                            LinearGradient(colors: [.quantumGreen, .quantumCyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 88, height: 88)
                        .shadow(color: Color.quantumGreen.opacity(0.4), radius: 16, x: 0, y: 0)

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
                Text(NSLocalizedString("onboarding.ready.title", comment: ""))
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)

                if let userType = selectedUserType {
                    Text(String(format: NSLocalizedString("onboarding.ready.personalized", comment: ""), NSLocalizedString(userType.titleKey, comment: "")))
                        .font(.system(size: 15))
                        .foregroundColor(.textSecondary)
                }

                Text(NSLocalizedString("onboarding.ready.subtitle", comment: ""))
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(colors: [.quantumOrange, .quantumPurple], startPoint: .leading, endPoint: .trailing)
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
                    Text(NSLocalizedString("onboarding.ready.button", comment: ""))
                        .font(.system(size: 18, weight: .bold))
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 20))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(colors: [.quantumOrange, .quantumPurple], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(16)
                .shadow(color: .quantumOrange.opacity(0.4), radius: 16, y: 8)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
            .animation(.easeOut(duration: 0.5).delay(0.4), value: showContent)
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
