//
//  ExpertiseEvidenceDashboardView.swift
//  SwiftQuantumLearning
//
//  Frame 4: Portfolio - Expertise Evidence Dashboard
//  O1 Visa petition evidence with 3D Quantum Skill Tree
//  Fire energy (Red-Gold) gauge for US expert visa compliance
//
//  Created by SwiftQuantum Team
//  Copyright © 2026 SwiftQuantum. All rights reserved.
//

import SwiftUI
import Combine

// MARK: - Skill Node Model
struct SkillNode: Identifiable {
    let id: String
    let name: String
    let category: SkillCategory
    let level: Int // 1-5
    let xp: Int
    let codeContributions: Int
    let projectsCompleted: Int
    let certificationsEarned: Int
    let connections: [String] // IDs of connected nodes

    enum SkillCategory: String, CaseIterable {
        case fundamentals = "Fundamentals"
        case algorithms = "Algorithms"
        case hardware = "Hardware"
        case applications = "Applications"
        case research = "Research"

        var color: Color {
            switch self {
            case .fundamentals: return .quantumCyan
            case .algorithms: return .quantumPurple
            case .hardware: return .solarGold
            case .applications: return .quantumGreen
            case .research: return .miamiSunrise
            }
        }

        var icon: String {
            switch self {
            case .fundamentals: return "atom"
            case .algorithms: return "function"
            case .hardware: return "cpu"
            case .applications: return "app.connected.to.app.below.fill"
            case .research: return "doc.text.magnifyingglass"
            }
        }
    }

    static let sampleNodes: [SkillNode] = [
        SkillNode(id: "qubit", name: "Qubit Mastery", category: .fundamentals, level: 5, xp: 1500, codeContributions: 45, projectsCompleted: 12, certificationsEarned: 3, connections: ["superposition", "entanglement"]),
        SkillNode(id: "superposition", name: "Superposition", category: .fundamentals, level: 4, xp: 1200, codeContributions: 32, projectsCompleted: 8, certificationsEarned: 2, connections: ["qubit", "gates"]),
        SkillNode(id: "entanglement", name: "Entanglement", category: .fundamentals, level: 4, xp: 1100, codeContributions: 28, projectsCompleted: 7, certificationsEarned: 2, connections: ["qubit", "bellstate"]),
        SkillNode(id: "gates", name: "Quantum Gates", category: .fundamentals, level: 5, xp: 1400, codeContributions: 52, projectsCompleted: 15, certificationsEarned: 3, connections: ["superposition", "grover", "vqe"]),
        SkillNode(id: "grover", name: "Grover's Algorithm", category: .algorithms, level: 4, xp: 1000, codeContributions: 25, projectsCompleted: 5, certificationsEarned: 1, connections: ["gates", "shor"]),
        SkillNode(id: "shor", name: "Shor's Algorithm", category: .algorithms, level: 3, xp: 800, codeContributions: 18, projectsCompleted: 3, certificationsEarned: 1, connections: ["grover", "qft"]),
        SkillNode(id: "qft", name: "Quantum Fourier Transform", category: .algorithms, level: 3, xp: 750, codeContributions: 15, projectsCompleted: 4, certificationsEarned: 1, connections: ["shor", "vqe"]),
        SkillNode(id: "vqe", name: "VQE", category: .algorithms, level: 4, xp: 950, codeContributions: 30, projectsCompleted: 6, certificationsEarned: 2, connections: ["gates", "qft", "chemistry"]),
        SkillNode(id: "bellstate", name: "Bell States", category: .fundamentals, level: 5, xp: 1300, codeContributions: 40, projectsCompleted: 10, certificationsEarned: 2, connections: ["entanglement", "teleportation"]),
        SkillNode(id: "teleportation", name: "Quantum Teleportation", category: .applications, level: 3, xp: 700, codeContributions: 12, projectsCompleted: 3, certificationsEarned: 1, connections: ["bellstate", "cryptography"]),
        SkillNode(id: "cryptography", name: "Quantum Cryptography", category: .applications, level: 3, xp: 650, codeContributions: 10, projectsCompleted: 2, certificationsEarned: 1, connections: ["teleportation"]),
        SkillNode(id: "chemistry", name: "Quantum Chemistry", category: .applications, level: 2, xp: 500, codeContributions: 8, projectsCompleted: 2, certificationsEarned: 0, connections: ["vqe"]),
        SkillNode(id: "ibm", name: "IBM Quantum", category: .hardware, level: 4, xp: 1100, codeContributions: 35, projectsCompleted: 8, certificationsEarned: 2, connections: ["gates", "research"]),
        SkillNode(id: "research", name: "Research Publications", category: .research, level: 3, xp: 900, codeContributions: 20, projectsCompleted: 4, certificationsEarned: 2, connections: ["ibm"])
    ]
}

