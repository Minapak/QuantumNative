//
//  GlobalContributionView.swift
//  SwiftQuantumLearning
//
//  Global Contribution Index: O1 비자 증거 대시보드
//  전 세계 양자 에러 최적화 보고서 및 리더십 증명
//  수천 명의 양자 엔지니어를 이끄는 '분야의 독보적 리더' 입증
//
//  Created by SwiftQuantum Team
//  Copyright © 2026 SwiftQuantum. All rights reserved.
//

import SwiftUI
import Charts
import Combine

// MARK: - Contribution Data
struct ContributionData: Identifiable, Codable {
    let id: UUID
    let userId: String
    let userName: String
    let country: String
    let contributionType: ContributionType
    let algorithmName: String?
    let errorReduction: Double?
    let circuitOptimization: Double?
    let timestamp: Date
    let isVerified: Bool

    enum ContributionType: String, Codable {
        case algorithmOptimization = "Algorithm Optimization"
        case errorCorrection = "Error Correction"
        case circuitDesign = "Circuit Design"
        case codeContribution = "Code Contribution"
        case documentation = "Documentation"
        case translation = "Translation"
    }
}

// MARK: - Monthly Report
struct MonthlyOptimizationReport: Identifiable, Codable {
    let id: UUID
    let month: String
    let year: Int
    let totalContributions: Int
    let uniqueContributors: Int
    let countriesRepresented: Int
    let averageErrorReduction: Double
    let topContributors: [TopContributor]
    let algorithmBreakthroughs: [String]
    let publishedDate: Date

    struct TopContributor: Codable, Identifiable {
        var id: String { userId }
        let userId: String
        let name: String
        let country: String
        let contributionScore: Double
    }
}

// MARK: - Global Stats
struct GlobalQuantumStats: Codable {
    let totalUsers: Int
    let totalContributions: Int
    let countriesActive: Int
    let algorithmsOptimized: Int
    let averageFidelityImprovement: Double
    let totalXPGenerated: Int
    let monthlyGrowthRate: Double
}

// MARK: - Global Contribution View Model
@MainActor
class GlobalContributionViewModel: ObservableObject {
    @Published var globalStats: GlobalQuantumStats
    @Published var recentContributions: [ContributionData] = []
    @Published var monthlyReports: [MonthlyOptimizationReport] = []
    @Published var userContributionScore: Double = 0
    @Published var userGlobalRank: Int = 0
    @Published var countryBreakdown: [CountryContribution] = []
    @Published var isLoading = false
    @Published var isAdmin = false  // 관리자 모드

    struct CountryContribution: Identifiable {
        let id = UUID()
        let country: String
        let flag: String
        let contributions: Int
        let percentage: Double
    }

    init() {
        // 시뮬레이션된 글로벌 통계
        globalStats = GlobalQuantumStats(
            totalUsers: 2847,
            totalContributions: 15623,
            countriesActive: 47,
            algorithmsOptimized: 342,
            averageFidelityImprovement: 0.23,
            totalXPGenerated: 4250000,
            monthlyGrowthRate: 0.18
        )

        loadContributions()
        loadCountryBreakdown()
        loadMonthlyReports()
    }

