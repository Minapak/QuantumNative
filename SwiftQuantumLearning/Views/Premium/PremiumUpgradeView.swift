//
//  PremiumUpgradeView.swift
//  SwiftQuantumLearning
//
//  2026년 마케팅 트렌드 기반 프리미엄 업그레이드 뷰
//  Agentic AI 추천 시스템 + 심리학적 수익화 기법
//
//  Created by SwiftQuantum Team
//  Copyright © 2026 SwiftQuantum. All rights reserved.
//

import SwiftUI

// MARK: - Subscription Plan
struct SubscriptionPlan: Identifiable {
    let id: String
    let tier: PlanTier
    let name: String
    let monthlyPrice: Double
    let yearlyPrice: Double
    let features: [String]
    let highlight: String?
    let isRecommended: Bool
    let savingsPercentage: Int

    enum PlanTier: String {
        case basic = "Basic"
        case pro = "Pro"
        case enterprise = "Enterprise"

        var color: Color {
            switch self {
            case .basic: return .gray
            case .pro: return .quantumCyan
            case .enterprise: return .quantumOrange
            }
        }

        var gradientColors: [Color] {
            switch self {
            case .basic: return [.gray.opacity(0.6), .gray]
            case .pro: return [.quantumCyan, .quantumPurple]
            case .enterprise: return [Color(hex: "FFD700"), Color(hex: "FF8C00")]  // Gold-Orange Miami Sun
            }
        }
    }
}