// MARK: - O1 Visa Criteria
struct O1VisaCriteria: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let currentProgress: Double // 0.0 - 1.0
    let requiredEvidence: String
    let isMet: Bool

    static let criteria: [O1VisaCriteria] = [
        O1VisaCriteria(
            id: "awards",
            name: "Awards & Recognition",
            description: "National/international awards for excellence",
            icon: "trophy.fill",
            currentProgress: 0.75,
            requiredEvidence: "Hackathon wins, App Store features",
            isMet: false
        ),
        O1VisaCriteria(
            id: "publications",
            name: "Scholarly Publications",
            description: "Published articles in professional journals",
            icon: "doc.text.fill",
            currentProgress: 0.6,
            requiredEvidence: "Technical blogs, research papers",
            isMet: false
        ),
        O1VisaCriteria(
            id: "contributions",
            name: "Original Contributions",
            description: "Significant contributions to the field",
            icon: "lightbulb.fill",
            currentProgress: 0.9,
            requiredEvidence: "SwiftQuantum library, open source",
            isMet: true
        ),
        O1VisaCriteria(
            id: "judging",
            name: "Judging Work of Others",
            description: "Served as judge of work of others",
            icon: "person.2.badge.gearshape.fill",
            currentProgress: 0.4,
            requiredEvidence: "Code reviews, hackathon judging",
            isMet: false
        ),
        O1VisaCriteria(
            id: "employment",
            name: "Critical Employment",
            description: "Employment in critical/essential capacity",
            icon: "briefcase.fill",
            currentProgress: 0.85,
            requiredEvidence: "Lead developer roles",
            isMet: true
        ),
        O1VisaCriteria(
            id: "salary",
            name: "High Salary Evidence",
            description: "Salary significantly above average",
            icon: "dollarsign.circle.fill",
            currentProgress: 0.7,
            requiredEvidence: "Compensation documentation",
            isMet: false
        )
    ]
}

// MARK: - Expertise Evidence Dashboard ViewModel
@MainActor
class ExpertiseDashboardViewModel: ObservableObject {
    @Published var skillNodes: [SkillNode] = SkillNode.sampleNodes
    @Published var selectedNode: SkillNode?
    @Published var criteria: [O1VisaCriteria] = O1VisaCriteria.criteria
    @Published var globalContributionIndex: Double = 0.78

    var totalXP: Int {
        skillNodes.reduce(0) { $0 + $1.xp }
    }

    var totalCodeContributions: Int {
        skillNodes.reduce(0) { $0 + $1.codeContributions }
    }

    var totalProjects: Int {
        skillNodes.reduce(0) { $0 + $1.projectsCompleted }
    }

    var totalCertifications: Int {
        skillNodes.reduce(0) { $0 + $1.certificationsEarned }
    }

    var criteriaMetCount: Int {
        criteria.filter { $0.isMet }.count
    }

    var overallProgress: Double {
        criteria.reduce(0) { $0 + $1.currentProgress } / Double(criteria.count)
    }
}

// MARK: - Expertise Evidence Dashboard View
struct ExpertiseEvidenceDashboardView: View {
    @StateObject private var viewModel = ExpertiseDashboardViewModel()
    @StateObject private var storeKitService = StoreKitService.shared
    @ObservedObject var translationManager = QuantumTranslationManager.shared

