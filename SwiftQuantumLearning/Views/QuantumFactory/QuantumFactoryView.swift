//
//  QuantumFactoryView.swift
//  SwiftQuantumLearning
//
//  Quantum Factory - 알고리즘 개발 및 QuantumBridge 배포 플랫폼
//  기존 'Example' 탭을 대체하여 학습-실무 브릿지 구축
//
//  Created by SwiftQuantum Team
//  Copyright © 2026 SwiftQuantum. All rights reserved.
//

import SwiftUI

// MARK: - Factory Project
struct FactoryProject: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var circuit: QuantumCircuitData?
    var createdAt: Date
    var lastModified: Date
    var isDeployed: Bool
    var deploymentStatus: DeploymentStatus

    enum DeploymentStatus: String, Codable {
        case local = "Local"
        case pending = "Pending Deployment"
        case deployed = "Deployed to Bridge"
        case failed = "Deployment Failed"

        var color: Color {
            switch self {
            case .local: return .textSecondary
            case .pending: return .yellow
            case .deployed: return .green
            case .failed: return .red
            }
        }

        var icon: String {
            switch self {
            case .local: return "laptopcomputer"
            case .pending: return "arrow.up.circle"
            case .deployed: return "checkmark.icloud.fill"
            case .failed: return "xmark.icloud"
            }
        }
    }

    init(name: String, description: String = "") {
        self.id = UUID()
        self.name = name
        self.description = description
        self.circuit = nil
        self.createdAt = Date()
        self.lastModified = Date()
        self.isDeployed = false
        self.deploymentStatus = .local
    }
}

// MARK: - Quantum Factory View Model
@MainActor
class QuantumFactoryViewModel: ObservableObject {
    @Published var projects: [FactoryProject] = []
    @Published var selectedProject: FactoryProject?
    @Published var currentCircuit: QuantumCircuit?
    @Published var isLoading = false
    @Published var showPremiumPrompt = false
    @Published var deploymentProgress: Double = 0

    private let bridgeService = QuantumBridgeService.shared

    init() {
        loadSampleProjects()
    }

    private func loadSampleProjects() {
        projects = [
            FactoryProject(name: "Bell State Generator", description: "Create entangled qubit pairs"),
            FactoryProject(name: "Grover Search", description: "Quantum search algorithm"),
            FactoryProject(name: "QFT Circuit", description: "Quantum Fourier Transform"),
            FactoryProject(name: "VQE Optimizer", description: "Variational quantum eigensolver")
        ]
    }

    func createNewProject(name: String) -> FactoryProject {
        let project = FactoryProject(name: name)
        projects.insert(project, at: 0)
        return project
    }

    func deployToQuantumBridge(_ project: FactoryProject, tier: SubscriptionTier?) async throws {
        guard let userTier = tier else {
            showPremiumPrompt = true
            return
        }

        guard userTier == .pro || userTier == .premium else {
            showPremiumPrompt = true
            return
        }

        isLoading = true
        deploymentProgress = 0

        // 시뮬레이션된 배포 프로세스
        for i in 1...10 {
            try? await Task.sleep(nanoseconds: 200_000_000)
            deploymentProgress = Double(i) / 10
        }

        // 프로젝트 상태 업데이트
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index].isDeployed = true
            projects[index].deploymentStatus = .deployed
            projects[index].lastModified = Date()
        }

        isLoading = false
    }

    func deleteProject(_ project: FactoryProject) {
        projects.removeAll { $0.id == project.id }
    }
}

// MARK: - Quantum Factory View
struct QuantumFactoryView: View {
    @StateObject private var viewModel = QuantumFactoryViewModel()
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @State private var showNewProjectSheet = false
    @State private var showCircuitEditor = false
    @State private var showPremiumUpgrade = false
    @State private var selectedTab: FactoryTab = .myProjects

    enum FactoryTab: String, CaseIterable {
        case myProjects = "My Projects"
        case templates = "Templates"
        case deployed = "Deployed"