// MARK: - Premium Upgrade View
struct PremiumUpgradeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @StateObject private var bridgeService = QuantumBridgeService.shared

    @State private var selectedPlan: SubscriptionPlan?
    @State private var isYearly = true
    @State private var showConfirmation = false
    @State private var isLoading = false
    @State private var showAIRecommendation = true
    @State private var animateRecommendation = false

    // AI 추천 메시지 (사용자 진도 기반)
    private var aiRecommendationMessage: String {
        let progress = progressViewModel.levelProgress
        if progress > 0.7 {
            return "You're 87% through advanced content! Bridge integration will boost your algorithm efficiency by 150%."
        } else if progress > 0.4 {
            return "Your learning pace is excellent! Pro tier unlocks Harvard-MIT continuous operation mode."
        } else {
            return "Start your quantum journey with Pro to access 3,000-qubit simulation capabilities."
        }
    }

    private let plans: [SubscriptionPlan] = [
        SubscriptionPlan(
            id: "basic",
            tier: .basic,
            name: "Basic",
            monthlyPrice: 0,
            yearlyPrice: 0,
            features: [
                "Basic quantum simulation (8 qubits)",
                "Beginner learning tracks",
                "Community forum access"
            ],
            highlight: nil,
            isRecommended: false,
            savingsPercentage: 0
        ),
        SubscriptionPlan(
            id: "pro",
            tier: .pro,
            name: "Pro",
            monthlyPrice: 9.99,
            yearlyPrice: 71.88,
            features: [
                "Harvard-MIT continuous operation mode",
                "Up to 64 qubits simulation",
                "Advanced courses (Bell State, Grover, Simon)",
                "QuantumBridge hybrid computing",
                "Real-time noise visualization",
                "100 Bridge credits/month",
                "Priority support"
            ],
            highlight: "MOST POPULAR",
            isRecommended: true,
            savingsPercentage: 40
        ),
        SubscriptionPlan(
            id: "enterprise",
            tier: .enterprise,
            name: "Enterprise",
            monthlyPrice: 29.99,
            yearlyPrice: 215.88,
            features: [
                "Everything in Pro",
                "Fault-tolerant architecture (96+ logical qubits)",
                "Up to 256 qubits simulation",
                "IBM Quantum integration lessons",
                "Unlimited error correction layers",
                "1,000 Bridge credits/month",
                "Direct QuantumBridge cloud deployment",
                "Custom curriculum support",
                "Dedicated account manager"
            ],
            highlight: "BEST VALUE",
            isRecommended: false,
            savingsPercentage: 40
        )
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    // AI Recommendation Banner (Agentic AI)
                    if showAIRecommendation {
                        aiRecommendationBanner
                    }

                    // Loss Aversion Message
                    lossAversionBanner

                    // Billing Toggle
                    billingToggle

                    // Plans
                    plansSection

                    // Trust Indicators
                    trustIndicators

                    // Harvard-MIT Research Badge
                    researchBadge
                }
                .padding()
            }
            .background(Color.bgDark.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.quantumCyan)
                }
            }
        }
        .onAppear {
            selectedPlan = plans.first { $0.isRecommended }
            withAnimation(.spring().delay(0.5)) {
                animateRecommendation = true
            }
        }
        .sheet(isPresented: $showConfirmation) {
            if let plan = selectedPlan {
                PurchaseConfirmationView(plan: plan, isYearly: isYearly)
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "atom")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.quantumCyan, .quantumPurple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .symbolEffect(.pulse)

            Text("Unlock Quantum Power")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)

            Text("Experience the Harvard-MIT 3,000 qubit architecture")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top)
    }

    // MARK: - AI Recommendation Banner (Agentic AI 트렌드)
    private var aiRecommendationBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.title2)
                .foregroundColor(.quantumCyan)
                .symbolEffect(.bounce, value: animateRecommendation)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("AI Recommendation")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.quantumCyan)

                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }

                Text(aiRecommendationMessage)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .lineLimit(2)
            }

            Spacer()

            Button {
                showAIRecommendation = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.textSecondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.quantumCyan.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.quantumCyan.opacity(0.3), lineWidth: 1)
                )
        )
        .scaleEffect(animateRecommendation ? 1 : 0.95)
        .opacity(animateRecommendation ? 1 : 0.8)
    }

    // MARK: - Loss Aversion Banner (손실 회피 심리)
    private var lossAversionBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.shield.fill")
                .font(.title2)
                .foregroundColor(.yellow)

            VStack(alignment: .leading, spacing: 2) {
                Text("Don't Miss the Quantum Advantage Era")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text("Transfer your fault-tolerant algorithms to Bridge now, or risk falling behind in post-quantum security standards.")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.yellow.opacity(0.1))
        )
    }

    // MARK: - Billing Toggle
    private var billingToggle: some View {
        HStack(spacing: 16) {
            Text("Monthly")
                .foregroundColor(isYearly ? .textSecondary : .white)
                .fontWeight(isYearly ? .regular : .semibold)

            Toggle("", isOn: $isYearly)
                .toggleStyle(SwitchToggleStyle(tint: .quantumCyan))
                .labelsHidden()

            HStack(spacing: 4) {
                Text("Yearly")
                    .foregroundColor(isYearly ? .white : .textSecondary)
                    .fontWeight(isYearly ? .semibold : .regular)

                // Anchoring: 40% 절감 강조
                if isYearly {
                    Text("SAVE 40%")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.green)
                        )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.bgCard)
        )
    }

    // MARK: - Plans Section
    private var plansSection: some View {
        VStack(spacing: 16) {
            ForEach(plans) { plan in
                PlanCard(
                    plan: plan,
                    isSelected: selectedPlan?.id == plan.id,
                    isYearly: isYearly,
                    onSelect: {
                        withAnimation(.spring()) {
                            selectedPlan = plan
                        }
                        QuantumTheme.Haptics.selection()
                    },
                    onSubscribe: {
                        selectedPlan = plan
                        showConfirmation = true
                    }
                )
            }
        }
    }

    // MARK: - Trust Indicators
    private var trustIndicators: some View {
        HStack(spacing: 24) {
            TrustBadge(icon: "lock.shield.fill", text: "Secure Payment")
            TrustBadge(icon: "arrow.triangle.2.circlepath", text: "Cancel Anytime")
            TrustBadge(icon: "checkmark.seal.fill", text: "7-Day Trial")
        }
        .padding(.vertical)
    }

    // MARK: - Research Badge
    private var researchBadge: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "graduationcap.fill")
                    .foregroundColor(.quantumPurple)
                Text("Based on Harvard-MIT Research")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }

            Text("3,000 qubit continuous operation architecture (Nature, Jan 2026)")
                .font(.caption2)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.quantumPurple.opacity(0.1))
        )
    }
}