    @State private var showNodeDetail = false
    @State private var showExportSheet = false
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background with Fire energy
                LinearGradient(
                    colors: [.bgDark, Color(red: 0.1, green: 0.05, blue: 0.08)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header with Global Contribution Index
                        headerSection

                        // O1 Visa Requirements Progress
                        o1VisaProgressSection

                        // 3D Skill Tree
                        skillTreeSection

                        // Evidence Summary
                        evidenceSummarySection

                        // Export Actions
                        exportActionsSection

                        Spacer().frame(height: 100)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle(NSLocalizedString("portfolio.title", comment: ""))
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showNodeDetail) {
                if let node = viewModel.selectedNode {
                    SkillNodeDetailSheet(node: node)
                }
            }
            .sheet(isPresented: $showExportSheet) {
                ExportReportSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(NSLocalizedString("portfolio.expertiseIndex", comment: ""))
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                    Text(NSLocalizedString("portfolio.globalContribution", comment: ""))
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }

                Spacer()

                // Global Contribution Index Circle
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 8)
                        .frame(width: 80, height: 80)

                    Circle()
                        .trim(from: 0, to: viewModel.globalContributionIndex)
                        .stroke(
                            AngularGradient(
                                colors: [.fireRed, .solarGold, .miamiSunrise],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 0) {
                        Text(String(format: "%.0f", viewModel.globalContributionIndex * 100))
                            .font(.title2.bold())
                            .foregroundColor(.solarGold)
                        Text("%")
                            .font(.caption2)
                            .foregroundColor(.textSecondary)
                    }
                }
            }

            // Fire Energy Gauge
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.fireRed)
                    Text(NSLocalizedString("portfolio.fireEnergy", comment: ""))
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    Spacer()
                    Text(String(format: "%.0f%%", translationManager.fireEnergyLevel * 100))
                        .font(.caption.bold())
                        .foregroundColor(.solarGold)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.1))

                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [.fireRed, .miamiSunrise, .solarGold],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * translationManager.fireEnergyLevel)
                            .shadow(color: .solarGold.opacity(0.5), radius: 4)
                    }
                }
                .frame(height: 10)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(colors: [.fireRed.opacity(0.5), .solarGold.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 1.5
                        )
                )
        )
    }

    // MARK: - O1 Visa Progress Section
    private var o1VisaProgressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "doc.badge.gearshape.fill")
                    .foregroundColor(.solarGold)
                Text(NSLocalizedString("portfolio.o1Visa", comment: ""))
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Text("\(viewModel.criteriaMetCount)/\(viewModel.criteria.count) " + NSLocalizedString("portfolio.criteriaMet", comment: ""))
                    .font(.caption)
                    .foregroundColor(viewModel.criteriaMetCount >= 3 ? .completed : .textSecondary)
            }

            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            viewModel.criteriaMetCount >= 3
                                ? LinearGradient(colors: [.completed, .quantumGreen], startPoint: .leading, endPoint: .trailing)
                                : LinearGradient(colors: [.fireRed, .solarGold], startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(width: geo.size.width * viewModel.overallProgress)
                }
            }
            .frame(height: 8)

            // Criteria Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.criteria) { criterion in
                    O1CriteriaCard(criterion: criterion)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.bgCard)
        )
    }

    // MARK: - Skill Tree Section
    private var skillTreeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "point.3.connected.trianglepath.dotted")
                    .foregroundColor(.quantumCyan)
                Text(NSLocalizedString("portfolio.skillTree", comment: ""))
                    .font(.headline)
                    .foregroundColor(.white)
            }

            // 3D-like skill tree visualization
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(SkillNode.SkillCategory.allCases, id: \.rawValue) { category in
                        SkillCategoryColumn(
                            category: category,
                            nodes: viewModel.skillNodes.filter { $0.category == category },
                            onNodeTap: { node in
                                viewModel.selectedNode = node
                                showNodeDetail = true
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.bgCard)
        )
    }

    // MARK: - Evidence Summary Section
    private var evidenceSummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(NSLocalizedString("portfolio.evidenceSummary", comment: ""))
                .font(.headline)
                .foregroundColor(.white)

            HStack(spacing: 16) {
                EvidenceStatCard(title: "XP", value: "\(viewModel.totalXP)", icon: "star.fill", color: .solarGold)
                EvidenceStatCard(title: NSLocalizedString("portfolio.code", comment: ""), value: "\(viewModel.totalCodeContributions)", icon: "chevron.left.forwardslash.chevron.right", color: .quantumCyan)
                EvidenceStatCard(title: NSLocalizedString("portfolio.projects", comment: ""), value: "\(viewModel.totalProjects)", icon: "folder.fill", color: .quantumPurple)
                EvidenceStatCard(title: NSLocalizedString("portfolio.certs", comment: ""), value: "\(viewModel.totalCertifications)", icon: "rosette", color: .completed)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.bgCard)
        )
    }

    // MARK: - Export Actions Section
    private var exportActionsSection: some View {
        VStack(spacing: 12) {
            Button {
                if storeKitService.isPremium {
                    showExportSheet = true
                } else {
                    showPaywall = true
                }
            } label: {
                HStack {
                    Image(systemName: "doc.richtext")
                    Text(NSLocalizedString("portfolio.exportReport", comment: ""))
                }
                .font(.headline)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(colors: [.solarGold, .miamiGlow], startPoint: .leading, endPoint: .trailing)
                        )
                )
            }

            if !storeKitService.isPremium {
                Text(NSLocalizedString("portfolio.premiumRequired", comment: ""))
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
    }
}

