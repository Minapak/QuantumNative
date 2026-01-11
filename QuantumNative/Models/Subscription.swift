//
//  Subscription.swift
//  QuantumNative
//
//  StoreKit 2 구독 상품 모델
//
//  Created by QuantumNative Team
//  Copyright © 2026 QuantumNative. All rights reserved.
//

import Foundation
import StoreKit

// MARK: - Subscription Tier
enum SubscriptionTier: String, CaseIterable {
    case pro = "pro"
    case premium = "premium"

    var displayName: String {
        switch self {
        case .pro:
            return String(localized: "subscription.tier.pro")
        case .premium:
            return String(localized: "subscription.tier.premium")
        }
    }
}

// MARK: - Subscription Product ID
enum SubscriptionProductID: String, CaseIterable {
    case proMonthly = "com.quantumnative.pro.monthly"
    case proYearly = "com.quantumnative.pro.yearly"
    case premiumMonthly = "com.quantumnative.premium.monthly"
    case premiumYearly = "com.quantumnative.premium.yearly"

    var displayName: String {
        switch self {
        case .proMonthly:
            return String(localized: "subscription.pro.monthly.name")
        case .premiumMonthly:
            return String(localized: "subscription.premium.monthly.name")
        case .proYearly:
            return String(localized: "subscription.pro.yearly.name")
        case .premiumYearly:
            return String(localized: "subscription.premium.yearly.name")
        }
    }

    var description: String {
        switch self {
        case .proMonthly:
            return String(localized: "subscription.pro.monthly.description")
        case .premiumMonthly:
            return String(localized: "subscription.premium.monthly.description")
        case .proYearly:
            return String(localized: "subscription.pro.yearly.description")
        case .premiumYearly:
            return String(localized: "subscription.premium.yearly.description")
        }
    }

    var tier: SubscriptionTier {
        switch self {
        case .proMonthly, .proYearly:
            return .pro
        case .premiumMonthly, .premiumYearly:
            return .premium
        }
    }

    var isYearly: Bool {
        switch self {
        case .proYearly, .premiumYearly:
            return true
        case .proMonthly, .premiumMonthly:
            return false
        }
    }

    var features: [String] {
        switch self {
        case .proMonthly, .proYearly:
            return [
                String(localized: "subscription.feature.allContent"),
                String(localized: "subscription.feature.noAds"),
                String(localized: "subscription.feature.offlineAccess")
            ]
        case .premiumMonthly, .premiumYearly:
            return [
                String(localized: "subscription.feature.allContent"),
                String(localized: "subscription.feature.noAds"),
                String(localized: "subscription.feature.offlineAccess"),
                String(localized: "subscription.feature.prioritySupport"),
                String(localized: "subscription.feature.earlyAccess"),
                String(localized: "subscription.feature.advancedAnalytics")
            ]
        }
    }

    var isBestValue: Bool {
        self == .premiumYearly
    }

    var sortOrder: Int {
        switch self {
        case .proMonthly: return 1
        case .proYearly: return 2
        case .premiumMonthly: return 3
        case .premiumYearly: return 4
        }
    }
}

// MARK: - Subscription Status
enum SubscriptionStatus: String, Codable {
    case free = "free"
    case premium = "premium"
    case expired = "expired"

    var isPremium: Bool {
        self == .premium
    }

    var displayName: String {
        switch self {
        case .free:
            return String(localized: "subscription.status.free")
        case .premium:
            return String(localized: "subscription.status.premium")
        case .expired:
            return String(localized: "subscription.status.expired")
        }
    }
}

// MARK: - Subscription Info
struct SubscriptionInfo: Codable, Equatable {
    var status: SubscriptionStatus
    var productId: String?
    var purchaseDate: Date?
    var expirationDate: Date?
    var originalTransactionId: String?
    var isAutoRenewEnabled: Bool

    init(
        status: SubscriptionStatus = .free,
        productId: String? = nil,
        purchaseDate: Date? = nil,
        expirationDate: Date? = nil,
        originalTransactionId: String? = nil,
        isAutoRenewEnabled: Bool = false
    ) {
        self.status = status
        self.productId = productId
        self.purchaseDate = purchaseDate
        self.expirationDate = expirationDate
        self.originalTransactionId = originalTransactionId
        self.isAutoRenewEnabled = isAutoRenewEnabled
    }

    var isActive: Bool {
        guard status == .premium else { return false }

        // 만료일이 없으면 유효한 구독으로 간주
        guard let expiration = expirationDate else {
            return true
        }

        return expiration > Date()
    }

    var daysRemaining: Int? {
        guard let expiration = expirationDate else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: expiration)
        return max(0, components.day ?? 0)
    }

    static let free = SubscriptionInfo()
}

// MARK: - Purchase Result
enum PurchaseResult {
    case success(Transaction)
    case pending
    case userCancelled
    case failed(Error)
}

// MARK: - StoreKit Error
enum StoreKitError: LocalizedError {
    case productNotFound
    case purchaseFailed
    case verificationFailed
    case networkError
    case unknown

    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return String(localized: "error.storekit.productNotFound")
        case .purchaseFailed:
            return String(localized: "error.storekit.purchaseFailed")
        case .verificationFailed:
            return String(localized: "error.storekit.verificationFailed")
        case .networkError:
            return String(localized: "error.storekit.networkError")
        case .unknown:
            return String(localized: "error.storekit.unknown")
        }
    }
}