// MARK: - Plan Card
struct PlanCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let isYearly: Bool
    let onSelect: () -> Void
    let onSubscribe: () -> Void

    private var displayPrice: Double {
        isYearly ? plan.yearlyPrice / 12 : plan.monthlyPrice
    }

    private var totalPrice: Double {
        isYearly ? plan.yearlyPrice : plan.monthlyPrice
    }

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let highlight = plan.highlight {
                        Text(highlight)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(plan.tier == .pro ? Color.quantumCyan : Color(hex: "FFD700"))
                            )
                    }

                    Text(plan.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }

                Spacer()

                // Price
                if plan.monthlyPrice > 0 {
                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("$")
                                .font(.subheadline)
                            Text(String(format: "%.2f", displayPrice))
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)

                        Text("/month")
                            .font(.caption)
                            .foregroundColor(.textSecondary)

                        if isYearly {
                            Text("$\(String(format: "%.2f", totalPrice))/year")
                                .font(.caption2)
                                .foregroundColor(.textTertiary)
                        }
                    }
                } else {
                    Text("Free")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }

            Divider()
                .background(Color.white.opacity(0.1))

            // Features
            VStack(alignment: .leading, spacing: 8) {
                ForEach(plan.features, id: \.self) { feature in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(plan.tier.color)

                        Text(feature)
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                    }
                }
            }

            // Subscribe Button
            if plan.monthlyPrice > 0 {
                Button {
                    onSubscribe()
                } label: {
                    Text(plan.tier == .enterprise ? "Start Free Trial" : "Subscribe Now")
                        .font(.headline)
                        .foregroundColor(plan.tier == .enterprise ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: plan.tier.gradientColors,
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isSelected ? plan.tier.color : Color.clear,
                            lineWidth: 2
                        )
                )
        )
        .onTapGesture {
            onSelect()
        }
    }
}

// MARK: - Trust Badge
struct TrustBadge: View {
    let icon: String
    let text: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.textSecondary)
            Text(text)
                .font(.caption2)
                .foregroundColor(.textSecondary)
        }
    }
}

// MARK: - Purchase Confirmation View
struct PurchaseConfirmationView: View {
    @Environment(\.dismiss) private var dismiss
    let plan: SubscriptionPlan
    let isYearly: Bool

    @State private var isProcessing = false
    @State private var purchaseComplete = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                if purchaseComplete {
                    // Success State
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)

                        Text("Welcome to \(plan.name)!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("Your quantum journey begins now.")
                            .foregroundColor(.textSecondary)

                        Button("Get Started") {
                            dismiss()
                        }
                        .buttonStyle(.quantumPrimary)
                        .padding(.top)
                    }
                } else {
                    // Confirmation
                    VStack(spacing: 16) {
                        Text("Confirm Purchase")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        VStack(spacing: 8) {
                            Text(plan.name)
                                .font(.headline)
                                .foregroundColor(.white)

                            if isYearly {
                                Text("$\(String(format: "%.2f", plan.yearlyPrice))/year")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.quantumCyan)
                            } else {
                                Text("$\(String(format: "%.2f", plan.monthlyPrice))/month")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.quantumCyan)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.bgCard)
                        .cornerRadius(12)

                        Text("7-day free trial, cancel anytime")
                            .font(.caption)
                            .foregroundColor(.textSecondary)

                        Spacer()

                        Button {
                            processPayment()
                        } label: {
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Confirm & Subscribe")
                            }
                        }
                        .buttonStyle(.quantumPrimary)
                        .disabled(isProcessing)
                    }
                }
            }
            .padding()
            .background(Color.bgDark.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.textSecondary)
                }
            }
        }
    }

    private func processPayment() {
        isProcessing = true

        // Simulate payment processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isProcessing = false
            purchaseComplete = true
            QuantumTheme.Haptics.success()
        }
    }
}

// MARK: - Preview
#Preview {
    PremiumUpgradeView()
        .environmentObject(ProgressViewModel())
}