// MARK: - O1 Criteria Card
struct O1CriteriaCard: View {
    let criterion: O1VisaCriteria

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: criterion.icon)
                    .foregroundColor(criterion.isMet ? .completed : .textSecondary)
                Spacer()
                if criterion.isMet {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.completed)
                }
            }

            Text(criterion.name)
                .font(.caption.bold())
                .foregroundColor(.white)
                .lineLimit(2)

            // Progress
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.1))
                    RoundedRectangle(cornerRadius: 2)
                        .fill(criterion.isMet ? Color.completed : Color.miamiSunrise)
                        .frame(width: geo.size.width * criterion.currentProgress)
                }
            }
            .frame(height: 4)

            Text(String(format: "%.0f%%", criterion.currentProgress * 100))
                .font(.caption2)
                .foregroundColor(.textTertiary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.bgDark)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(criterion.isMet ? Color.completed.opacity(0.5) : Color.clear, lineWidth: 1)
                )
        )
    }
}

// MARK: - Skill Category Column
struct SkillCategoryColumn: View {
    let category: SkillNode.SkillCategory
    let nodes: [SkillNode]
    let onNodeTap: (SkillNode) -> Void

    var body: some View {
        VStack(spacing: 12) {
            // Category Header
            HStack {
                Image(systemName: category.icon)
                    .foregroundColor(category.color)
                Text(category.rawValue)
                    .font(.caption.bold())
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(category.color.opacity(0.2))
            )

            // Nodes
            ForEach(nodes) { node in
                Button {
                    onNodeTap(node)
                } label: {
                    SkillNodeView(node: node)
                }
            }
        }
        .frame(width: 140)
        .padding(.horizontal, 8)
    }
}

// MARK: - Skill Node View
struct SkillNodeView: View {
    let node: SkillNode

    var body: some View {
        VStack(spacing: 8) {
            // Level indicator
            ZStack {
                Circle()
                    .fill(node.category.color.opacity(0.2))
                    .frame(width: 50, height: 50)

                Circle()
                    .trim(from: 0, to: Double(node.level) / 5.0)
                    .stroke(node.category.color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))

                Text("\(node.level)")
                    .font(.headline.bold())
                    .foregroundColor(node.category.color)
            }

            Text(node.name)
                .font(.caption2)
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            Text("\(node.xp) XP")
                .font(.caption2)
                .foregroundColor(.textTertiary)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.bgDark)
        )
    }
}

// MARK: - Evidence Stat Card
struct EvidenceStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(value)
                .font(.headline.bold())
                .foregroundColor(.white)
            Text(title)
                .font(.caption2)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.bgDark)
        )
    }
}