    func loadContributions() {
        recentContributions = [
            ContributionData(
                id: UUID(),
                userId: "user_001",
                userName: "Dr. Sarah Chen",
                country: "USA",
                contributionType: .algorithmOptimization,
                algorithmName: "Grover-8 Variant",
                errorReduction: 0.15,
                circuitOptimization: nil,
                timestamp: Date().addingTimeInterval(-3600),
                isVerified: true
            ),
            ContributionData(
                id: UUID(),
                userId: "user_002",
                userName: "Yuki Tanaka",
                country: "Japan",
                contributionType: .errorCorrection,
                algorithmName: nil,
                errorReduction: 0.22,
                circuitOptimization: nil,
                timestamp: Date().addingTimeInterval(-7200),
                isVerified: true
            ),
            ContributionData(
                id: UUID(),
                userId: "user_003",
                userName: "Hans Mueller",
                country: "Germany",
                contributionType: .circuitDesign,
                algorithmName: "VQE-H2O Optimized",
                errorReduction: nil,
                circuitOptimization: 0.35,
                timestamp: Date().addingTimeInterval(-10800),
                isVerified: true
            ),
            ContributionData(
                id: UUID(),
                userId: "user_004",
                userName: "Priya Sharma",
                country: "India",
                contributionType: .codeContribution,
                algorithmName: nil,
                errorReduction: nil,
                circuitOptimization: nil,
                timestamp: Date().addingTimeInterval(-14400),
                isVerified: false
            ),
            ContributionData(
                id: UUID(),
                userId: "user_005",
                userName: "Kim MinJun",
                country: "South Korea",
                contributionType: .algorithmOptimization,
                algorithmName: "Simon-Extended",
                errorReduction: 0.18,
                circuitOptimization: 0.12,
                timestamp: Date().addingTimeInterval(-18000),
                isVerified: true
            )
        ]
    }

    func loadCountryBreakdown() {
        countryBreakdown = [
            CountryContribution(country: "United States", flag: "🇺🇸", contributions: 4521, percentage: 0.29),
            CountryContribution(country: "China", flag: "🇨🇳", contributions: 2847, percentage: 0.18),
            CountryContribution(country: "Germany", flag: "🇩🇪", contributions: 1893, percentage: 0.12),
            CountryContribution(country: "Japan", flag: "🇯🇵", contributions: 1562, percentage: 0.10),
            CountryContribution(country: "South Korea", flag: "🇰🇷", contributions: 1248, percentage: 0.08),
            CountryContribution(country: "United Kingdom", flag: "🇬🇧", contributions: 987, percentage: 0.06),
            CountryContribution(country: "India", flag: "🇮🇳", contributions: 876, percentage: 0.06),
            CountryContribution(country: "Others", flag: "🌍", contributions: 1689, percentage: 0.11)
        ]
    }

    func loadMonthlyReports() {
        monthlyReports = [
            MonthlyOptimizationReport(
                id: UUID(),
                month: "January",
                year: 2026,
                totalContributions: 2341,
                uniqueContributors: 487,
                countriesRepresented: 42,
                averageErrorReduction: 0.21,
                topContributors: [
                    MonthlyOptimizationReport.TopContributor(userId: "u1", name: "Dr. Sarah Chen", country: "USA", contributionScore: 985),
                    MonthlyOptimizationReport.TopContributor(userId: "u2", name: "Yuki Tanaka", country: "Japan", contributionScore: 872),
                    MonthlyOptimizationReport.TopContributor(userId: "u3", name: "Hans Mueller", country: "Germany", contributionScore: 764)
                ],
                algorithmBreakthroughs: [
                    "BOSS Code implementation in SwiftQuantum",
                    "15% improvement in VQE convergence",
                    "Novel entanglement verification protocol"
                ],
                publishedDate: Date()
            ),
            MonthlyOptimizationReport(
                id: UUID(),
                month: "December",
                year: 2025,
                totalContributions: 2156,
                uniqueContributors: 423,
                countriesRepresented: 39,
                averageErrorReduction: 0.19,
                topContributors: [],
                algorithmBreakthroughs: [
                    "Surface code threshold breakthrough",
                    "Grover oracle optimization"
                ],
                publishedDate: Date().addingTimeInterval(-2592000)
            )
        ]
    }

