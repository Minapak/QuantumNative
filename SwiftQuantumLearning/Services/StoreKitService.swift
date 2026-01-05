//
//  StoreKitService.swift
//  SwiftQuantum Learning App
//
//  StoreKit 2 결제 서비스 - App Store 통신 및 구독 관리
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import Foundation
import StoreKit
import Combine

// MARK: - StoreKit Service
@MainActor
class StoreKitService: ObservableObject {

    // MARK: - Singleton
    static let shared = StoreKitService()

    // MARK: - Published Properties
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var subscriptionInfo: SubscriptionInfo = .free
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    // MARK: - Private Properties
    private var updateListenerTask: Task<Void, Error>?
    private let subscriptionManager = SubscriptionManager.shared

    // MARK: - Initialization
    private init() {
        // Transaction listener 시작
        updateListenerTask = listenForTransactions()

        // 저장된 구독 정보 로드
        subscriptionInfo = subscriptionManager.loadSubscriptionInfo()

        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Public Methods

    /// 상품 목록 로드
    func loadProducts() async {
        isLoading = true
        errorMessage = nil

        do {
            let productIDs = SubscriptionProductID.allCases.map { $0.rawValue }
            let storeProducts = try await Product.products(for: productIDs)

            // 정렬된 상품 목록
            products = storeProducts.sorted { product1, product2 in
                let order1 = SubscriptionProductID(rawValue: product1.id)?.sortOrder ?? 0
                let order2 = SubscriptionProductID(rawValue: product2.id)?.sortOrder ?? 0
                return order1 < order2
            }

            isLoading = false
            print("✅ Loaded \(products.count) products")
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            print("❌ Failed to load products: \(error)")
        }
    }

    /// 상품 구매
    func purchase(_ product: Product) async -> PurchaseResult {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                // 트랜잭션 검증
                let transaction = try checkVerified(verification)

                // 구독 정보 업데이트
                await updateSubscriptionStatus()

                // 트랜잭션 완료 처리
                await transaction.finish()

                isLoading = false
                print("✅ Purchase successful: \(product.id)")
                return .success(transaction)

            case .userCancelled:
                isLoading = false
                print("⚠️ User cancelled purchase")
                return .userCancelled

            case .pending:
                isLoading = false
                print("⏳ Purchase pending")
                return .pending

            @unknown default:
                isLoading = false
                return .failed(StoreKitError.unknown)
            }
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            print("❌ Purchase failed: \(error)")
            return .failed(error)
        }
    }

    /// 구매 복원
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil

        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
            isLoading = false
            print("✅ Purchases restored")
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            print("❌ Failed to restore purchases: \(error)")
        }
    }

    /// 구독 상태 업데이트
    func updateSubscriptionStatus() async {
        var newSubscriptionInfo = SubscriptionInfo.free

        // 현재 유효한 구독 확인
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)

                // 구독 상품인지 확인
                if let productID = SubscriptionProductID(rawValue: transaction.productID) {
                    purchasedProductIDs.insert(transaction.productID)

                    newSubscriptionInfo = SubscriptionInfo(
                        status: .premium,
                        productId: transaction.productID,
                        purchaseDate: transaction.purchaseDate,
                        expirationDate: transaction.expirationDate,
                        originalTransactionId: String(transaction.originalID),
                        isAutoRenewEnabled: await checkAutoRenewStatus(for: transaction)
                    )

                    print("✅ Active subscription: \(productID.displayName)")
                }
            } catch {
                print("❌ Transaction verification failed: \(error)")
            }
        }

        // 구독 정보 저장 및 업데이트
        subscriptionInfo = newSubscriptionInfo
        subscriptionManager.saveSubscriptionInfo(newSubscriptionInfo)
    }

    /// 프리미엄 여부 확인
    var isPremium: Bool {
        subscriptionInfo.isActive
    }

    /// 특정 상품 가격 가져오기
    func price(for productID: SubscriptionProductID) -> String? {
        products.first { $0.id == productID.rawValue }?.displayPrice
    }

    /// 특정 상품 가져오기
    func product(for productID: SubscriptionProductID) -> Product? {
        products.first { $0.id == productID.rawValue }
    }

    // MARK: - Private Methods

    /// 트랜잭션 리스너
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)

                    // 메인 스레드에서 상태 업데이트
                    await MainActor.run {
                        Task {
                            await self.updateSubscriptionStatus()
                        }
                    }

                    await transaction.finish()
                } catch {
                    print("❌ Transaction listener error: \(error)")
                }
            }
        }
    }

    /// 트랜잭션 검증
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }

    /// 자동 갱신 상태 확인
    private func checkAutoRenewStatus(for transaction: Transaction) async -> Bool {
        guard let product = products.first(where: { $0.id == transaction.productID }),
              let subscription = product.subscription else {
            return false
        }

        do {
            let statuses = try await subscription.status
            for status in statuses {
                if case .verified(let renewalInfo) = status.renewalInfo {
                    return renewalInfo.willAutoRenew
                }
            }
        } catch {
            print("❌ Failed to check auto-renew status: \(error)")
        }

        return false
    }
}

// MARK: - Product Extension
extension Product {
    /// 월간 가격으로 환산
    var monthlyPrice: Decimal? {
        guard let subscription = self.subscription else { return nil }

        let unit = subscription.subscriptionPeriod.unit
        let value = subscription.subscriptionPeriod.value

        switch unit {
        case .month:
            return price / Decimal(value)
        case .year:
            return price / Decimal(value * 12)
        case .week:
            return price * Decimal(4) / Decimal(value)
        case .day:
            return price * Decimal(30) / Decimal(value)
        @unknown default:
            return price
        }
    }

    /// 월간 가격 표시 문자열
    var monthlyPriceDisplay: String {
        guard let monthlyPrice = monthlyPrice else { return displayPrice }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceFormatStyle.locale

        return formatter.string(from: monthlyPrice as NSDecimalNumber) ?? displayPrice
    }

    /// 구독 기간 표시
    var subscriptionPeriodDisplay: String {
        guard let subscription = self.subscription else { return "" }

        let unit = subscription.subscriptionPeriod.unit
        let value = subscription.subscriptionPeriod.value

        switch unit {
        case .day:
            return value == 1 ? String(localized: "subscription.period.day") : String(localized: "subscription.period.days \(value)")
        case .week:
            return value == 1 ? String(localized: "subscription.period.week") : String(localized: "subscription.period.weeks \(value)")
        case .month:
            return value == 1 ? String(localized: "subscription.period.month") : String(localized: "subscription.period.months \(value)")
        case .year:
            return value == 1 ? String(localized: "subscription.period.year") : String(localized: "subscription.period.years \(value)")
        @unknown default:
            return ""
        }
    }
}