// MARK: - Skill Node Detail Sheet
struct SkillNodeDetailSheet: View {
    @Environment(\.dismiss) var dismiss
    let node: SkillNode

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgDark.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(node.category.color.opacity(0.2))
                                    .frame(width: 100, height: 100)

                                Circle()
                                    .trim(from: 0, to: Double(node.level) / 5.0)
                                    .stroke(node.category.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                    .frame(width: 100, height: 100)
                                    .rotationEffect(.degrees(-90))

                                Text("Lv.\(node.level)")
                                    .font(.title2.bold())
                                    .foregroundColor(node.category.color)
                            }

                            Text(node.name)
                                .font(.title2.bold())
                                .foregroundColor(.white)

                            Text(node.category.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.textSecondary)
                        }

                        // Stats
                        HStack(spacing: 16) {
                            statItem(title: "XP", value: "\(node.xp)", color: .solarGold)
                            statItem(title: NSLocalizedString("portfolio.code", comment: ""), value: "\(node.codeContributions)", color: .quantumCyan)
                            statItem(title: NSLocalizedString("portfolio.projects", comment: ""), value: "\(node.projectsCompleted)", color: .quantumPurple)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.bgCard)
                        )

                        // Connected Skills
                        if !node.connections.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(NSLocalizedString("portfolio.connectedSkills", comment: ""))
                                    .font(.headline)
                                    .foregroundColor(.white)

                                ForEach(node.connections, id: \.self) { connectionId in
                                    HStack {
                                        Image(systemName: "arrow.right.circle")
                                            .foregroundColor(.quantumCyan)
                                        Text(connectionId.capitalized)
                                            .foregroundColor(.textSecondary)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.bgCard)
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(NSLocalizedString("portfolio.skillDetail", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("common.done", comment: "")) {
                        dismiss()
                    }
                    .foregroundColor(.quantumCyan)
                }
            }
        }
    }

    private func statItem(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Export Report Sheet
struct ExportReportSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ExpertiseDashboardViewModel
    @State private var isExporting = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgDark.ignoresSafeArea()

                VStack(spacing: 24) {
                    Image(systemName: "doc.richtext.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(colors: [.solarGold, .miamiGlow], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )

                    Text(NSLocalizedString("portfolio.export.title", comment: ""))
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    Text(NSLocalizedString("portfolio.export.description", comment: ""))
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)

                    VStack(alignment: .leading, spacing: 12) {
                        exportItem(icon: "checkmark.circle.fill", text: NSLocalizedString("portfolio.export.item1", comment: ""))
                        exportItem(icon: "checkmark.circle.fill", text: NSLocalizedString("portfolio.export.item2", comment: ""))
                        exportItem(icon: "checkmark.circle.fill", text: NSLocalizedString("portfolio.export.item3", comment: ""))
                        exportItem(icon: "checkmark.circle.fill", text: NSLocalizedString("portfolio.export.item4", comment: ""))
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.bgCard)
                    )

                    Spacer()

                    Button {
                        isExporting = true
                        // Simulate export
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isExporting = false
                            dismiss()
                        }
                    } label: {
                        HStack {
                            if isExporting {
                                ProgressView()
                                    .tint(.black)
                            } else {
                                Image(systemName: "square.and.arrow.up")
                            }
                            Text(isExporting ? NSLocalizedString("portfolio.exporting", comment: "") : NSLocalizedString("portfolio.generateReport", comment: ""))
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(colors: [.solarGold, .miamiGlow], startPoint: .leading, endPoint: .trailing)
                                )
                        )
                    }
                    .disabled(isExporting)
                }
                .padding()
            }
            .navigationTitle(NSLocalizedString("portfolio.exportReport", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("common.cancel", comment: "")) {
                        dismiss()
                    }
                    .foregroundColor(.textSecondary)
                }
            }
        }
    }

    private func exportItem(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.completed)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
        }
    }
}

// MARK: - Preview
#Preview {
    ExpertiseEvidenceDashboardView()
}
