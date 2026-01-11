//
//  SubscriptionManager.swift
//  SwiftQuantum Learning App
//
//  구독 상태 로컬 저장소 관리
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import Foundation

// MARK: - Subscription Manager
class SubscriptionManager {

    // MARK: - Singleton
    static let shared = SubscriptionManager()

    // MARK: - Keys
    private enum Keys {
        static let subscriptionInfo = "subscription_info"
        static let lastVerificationDate = "subscription_last_verification"
        static let freeTrialUsed = "free_trial_used"
        static let freeContentViewCount = "free_content_view_count"
    }

    // MARK: - Private Properties
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Free Content Limits
    private let maxFreeContentViews = 3  // 무료 사용자 하루 콘텐츠 제한

    // MARK: - Initialization
    private init() {
        print("✅ SubscriptionManager initialized")
    }

    // MARK: - Subscription Info Management

    /// 구독 정보 저장
    func saveSubscriptionInfo(_ info: SubscriptionInfo) {
        do {
            let data = try encoder.encode(info)
            defaults.set(data, forKey: Keys.subscriptionInfo)
            defaults.set(Date(), forKey: Keys.lastVerificationDate)
            defaults.synchronize()
            print("✅ Subscription info saved: \(info.status.rawValue)")
        } catch {
            print("❌ Failed to save subscription info: \(error)")
        }
    }

    /// 구독 정보 로드
    func loadSubscriptionInfo() -> SubscriptionInfo {
        guard let data = defaults.data(forKey: Keys.subscriptionInfo) else {
            return .free
        }

        do {
            let info = try decoder.decode(SubscriptionInfo.self, from: data)

            // 만료된 구독 체크
            if let expiration = info.expirationDate, expiration < Date() {
                let expiredInfo = SubscriptionInfo(
                    status: .expired,
                    productId: info.productId,
                    purchaseDate: info.purchaseDate,
                    expirationDate: info.expirationDate,
                    originalTransactionId: info.originalTransactionId,
                    isAutoRenewEnabled: false
                )
                saveSubscriptionInfo(expiredInfo)
                return expiredInfo
            }

            return info
        } catch {
            print("❌ Failed to load subscription info: \(error)")
            return .free
        }
    }

    /// 구독 정보 초기화 (로그아웃 시)
    func clearSubscriptionInfo() {
        defaults.removeObject(forKey: Keys.subscriptionInfo)
        defaults.removeObject(forKey: Keys.lastVerificationDate)
        defaults.synchronize()
        print("✅ Subscription info cleared")
    }

    // MARK: - Free Trial Management

    /// 무료 체험 사용 여부
    var hasFreeTrialBeenUsed: Bool {
        defaults.bool(forKey: Keys.freeTrialUsed)
    }

    /// 무료 체험 사용 표시
    func markFreeTrialAsUsed() {
        defaults.set(true, forKey: Keys.freeTrialUsed)
        defaults.synchronize()
    }

    // MARK: - Free Content View Management

    /// 오늘 본 무료 콘텐츠 수 가져오기
    func getFreeContentViewCount() -> Int {
        let data = defaults.dictionary(forKey: Keys.freeContentViewCount) as? [String: Int] ?? [:]
        let today = todayKey()
        return data[today] ?? 0
    }

    /// 무료 콘텐츠 조회 증가
    func incrementFreeContentViewCount() {
        var data = defaults.dictionary(forKey: Keys.freeContentViewCount) as? [String: Int] ?? [:]
        let today = todayKey()

        // 이전 날짜 데이터 정리 (7일 이상 된 것)
        let calendar = Calendar.current
        data = data.filter { key, _ in
            if let date = dateFromKey(key) {
                return calendar.dateComponents([.day], from: date, to: Date()).day ?? 8 < 7
            }
            return false
        }

        data[today] = (data[today] ?? 0) + 1
        defaults.set(data, forKey: Keys.freeContentViewCount)
        defaults.synchronize()
    }

    /// 오늘 더 볼 수 있는 무료 콘텐츠가 있는지
    func canViewFreeContent() -> Bool {
        getFreeContentViewCount() < maxFreeContentViews
    }

    /// 남은 무료 콘텐츠 조회 횟수
    func remainingFreeContentViews() -> Int {
        max(0, maxFreeContentViews - getFreeContentViewCount())
    }

    // MARK: - Verification

    /// 마지막 검증 날짜
    var lastVerificationDate: Date? {
        defaults.object(forKey: Keys.lastVerificationDate) as? Date
    }

    /// 검증이 필요한지 확인 (24시간 마다)
    var needsVerification: Bool {
        guard let lastDate = lastVerificationDate else { return true }
        let hoursSinceLastVerification = Calendar.current.dateComponents(
            [.hour],
            from: lastDate,
            to: Date()
        ).hour ?? 25
        return hoursSinceLastVerification >= 24
    }

    // MARK: - Premium Status

    /// 현재 프리미엄 상태인지
    var isPremium: Bool {
        loadSubscriptionInfo().isActive
    }

    /// 구독 상태
    var subscriptionStatus: SubscriptionStatus {
        loadSubscriptionInfo().status
    }

    // MARK: - Private Helpers

    private func todayKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private func dateFromKey(_ key: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: key)
    }
}

// MARK: - Content Access Control
extension SubscriptionManager {

    /// 콘텐츠 접근 가능 여부 확인
    /// - Parameter contentId: 콘텐츠 ID (트랙 번호 또는 레벨 ID)
    /// - Returns: 접근 가능 여부
    func canAccessContent(contentId: Int) -> Bool {
        // 프리미엄 사용자는 모든 콘텐츠 접근 가능
        if isPremium {
            return true
        }

        // 무료 사용자: 처음 2개 트랙만 접근 가능
        // 트랙 ID가 100 단위로 구분된다고 가정 (101, 102 = Track 1, 201, 202 = Track 2)
        let trackNumber = contentId / 100
        if trackNumber <= 2 {
            return true
        }

        // 또는 하루 제한 내에서 접근
        return canViewFreeContent()
    }

    /// 프리미엄 트랙인지 확인
    func isPremiumContent(trackIndex: Int) -> Bool {
        // 처음 2개 트랙(인덱스 0, 1)은 무료
        return trackIndex >= 2
    }

    /// 프리미엄 레벨인지 확인
    func isPremiumLevel(levelId: Int) -> Bool {
        let trackNumber = levelId / 100
        return trackNumber > 2
    }
}