        var icon: String {
            switch self {
            case .myProjects: return "folder.fill"
            case .templates: return "doc.on.doc.fill"
            case .deployed: return "icloud.fill"
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with Bridge Status
                bridgeStatusHeader

                // Tab Selector
                tabSelector

                // Content
                ScrollView {
                    switch selectedTab {
                    case .myProjects:
                        projectsGrid
                    case .templates:
                        templatesSection
                    case .deployed:
                        deployedSection
                    }
                }
            }
            .background(Color.bgDark.ignoresSafeArea())
            .navigationTitle("Quantum Factory")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showNewProjectSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.quantumCyan)
                    }
                }
            }
        }
        .sheet(isPresented: $showNewProjectSheet) {
            NewProjectSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showCircuitEditor) {
            if let project = viewModel.selectedProject {
                CircuitEditorView(project: project, viewModel: viewModel)
            }
        }
        .sheet(isPresented: $showPremiumUpgrade) {
            PremiumUpgradeView()
                .environmentObject(progressViewModel)
        }
        .onChange(of: viewModel.showPremiumPrompt) { _, newValue in
            if newValue {
                showPremiumUpgrade = true
                viewModel.showPremiumPrompt = false
            }
        }
    }

    // MARK: - Bridge Status Header
    private var bridgeStatusHeader: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                Text("Bridge Online")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.quantumOrange)
                Text("100 credits")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.bgCard))

            Button {
                showPremiumUpgrade = true
            } label: {
                Text("Upgrade")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "FFD700"), Color(hex: "FF8C00")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.bgCard)
    }

    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(FactoryTab.allCases, id: \.rawValue) { tab in
                Button {
                    withAnimation(.spring()) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: tab.icon)
                            Text(tab.rawValue)
                        }
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
    }

    // MARK: - Projects Grid
    private var projectsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            // New Project Card
            Button {
                showNewProjectSheet = true
            } label: {
                VStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.quantumCyan)

                    Text("New Project")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 160)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.bgCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.quantumCyan.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8]))
                        )
                )
            }

            // Project Cards
            ForEach(viewModel.projects) { project in
                ProjectCard(project: project) {
                    viewModel.selectedProject = project
                    showCircuitEditor = true
                }
            }
        }
        .padding()
    }

    // MARK: - Templates Section
    private var templatesSection: some View {
        VStack(spacing: 16) {
            ForEach(QuantumTemplate.allTemplates) { template in
                TemplateCard(template: template) {
                    let project = viewModel.createNewProject(name: template.name)
                    viewModel.selectedProject = project
                    showCircuitEditor = true
                }
            }
        }
        .padding()
    }

    // MARK: - Deployed Section
    private var deployedSection: some View {
        VStack(spacing: 16) {
            let deployedProjects = viewModel.projects.filter { $0.isDeployed }

            if deployedProjects.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "icloud.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.textSecondary)

                    Text("No Deployed Projects")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("Deploy your circuits to QuantumBridge to run on real quantum hardware")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)

                    Button {
                        selectedTab = .myProjects
                    } label: {
                        Text("Create a Project")
                    }
                    .buttonStyle(.quantumSecondary)
                }
                .padding(40)
            } else {
                ForEach(deployedProjects) { project in
                    DeployedProjectCard(project: project)
                }
            }
        }
        .padding()
    }
}

// MARK: - Project Card
struct ProjectCard: View {
    let project: FactoryProject
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "cpu.fill")
                        .font(.title2)
                        .foregroundColor(.quantumPurple)

                    Spacer()

                    Image(systemName: project.deploymentStatus.icon)
                        .foregroundColor(project.deploymentStatus.color)
                }

                Text(project.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(project.description.isEmpty ? "No description" : project.description)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)

                Spacer()

                HStack {
                    Text(project.lastModified, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.textTertiary)

                    Spacer()

                    if project.isDeployed {
                        Text("LIVE")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
            }
            .padding()
            .frame(height: 160)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.bgCard)
            )
        }
    }
}

