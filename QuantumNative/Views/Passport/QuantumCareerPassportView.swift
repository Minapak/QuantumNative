//
//  QuantumCareerPassportView.swift
//  QuantumNative
//
//  Quantum Career Passport - O1 Visa Evidence Dashboard
//  Created by QuantumNative Team
//  Copyright 2026 QuantumNative. All rights reserved.
//

import SwiftUI

struct QuantumCareerPassportView: View {
    @StateObject private var passportService = CareerPassportService.shared
    @State private var showingPDFExport = false
    @State private var selectedTab: PassportTab = .dashboard

    enum PassportTab: String, CaseIterable {
        case dashboard = "Dashboard"
        case circuits = "My Circuits"
        case badges = "Badges"
        case leaderboard = "Rankings"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.15),
                        Color.black
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Tab selector
                    tabSelector

                    // Content
                    TabView(selection: $selectedTab) {
                        dashboardView
                            .tag(PassportTab.dashboard)

                        myCircuitsView
                            .tag(PassportTab.circuits)

                        badgesView
                            .tag(PassportTab.badges)

                        leaderboardView
                            .tag(PassportTab.leaderboard)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Career Passport")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingPDFExport = true
                    } label: {
                        Image(systemName: "doc.text")
                            .foregroundColor(.yellow)
                    }
                }
            }
            .sheet(isPresented: $showingPDFExport) {
                PDFExportView(evidence: passportService.evidence)
            }
            .task {
                await passportService.fetchEvidence()
                await passportService.fetchBadges()
                await passportService.fetchLeaderboard()
                await passportService.fetchMyCircuits()
            }
        }
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(PassportTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    } label: {
                        Text(tab.rawValue)
                            .font(.subheadline)
                            .fontWeight(selectedTab == tab ? .bold : .medium)
                            .foregroundColor(selectedTab == tab ? .white : .gray)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                selectedTab == tab
                                ? Color.cyan.opacity(0.3)
                                : Color.white.opacity(0.05)
                            )
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Dashboard View

    private var dashboardView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // O1 Readiness Score
                o1ScoreCard

                // Radar Chart
                radarChartCard

                // Contribution Timeline
                contributionTimelineCard

                // Quick Stats
                quickStatsGrid

                // Export CTA
                exportCTAButton
            }
            .padding()
        }
    }

    private var o1ScoreCard: some View {
        VStack(spacing: 16) {
            Text("O1 Readiness Score")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))

            ZStack {
                // Background ring
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 12)
                    .frame(width: 160, height: 160)

                // Progress ring
                Circle()
                    .trim(from: 0, to: CGFloat((passportService.evidence?.o1ReadinessScore ?? 0) / 100))
                    .stroke(
                        LinearGradient(
                            colors: [.cyan, .yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: passportService.evidence?.o1ReadinessScore)

                VStack(spacing: 4) {
                    Text("\(Int(passportService.evidence?.o1ReadinessScore ?? 0))")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("/ 100")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            // Percentile badge
            if let evidence = passportService.evidence, let rank = evidence.globalRank {
                HStack(spacing: 6) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.yellow)
                    Text("Top \(String(format: "%.1f", evidence.percentile))%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.yellow)
                    Text("(Rank #\(rank))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.yellow.opacity(0.15))
                .cornerRadius(20)
            }
        }
        .padding(24)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
    }

    private var radarChartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Skill Radar")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                HStack(spacing: 12) {
                    LegendItem(color: .cyan, label: "You")
                    LegendItem(color: .gray, label: "Average")
                }
            }

            RadarChartView(
                scores: passportService.evidence?.radarScores ?? [0, 0, 0, 0, 0],
                globalAverage: [50, 50, 50, 50, 50]
            )
            .frame(height: 280)
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
    }

    private var contributionTimelineCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Contribution Timeline")
                .font(.headline)
                .foregroundColor(.white)

            // Placeholder - would show GitHub-style contribution graph
            ContributionGridView()
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
    }

    private var quickStatsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            PassportStatCard(
                title: "Circuits",
                value: "\(passportService.evidence?.circuitsPublished ?? 0)",
                icon: "cpu",
                color: .cyan
            )

            PassportStatCard(
                title: "Citations",
                value: "\(passportService.evidence?.totalCitations ?? 0)",
                icon: "quote.bubble",
                color: .orange
            )

            PassportStatCard(
                title: "Reviews",
                value: "\(passportService.evidence?.reviewsCompleted ?? 0)",
                icon: "checkmark.seal",
                color: .green
            )

            PassportStatCard(
                title: "Badges",
                value: "\(passportService.badges.filter { $0.isEarned }.count)",
                icon: "medal",
                color: .yellow
            )
        }
    }

    private var exportCTAButton: some View {
        Button {
            showingPDFExport = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "doc.richtext")
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Export PDF Evidence")
                        .font(.headline)
                    Text("Generate official O1 visa documentation")
                        .font(.caption)
                        .opacity(0.7)
                }

                Spacer()

                Image(systemName: "chevron.right")
            }
            .foregroundColor(.black)
            .padding()
            .background(
                LinearGradient(
                    colors: [.yellow, .orange],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
    }

    // MARK: - My Circuits View

    private var myCircuitsView: some View {
        ScrollView {
            if passportService.myCircuits.isEmpty {
                emptyCircuitsView
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(passportService.myCircuits) { circuit in
                        CircuitCard(circuit: circuit)
                    }
                }
                .padding()
            }
        }
    }

    private var emptyCircuitsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "cpu")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No Circuits Published")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("Publish your first quantum circuit to start building your evidence portfolio")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            NavigationLink {
                // Navigate to circuit creation
                Text("Create Circuit View")
            } label: {
                Text("Create Circuit")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Color.cyan)
                    .cornerRadius(25)
            }
        }
        .padding(.top, 80)
    }

    // MARK: - Badges View

    private var badgesView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(passportService.badges) { badge in
                    BadgeCard(badge: badge)
                }
            }
            .padding()
        }
    }

    // MARK: - Leaderboard View

    private var leaderboardView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(passportService.leaderboard) { entry in
                    PassportLeaderboardRow(entry: entry)
                }
            }
            .padding()
        }
    }
}