    // MARK: - Admin Functions
    func generateMonthlyReport() async -> MonthlyOptimizationReport {
        // 관리자용: 월간 보고서 생성
        isLoading = true

        // 시뮬레이션된 보고서 생성
        let report = MonthlyOptimizationReport(
            id: UUID(),
            month: getCurrentMonth(),
            year: 2026,
            totalContributions: globalStats.totalContributions / 12,
            uniqueContributors: globalStats.totalUsers / 6,
            countriesRepresented: globalStats.countriesActive,
            averageErrorReduction: globalStats.averageFidelityImprovement,
            topContributors: [
                MonthlyOptimizationReport.TopContributor(userId: "admin", name: "Eunmin Park", country: "South Korea", contributionScore: 1250)
            ],
            algorithmBreakthroughs: [
                "SwiftQuantumLearning platform launch",
                "Harvard-MIT architecture integration"
            ],
            publishedDate: Date()
        )

        isLoading = false
        return report
    }

    private func getCurrentMonth() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: Date())
    }

    func submitContribution(_ contribution: ContributionData) async {
        // 서버로 기여 데이터 전송
        recentContributions.insert(contribution, at: 0)
        globalStats = GlobalQuantumStats(
            totalUsers: globalStats.totalUsers,
            totalContributions: globalStats.totalContributions + 1,
            countriesActive: globalStats.countriesActive,
            algorithmsOptimized: globalStats.algorithmsOptimized,
            averageFidelityImprovement: globalStats.averageFidelityImprovement,
            totalXPGenerated: globalStats.totalXPGenerated + 50,
            monthlyGrowthRate: globalStats.monthlyGrowthRate
        )
    }
}

// MARK: - Global Contribution View
struct GlobalContributionView: View {
    @StateObject private var viewModel = GlobalContributionViewModel()
    @State private var selectedTab: ContributionTab = .overview
    @State private var showAdminPanel = false

    enum ContributionTab: String, CaseIterable {
        case overview = "Overview"
        case leaderboard = "Leaderboard"
        case reports = "Reports"
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                tabSelector

