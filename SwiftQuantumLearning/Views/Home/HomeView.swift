//
//  HomeView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @EnvironmentObject var learningViewModel: LearnViewModel
    @EnvironmentObject var achievementViewModel: AchievementViewModel
    @StateObject private var storeKitService = StoreKitService.shared
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgDark.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        headerSection

                        // 프리미엄 배너 (무료 사용자만)
                        if !storeKitService.isPremium {
                            premiumBanner
                        }

                        progressCard
                        subscriptionStatusCard
                        recentAchievements
                    }
                    .padding()
                }
            }
            .navigationTitle("Home")
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Welcome back!")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)

                Text(progressViewModel.userName)
                    .font(.title2.bold())
                    .foregroundColor(.textPrimary)
            }

            Spacer()

            // 프리미엄 배지
            if storeKitService.isPremium {
                HStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                        .font(.caption)
                    Text("PRO")
                        .font(.caption.bold())
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(LinearGradient(
                            colors: [.quantumOrange, .quantumPurple],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var premiumBanner: some View {
        Button(action: { showPaywall = true }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.quantumCyan.opacity(0.2), .quantumPurple.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)

                    Image(systemName: "crown.fill")
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.quantumOrange, .quantumPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "premium.upgrade"))
                        .font(.headline)
                        .foregroundColor(.textPrimary)

                    Text(String(localized: "paywall.header.subtitle"))
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.quantumCyan)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.bgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [.quantumCyan.opacity(0.5), .quantumPurple.opacity(0.5)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var progressCard: some View {
        VStack(spacing: 16) {
            Text("Level \(progressViewModel.userLevel)")
                .font(.headline)
                .foregroundColor(.quantumCyan)

            Text("\(progressViewModel.totalXP) XP")
                .font(.title2.bold())
                .foregroundColor(.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }

    private var subscriptionStatusCard: some View {
        Group {
            if storeKitService.isPremium {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.completed)
                        Text(String(localized: "subscription.status.premium"))
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                    }

                    if let daysRemaining = storeKitService.subscriptionInfo.daysRemaining {
                        Text(String(localized: "subscription.daysRemaining \(daysRemaining)"))
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.bgCard)
                .cornerRadius(12)
            } else {
                // 무료 사용자: 남은 무료 조회 횟수
                let remaining = SubscriptionManager.shared.remainingFreeContentViews()
                if remaining < 3 {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.quantumYellow)
                        Text(String(localized: "premium.freeRemaining \(remaining)"))
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.bgCard)
                    .cornerRadius(12)
                }
            }
        }
    }

    private var recentAchievements: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Achievements")
                .font(.headline)
                .foregroundColor(.textPrimary)

            if achievementViewModel.achievements.isEmpty {
                Text("Start learning to earn achievements!")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