// MARK: - Supporting Views

struct PassportStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

struct CircuitCard: View {
    let circuit: PublishedCircuit

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(circuit.title)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(circuit.doi)
                        .font(.caption)
                        .foregroundColor(.cyan)
                }

                Spacer()

                if circuit.isVerified {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                }
            }

            HStack(spacing: 16) {
                Label("\(circuit.qubitCount) qubits", systemImage: "circle.grid.2x2")
                Label("\(circuit.gatesCount) gates", systemImage: "cpu")
                Label("Depth \(circuit.depth)", systemImage: "arrow.right")
            }
            .font(.caption)
            .foregroundColor(.gray)

            HStack(spacing: 20) {
                ImpactStat(icon: "arrow.branch", value: circuit.forkCount, label: "Forks")
                ImpactStat(icon: "quote.bubble", value: circuit.citationCount, label: "Citations")
                ImpactStat(icon: "play.circle", value: circuit.runCount, label: "Runs")
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

struct ImpactStat: View {
    let icon: String
    let value: Int
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text("\(value)")
                .fontWeight(.semibold)
        }
        .font(.caption)
        .foregroundColor(.white.opacity(0.7))
    }
}

struct BadgeCard: View {
    let badge: CareerBadge

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        badge.isEarned
                        ? tierGradient(badge.tier)
                        : LinearGradient(colors: [.gray.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: 60, height: 60)

                Image(systemName: badge.icon)
                    .font(.title2)
                    .foregroundColor(badge.isEarned ? .white : .gray)
            }
            .opacity(badge.isEarned ? 1.0 : 0.4)

            Text(badge.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(badge.isEarned ? .white : .gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    private func tierGradient(_ tier: String) -> LinearGradient {
        switch tier {
        case "platinum":
            return LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "gold":
            return LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "silver":
            return LinearGradient(colors: [.gray, .white.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [.brown, .orange.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

struct PassportLeaderboardRow: View {
    let entry: LeaderboardEntry

    var body: some View {
        HStack(spacing: 16) {
            // Rank
            ZStack {
                if entry.rank <= 3 {
                    Circle()
                        .fill(rankColor(entry.rank))
                        .frame(width: 32, height: 32)
                }

                Text("\(entry.rank)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(entry.rank <= 3 ? .white : .gray)
            }
            .frame(width: 40)

            // User info
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.username)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text("\(entry.circuitsPublished) circuits | \(entry.totalCitations) citations")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            // Score
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(entry.o1Score))")
                    .font(.headline)
                    .foregroundColor(.cyan)

                Text("O1 Score")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return Color(white: 0.75)
        case 3: return .orange
        default: return .gray
        }
    }
}

struct ContributionGridView: View {
    // Placeholder for contribution timeline
    let weeks = 12
    let daysPerWeek = 7

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<weeks, id: \.self) { week in
                VStack(spacing: 3) {
                    ForEach(0..<daysPerWeek, id: \.self) { day in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(randomIntensityColor())
                            .frame(width: 12, height: 12)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }

    private func randomIntensityColor() -> Color {
        let intensity = Double.random(in: 0...1)
        if intensity < 0.2 {
            return Color.white.opacity(0.05)
        } else {
            return Color.cyan.opacity(intensity * 0.8)
        }
    }
}

struct PDFExportView: View {
    let evidence: O1Evidence?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 30) {
                    Image(systemName: "doc.richtext.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.yellow)

                    Text("O1 Evidence Report")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Generate an official PDF document summarizing your quantum computing achievements for O1 visa applications, university admissions, or job applications.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    if let evidence = evidence {
                        VStack(spacing: 8) {
                            Text("O1 Readiness: \(Int(evidence.o1ReadinessScore))%")
                            Text("Circuits: \(evidence.circuitsPublished)")
                            Text("Citations: \(evidence.totalCitations)")
                            Text("Reviews: \(evidence.reviewsCompleted)")
                        }
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    }

                    Button {
                        // Generate PDF
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.down.doc")
                            Text("Generate PDF")
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                    }
                }
                .padding()
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.gray)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    QuantumCareerPassportView()
}