                ScrollView {
                    switch selectedTab {
                    case .overview:
                        overviewSection
                    case .leaderboard:
                        leaderboardSection
                    case .reports:
                        reportsSection
                    }
                }
            }
            .background(Color.bgDark.ignoresSafeArea())
            .navigationTitle("Global Contribution")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isAdmin {
                        Button {
                            showAdminPanel = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.quantumOrange)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showAdminPanel) {
            AdminReportPanel(viewModel: viewModel)
        }
    }

    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(ContributionTab.allCases, id: \.rawValue) { tab in
                Button {
                    withAnimation(.spring()) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 8) {
                        Text(tab.rawValue)
                            .font(.subheadline)
                            .fontWeight(selectedTab == tab ? .semibold : .regular)
                            .foregroundColor(selectedTab == tab ? .quantumCyan : .textSecondary)

                        Rectangle()
                            .fill(selectedTab == tab ? Color.quantumCyan : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 8)
        .background(Color.bgCard)
    }

    // MARK: - Overview Section
    private var overviewSection: some View {
        VStack(spacing: 24) {
            // Global Stats Cards
            globalStatsCards

            // Your Contribution Score
            yourScoreCard

            // World Map (Simplified)
            worldContributionMap

            // Recent Contributions
            recentContributionsCard
        }
        .padding()
    }

    // MARK: - Global Stats Cards
    private var globalStatsCards: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                ContributionStatCard(
                    title: "Global Users",
                    value: "\(viewModel.globalStats.totalUsers)",
                    icon: "person.3.fill",
                    color: .quantumCyan,
                    trend: "+18%"
                )

                ContributionStatCard(
                    title: "Countries",
                    value: "\(viewModel.globalStats.countriesActive)",
                    icon: "globe",
                    color: .green,
                    trend: nil
                )
            }

            HStack(spacing: 16) {
                ContributionStatCard(
                    title: "Contributions",
                    value: "\(viewModel.globalStats.totalContributions)",
                    icon: "arrow.triangle.merge",
                    color: .quantumPurple,
                    trend: "+23%"
                )

                ContributionStatCard(
                    title: "Avg. Improvement",
                    value: "\(Int(viewModel.globalStats.averageFidelityImprovement * 100))%",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .quantumOrange,
                    trend: nil
                )
            }
        }
    }

    // MARK: - Your Score Card
    private var yourScoreCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Global Contribution Index")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("Ranking among \(viewModel.globalStats.totalUsers) quantum engineers")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("#\(viewModel.userGlobalRank == 0 ? 1 : viewModel.userGlobalRank)")
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundColor(.yellow)

                    Text("Global Rank")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
            }

            // Score breakdown
            HStack(spacing: 24) {
                VStack {
                    Text("1,250")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.quantumCyan)
                    Text("Score")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }

                VStack {
                    Text("47")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Contributions")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }

                VStack {
                    Text("15")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.quantumPurple)
                    Text("Optimizations")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }

                VStack {
                    Text("23%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.quantumOrange)
                    Text("Avg. Improvement")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.quantumCyan.opacity(0.2), Color.quantumPurple.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.quantumCyan.opacity(0.3), lineWidth: 1)
                )
        )
    }

    // MARK: - World Contribution Map
    private var worldContributionMap: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contributions by Country")
                .font(.headline)
                .foregroundColor(.white)

            ForEach(viewModel.countryBreakdown) { country in
                HStack {
                    Text(country.flag)
                        .font(.title2)

                    Text(country.country)
                        .font(.subheadline)
                        .foregroundColor(.white)

                    Spacer()

                    Text("\(country.contributions)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.quantumCyan)

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.bgCard)
                                .frame(width: geometry.size.width)

                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [.quantumCyan, .quantumPurple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * country.percentage)
                        }
                        .clipShape(Capsule())
                    }
                    .frame(width: 100, height: 8)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.bgCard)
        )
    }

    // MARK: - Recent Contributions Card
    private var recentContributionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Contributions")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                Text("Live")
                    .font(.caption)
                    .foregroundColor(.green)
            }

            ForEach(viewModel.recentContributions) { contribution in
                ContributionRow(contribution: contribution)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.bgCard)
        )
    }

    // MARK: - Leaderboard Section
    private var leaderboardSection: some View {
        VStack(spacing: 16) {
            ForEach(Array(viewModel.recentContributions.enumerated()), id: \.element.id) { index, contribution in
                LeaderboardRow(rank: index + 1, contribution: contribution)
            }
        }
        .padding()
    }

    // MARK: - Reports Section
    private var reportsSection: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.monthlyReports) { report in
                MonthlyReportCard(report: report)
            }
        }
        .padding()
    }
}

// MARK: - Contribution Stat Card
struct ContributionStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Spacer()

                if let trend = trend {
                    Text(trend)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.green.opacity(0.2)))
                }
            }

            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.bgCard)
        )
    }
}

// MARK: - Contribution Row
struct ContributionRow: View {
    let contribution: ContributionData

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(contributionColor)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(contribution.userName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)

                    if contribution.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(.quantumCyan)
                    }
                }

                Text(contribution.contributionType.rawValue)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                if let reduction = contribution.errorReduction {
                    Text("-\(Int(reduction * 100))% error")
                        .font(.caption)
                        .foregroundColor(.green)
                }

                Text(contribution.timestamp, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.textTertiary)
            }
        }
        .padding(.vertical, 8)
    }

    private var contributionColor: Color {
        switch contribution.contributionType {
        case .algorithmOptimization: return .quantumCyan
        case .errorCorrection: return .green
        case .circuitDesign: return .quantumPurple
        case .codeContribution: return .quantumOrange
        case .documentation: return .yellow
        case .translation: return .blue
        }
    }
}

// MARK: - Leaderboard Row
struct LeaderboardRow: View {
    let rank: Int
    let contribution: ContributionData