// MARK: - Template Card
struct TemplateCard: View {
    let template: QuantumTemplate
    let onUse: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: template.icon)
                .font(.title)
                .foregroundColor(.quantumCyan)
                .frame(width: 50)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(template.name)
                        .font(.headline)
                        .foregroundColor(.white)

                    if template.isPremium {
                        Text("PRO")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.quantumOrange))
                    }
                }

                Text(template.description)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)

                HStack {
                    Label("\(template.qubitCount) qubits", systemImage: "circle.grid.2x2")
                    Label("\(template.gateCount) gates", systemImage: "square.stack.3d.up")
                }
                .font(.caption2)
                .foregroundColor(.textTertiary)
            }

            Spacer()

            Button(action: onUse) {
                Text("Use")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.quantumCyan)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .stroke(Color.quantumCyan, lineWidth: 1)
                    )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.bgCard)
        )
    }
}

// MARK: - Deployed Project Card
struct DeployedProjectCard: View {
    let project: FactoryProject

    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 12, height: 12)
                Rectangle()
                    .fill(Color.green.opacity(0.3))
                    .frame(width: 2, height: 40)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(project.name)
                    .font(.headline)
                    .foregroundColor(.white)

                HStack {
                    Label("Running", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)

                    Text("•")
                        .foregroundColor(.textSecondary)

                    Text("Deployed \(project.lastModified, style: .relative)")
                        .foregroundColor(.textSecondary)
                }
                .font(.caption)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("0.998")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.quantumCyan)
                Text("Fidelity")
                    .font(.caption2)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.bgCard)
        )
    }
}

// MARK: - Quantum Template
struct QuantumTemplate: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let qubitCount: Int
    let gateCount: Int
    let isPremium: Bool

    static let allTemplates: [QuantumTemplate] = [
        QuantumTemplate(
            id: "bell",
            name: "Bell State",
            description: "Create maximally entangled qubit pairs",
            icon: "link",
            qubitCount: 2,
            gateCount: 2,
            isPremium: false
        ),
        QuantumTemplate(
            id: "grover",
            name: "Grover's Search",
            description: "Quantum search algorithm with O(√N) complexity",
            icon: "magnifyingglass",
            qubitCount: 4,
            gateCount: 12,
            isPremium: false
        ),
        QuantumTemplate(
            id: "qft",
            name: "Quantum Fourier Transform",
            description: "Foundation for Shor's algorithm",
            icon: "waveform.path.ecg",
            qubitCount: 4,
            gateCount: 10,
            isPremium: true
        ),
        QuantumTemplate(
            id: "vqe",
            name: "VQE Circuit",
            description: "Variational quantum eigensolver for chemistry",
            icon: "atom",
            qubitCount: 8,
            gateCount: 24,
            isPremium: true
        ),
        QuantumTemplate(
            id: "qaoa",
            name: "QAOA",
            description: "Quantum approximate optimization",
            icon: "chart.line.uptrend.xyaxis",
            qubitCount: 6,
            gateCount: 18,
            isPremium: true
        )
    ]
}

// MARK: - New Project Sheet
struct NewProjectSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: QuantumFactoryViewModel

    @State private var projectName = ""
    @State private var projectDescription = ""
    @State private var selectedMode: ContinuousOperationMode = .standard

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Project Name")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)

                    TextField("My Quantum Circuit", text: $projectName)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.bgCard)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Description (Optional)")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)

                    TextField("What does this circuit do?", text: $projectDescription)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.bgCard)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Operation Mode")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)

                    ForEach(ContinuousOperationMode.allCases, id: \.rawValue) { mode in
                        OperationModeCard(
                            mode: mode,
                            isSelected: selectedMode == mode
                        ) {
                            selectedMode = mode
                        }
                    }
                }

                Spacer()

                Button {
                    let _ = viewModel.createNewProject(name: projectName.isEmpty ? "Untitled Project" : projectName)
                    dismiss()
                } label: {
                    Text("Create Project")
                }
                .buttonStyle(.quantumPrimary)
            }
            .padding()
            .background(Color.bgDark.ignoresSafeArea())
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
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
}

