//
//  PaywallView.swift
//  SwiftQuantum Learning App
//
//  구독 결제 화면 (Paywall)
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI
import StoreKit

// MARK: - Paywall View
struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storeKitService = StoreKitService.shared

    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccessAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: QuantumSpacing.lg) {
                    // Header
                    headerSection

                    // Features
                    featuresSection

                    // Products
                    productsSection

                    // Purchase Button
                    purchaseButton

                    // Restore & Terms
                    footerSection
                }
                .padding(.horizontal, QuantumSpacing.md)
                .padding(.bottom, QuantumSpacing.xxl)
            }
            .quantumBackground()
            .navigationTitle(String(localized: "paywall.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .alert(String(localized: "common.error"), isPresented: $showError) {
                Button(String(localized: "common.close"), role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .alert(String(localized: "paywall.success.title"), isPresented: $showSuccessAlert) {
                Button(String(localized: "common.done")) {
                    dismiss()
                }
            } message: {
                Text(String(localized: "paywall.success.message"))
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: QuantumSpacing.md) {
            // Premium Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.quantumCyan.opacity(0.3), .quantumPurple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: "crown.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.quantumCyan, .quantumPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .quantumGlow(color: .quantumCyan, radius: 12)

            Text(String(localized: "paywall.header.title"))
                .font(QuantumTextStyle.title())
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)

            Text(String(localized: "paywall.header.subtitle"))
                .font(QuantumTextStyle.body())
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, QuantumSpacing.lg)
    }

    // MARK: - Features Section
    private var featuresSection: some View {
        VStack(spacing: QuantumSpacing.sm) {
            ForEach(premiumFeatures, id: \.title) { feature in
                HStack(spacing: QuantumSpacing.md) {
                    Image(systemName: feature.icon)
                        .font(.system(size: 20))
                        .foregroundColor(.quantumCyan)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(feature.title)
                            .font(QuantumTextStyle.body())
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)

                        Text(feature.description)
                            .font(QuantumTextStyle.caption())
                            .foregroundColor(.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.completed)
                }
                .padding(QuantumSpacing.md)
                .background(Color.bgCard)
                .cornerRadius(QuantumSpacing.CornerRadius.md)
            }
        }
    }

    // MARK: - Products Section
    private var productsSection: some View {
        VStack(spacing: QuantumSpacing.sm) {
            if storeKitService.isLoading && storeKitService.products.isEmpty {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .quantumCyan))
                    .frame(height: 200)
            } else if storeKitService.products.isEmpty {
                Text(String(localized: "paywall.noProducts"))
                    .font(QuantumTextStyle.body())
                    .foregroundColor(.textSecondary)
                    .frame(height: 200)
            } else {
                ForEach(storeKitService.products, id: \.id) { product in
                    ProductCard(
                        product: product,
                        isSelected: selectedProduct?.id == product.id,
                        isBestValue: SubscriptionProductID(rawValue: product.id)?.isBestValue ?? false
                    ) {
                        withAnimation(QuantumTheme.Animation.standard) {
                            selectedProduct = product
                        }
                        QuantumTheme.Haptics.selection()
                    }
                }
            }
        }
        .onAppear {
            // 기본 선택: Best Value 또는 첫 번째 상품
            if selectedProduct == nil {
                selectedProduct = storeKitService.products.first { product in
                    SubscriptionProductID(rawValue: product.id)?.isBestValue ?? false
                } ?? storeKitService.products.first
            }
        }
    }

    // MARK: - Purchase Button
    private var purchaseButton: some View {
        Button {
            purchaseSelectedProduct()
        } label: {
            HStack {
                if isPurchasing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(width: 20, height: 20)
                } else {
                    Text(String(localized: "paywall.subscribe"))
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.quantumPrimary)
        .disabled(selectedProduct == nil || isPurchasing)
        .padding(.top, QuantumSpacing.md)
    }

    // MARK: - Footer Section
    private var footerSection: some View {
        VStack(spacing: QuantumSpacing.md) {
            // Restore Purchases
            Button {
                restorePurchases()
            } label: {
                Text(String(localized: "paywall.restore"))
                    .font(QuantumTextStyle.caption())
                    .foregroundColor(.quantumCyan)
            }

            // Terms & Privacy
            HStack(spacing: QuantumSpacing.lg) {
                Link(String(localized: "paywall.terms"), destination: URL(string: "https://swiftquantum.com/terms")!)
                    .font(QuantumTextStyle.small())
                    .foregroundColor(.textSecondary)

                Link(String(localized: "paywall.privacy"), destination: URL(string: "https://swiftquantum.com/privacy")!)
                    .font(QuantumTextStyle.small())
                    .foregroundColor(.textSecondary)
            }

            // Auto-Renewal Notice
            Text(String(localized: "paywall.autoRenewal"))
                .font(QuantumTextStyle.small())
                .foregroundColor(.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, QuantumSpacing.md)
        }
        .padding(.top, QuantumSpacing.md)
    }

    // MARK: - Premium Features Data
    private var premiumFeatures: [PremiumFeature] {
        [
            PremiumFeature(
                icon: "book.fill",
                title: String(localized: "paywall.feature.allContent.title"),
                description: String(localized: "paywall.feature.allContent.description")
            ),
            PremiumFeature(
                icon: "arrow.down.circle.fill",
                title: String(localized: "paywall.feature.offline.title"),
                description: String(localized: "paywall.feature.offline.description")
            ),
            PremiumFeature(
                icon: "xmark.circle.fill",
                title: String(localized: "paywall.feature.noAds.title"),
                description: String(localized: "paywall.feature.noAds.description")
            ),
            PremiumFeature(
                icon: "person.fill.questionmark",
                title: String(localized: "paywall.feature.support.title"),
                description: String(localized: "paywall.feature.support.description")
            )
        ]
    }

    // MARK: - Actions
    private func purchaseSelectedProduct() {
        guard let product = selectedProduct else { return }

        isPurchasing = true
        QuantumTheme.Haptics.medium()

        Task {
            let result = await storeKitService.purchase(product)

            await MainActor.run {
                isPurchasing = false

                switch result {
                case .success:
                    QuantumTheme.Haptics.success()
                    showSuccessAlert = true
                case .userCancelled:
                    break
                case .pending:
                    errorMessage = String(localized: "paywall.pending")
                    showError = true
                case .failed(let error):
                    QuantumTheme.Haptics.error()
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    private func restorePurchases() {
        QuantumTheme.Haptics.light()

        Task {
            await storeKitService.restorePurchases()

            await MainActor.run {
                if storeKitService.isPremium {
                    QuantumTheme.Haptics.success()
                    showSuccessAlert = true
                } else if let error = storeKitService.errorMessage {
                    errorMessage = error
                    showError = true
                }
            }
        }
    }
}

// MARK: - Premium Feature Model
struct PremiumFeature {
    let icon: String
    let title: String
    let description: String
}

// MARK: - Product Card View
struct ProductCard: View {
    let product: Product
    let isSelected: Bool
    let isBestValue: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: QuantumSpacing.md) {
                // Selection Indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.quantumCyan : Color.textTertiary, lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(Color.quantumCyan)
                            .frame(width: 14, height: 14)
                    }
                }

                // Product Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(SubscriptionProductID(rawValue: product.id)?.displayName ?? product.displayName)
                            .font(QuantumTextStyle.body())
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)

                        if isBestValue {
                            Text(String(localized: "paywall.bestValue"))
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color.quantumOrange)
                                )
                        }
                    }

                    Text(product.subscriptionPeriodDisplay)
                        .font(QuantumTextStyle.caption())
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                // Price
                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.displayPrice)
                        .font(QuantumTextStyle.headline())
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)

                    if product.subscription != nil {
                        Text(String(localized: "paywall.perPeriod \(product.subscriptionPeriodDisplay)"))
                            .font(QuantumTextStyle.small())
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .padding(QuantumSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: QuantumSpacing.CornerRadius.md)
                    .fill(Color.bgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: QuantumSpacing.CornerRadius.md)
                            .stroke(
                                isSelected ? Color.quantumCyan : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    PaywallView()
}