    var body: some View {
        HStack(spacing: 16) {
            // Rank
            ZStack {
                Circle()
                    .fill(rankColor)
                    .frame(width: 40, height: 40)

                Text("\(rank)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(rank <= 3 ? .black : .white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(contribution.userName)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(contribution.country)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("985")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.quantumCyan)

                Text("points")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(rank <= 3 ? rankColor.opacity(0.5) : Color.clear, lineWidth: 2)
                )
        )
    }

    private var rankColor: Color {
        switch rank {
        case 1: return Color(hex: "FFD700")  // Gold
        case 2: return Color(hex: "C0C0C0")  // Silver
        case 3: return Color(hex: "CD7F32")  // Bronze
        default: return Color.bgCard
        }
    }
}

// MARK: - Monthly Report Card
struct MonthlyReportCard: View {
    let report: MonthlyOptimizationReport

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(report.month) \(report.year)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Global Quantum Error Optimization Report")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                Image(systemName: "doc.text.fill")
                    .font(.title)
                    .foregroundColor(.quantumCyan)
            }

            Divider()
                .background(Color.white.opacity(0.1))

            // Stats
            HStack(spacing: 24) {
                VStack {
                    Text("\(report.totalContributions)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.quantumCyan)
                    Text("Contributions")
                        .font(.caption2)
                        .foregroundColor(.textSecondary)
                }

                VStack {
                    Text("\(report.uniqueContributors)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Contributors")
                        .font(.caption2)
                        .foregroundColor(.textSecondary)
                }

                VStack {
                    Text("\(report.countriesRepresented)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.quantumPurple)
                    Text("Countries")
                        .font(.caption2)
                        .foregroundColor(.textSecondary)
                }

                VStack {
                    Text("\(Int(report.averageErrorReduction * 100))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.quantumOrange)
                    Text("Avg. Reduction")
                        .font(.caption2)
                        .foregroundColor(.textSecondary)
                }
            }

            // Breakthroughs
            if !report.algorithmBreakthroughs.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Key Breakthroughs")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.yellow)

                    ForEach(report.algorithmBreakthroughs, id: \.self) { breakthrough in
                        HStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                            Text(breakthrough)
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
            }

            Button {
                // Download report
            } label: {
                HStack {
                    Image(systemName: "arrow.down.doc")
                    Text("Download Full Report")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.quantumCyan)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.quantumCyan, lineWidth: 1)
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.bgCard)
        )
    }
}

// MARK: - Admin Report Panel
struct AdminReportPanel: View {
    @ObservedObject var viewModel: GlobalContributionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isGenerating = false
    @State private var generatedReport: MonthlyOptimizationReport?

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Admin Badge
                HStack {
                    Image(systemName: "shield.checkered")
                        .font(.title)
                        .foregroundColor(.quantumOrange)

                    VStack(alignment: .leading) {
                        Text("Administrator Mode")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Global Report Management")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }

                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.quantumOrange.opacity(0.1))
                )

                // Generate Report Button
                Button {
                    Task {
                        isGenerating = true
                        generatedReport = await viewModel.generateMonthlyReport()
                        isGenerating = false
                    }
                } label: {
                    HStack {
                        if isGenerating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "doc.badge.plus")
                        }
                        Text("Generate Monthly Report")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.quantumPurple)
                    )
                }
                .disabled(isGenerating)

                if let report = generatedReport {
                    MonthlyReportCard(report: report)
                }

                Spacer()

                // O1 Visa Evidence Note
                VStack(alignment: .leading, spacing: 8) {
                    Label("O1 Visa Evidence", systemImage: "airplane")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.quantumCyan)

                    Text("This report demonstrates your leadership of \(viewModel.globalStats.totalUsers)+ quantum engineers across \(viewModel.globalStats.countriesActive) countries, providing evidence of extraordinary ability in the field.")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.bgCard)
                )
            }
            .padding()
            .background(Color.bgDark.ignoresSafeArea())
            .navigationTitle("Admin Panel")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.quantumCyan)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    GlobalContributionView()
}