// MARK: - Operation Mode Card
struct OperationModeCard: View {
    let mode: ContinuousOperationMode
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .quantumCyan : .textSecondary)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(mode.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)

                        if let tier = mode.requiredTier {
                            Text(tier.rawValue.uppercased())
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(tier == .pro ? Color.quantumCyan : Color.quantumOrange)
                                )
                        }
                    }

                    Text(mode.description)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)

                    Text("Up to \(mode.maxQubits) qubits")
                        .font(.caption2)
                        .foregroundColor(.textTertiary)
                }

                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.bgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.quantumCyan : Color.clear, lineWidth: 2)
                    )
            )
        }
    }
}

// MARK: - Circuit Editor View (Placeholder)
struct CircuitEditorView: View {
    let project: FactoryProject
    @ObservedObject var viewModel: QuantumFactoryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var circuit: QuantumCircuit

    init(project: FactoryProject, viewModel: QuantumFactoryViewModel) {
        self.project = project
        self.viewModel = viewModel
        self._circuit = State(initialValue: QuantumCircuit(name: project.name))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Circuit Canvas
                CircuitCanvasView(circuit: $circuit)

                // Gate Palette
                GatePaletteView(circuit: $circuit)
            }
            .background(Color.bgDark.ignoresSafeArea())
            .navigationTitle(project.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.textSecondary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            Task {
                                await circuit.execute()
                            }
                        } label: {
                            Label("Run Locally", systemImage: "play.fill")
                        }

                        Button {
                            Task {
                                try? await viewModel.deployToQuantumBridge(project, tier: .pro)
                            }
                        } label: {
                            Label("Deploy to Bridge", systemImage: "icloud.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                            .foregroundColor(.quantumCyan)
                    }
                }
            }
        }
    }
}

// MARK: - Circuit Canvas View
struct CircuitCanvasView: View {
    @Binding var circuit: QuantumCircuit

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            VStack(alignment: .leading, spacing: 2) {
                ForEach(0..<circuit.qubitCount, id: \.self) { qubit in
                    QubitWireView(qubit: qubit, circuit: circuit)
                }
            }
            .padding()
        }
        .background(Color.bgCard)
    }
}

// MARK: - Qubit Wire View
struct QubitWireView: View {
    let qubit: Int
    let circuit: QuantumCircuit

    var body: some View {
        HStack(spacing: 0) {
            // Qubit label
            Text("|q\(qubit)⟩")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.white)
                .frame(width: 40)

            // Wire line
            Rectangle()
                .fill(Color.textSecondary.opacity(0.5))
                .frame(height: 2)
                .frame(minWidth: 300)

            // Gates on this qubit
            HStack(spacing: 8) {
                ForEach(circuit.gates.filter { $0.targetQubit == qubit }) { gate in
                    GateSymbolView(gate: gate)
                }
            }
        }
        .frame(height: 50)
    }
}

// MARK: - Gate Symbol View
struct GateSymbolView: View {
    let gate: QuantumGate

    var body: some View {
        Text(gate.type.rawValue)
            .font(.system(.caption, design: .monospaced))
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(width: 30, height: 30)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(gate.type.color)
            )
    }
}

// MARK: - Gate Palette View
struct GatePaletteView: View {
    @Binding var circuit: QuantumCircuit
    @State private var selectedGate: QuantumGateType?

    var body: some View {
        VStack(spacing: 12) {
            Text("Gates")
                .font(.caption)
                .foregroundColor(.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(QuantumGateType.allCases, id: \.rawValue) { gateType in
                        Button {
                            circuit.addGate(gateType, target: 0)
                        } label: {
                            VStack(spacing: 4) {
                                Text(gateType.rawValue)
                                    .font(.system(.headline, design: .monospaced))
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(gateType.color)
                                    )

                                Text(gateType.displayName)
                                    .font(.caption2)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 16)
        .background(Color.bgCard)
    }
}

// MARK: - Preview
#Preview {
    QuantumFactoryView()
        .environmentObject(ProgressViewModel())
}
