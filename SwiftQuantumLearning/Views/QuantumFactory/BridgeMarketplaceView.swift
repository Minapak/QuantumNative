//
//  BridgeMarketplaceView.swift
//  SwiftQuantumLearning
//
//  Bridge Marketplace: 실시간 하드웨어 큐 및 우선 순위 액세스
//  사용자 코드를 '자산'으로 만드는 시스템
//  마이애미 해변 밤하늘 테마 파티클 애니메이션
//
//  Created by SwiftQuantum Team
//  Copyright © 2026 SwiftQuantum. All rights reserved.
//

import SwiftUI
import SceneKit
import Combine

// MARK: - Hardware Backend
struct HardwareBackend: Identifiable {
    let id: String
    let name: String
    let provider: String
    let qubitCount: Int
    let queueDepth: Int
    let averageWaitTime: TimeInterval  // seconds
    let costPerShot: Double
    let fidelity: Double
    let status: BackendStatus
    let isPriority: Bool

    enum BackendStatus: String {
        case online = "Online"
        case busy = "Busy"
        case maintenance = "Maintenance"
        case reserved = "Reserved"

        var color: Color {
            switch self {
            case .online: return .green
            case .busy: return .yellow
            case .maintenance: return .orange
            case .reserved: return .quantumPurple
            }
        }
    }
}

// MARK: - Queue Position
struct QueuePosition: Identifiable {
    let id: UUID
    let jobId: String
    let circuitName: String
    let position: Int
    let estimatedStart: Date
    let isPriority: Bool
    let status: JobQueueStatus

    enum JobQueueStatus: String {
        case waiting = "Waiting"
        case preparing = "Preparing"
        case running = "Running"
        case complete = "Complete"
    }
}

// MARK: - Cost Estimation
struct CostEstimation {
    let shots: Int
    let qubitCount: Int
    let gateCount: Int
    let backendName: String
    let baseCost: Double
    let prioritySurcharge: Double
    let totalCost: Double
    let creditsRemaining: Int
    let estimatedTime: TimeInterval

    var formattedCost: String {
        String(format: "$%.4f", totalCost)
    }

    var formattedCredits: String {
        "\(Int(totalCost * 100)) credits"
    }
}

// MARK: - Bridge Marketplace View Model
@MainActor
class BridgeMarketplaceViewModel: ObservableObject {
    @Published var backends: [HardwareBackend] = []
    @Published var selectedBackend: HardwareBackend?
    @Published var queuePositions: [QueuePosition] = []
    @Published var userJobsInQueue: [QueuePosition] = []
    @Published var costEstimation: CostEstimation?
    @Published var isLoading = false
    @Published var showPriorityComparison = false
    @Published var liveQueueAnimation = true

    private var queueUpdateTimer: Timer?

    init() {
        loadBackends()
        startQueueUpdates()
    }

    deinit {
        queueUpdateTimer?.invalidate()
    }

    func loadBackends() {
        backends = [
            HardwareBackend(
                id: "ibm_brisbane",
                name: "IBM Brisbane",
                provider: "IBM Quantum",
                qubitCount: 127,
                queueDepth: 47,
                averageWaitTime: 1800,  // 30 min
                costPerShot: 0.0001,
                fidelity: 0.9965,
                status: .online,
                isPriority: false
            ),
            HardwareBackend(
                id: "ibm_osaka",
                name: "IBM Osaka",
                provider: "IBM Quantum",
                qubitCount: 127,
                queueDepth: 23,
                averageWaitTime: 900,  // 15 min
                costPerShot: 0.00012,
                fidelity: 0.9972,
                status: .online,
                isPriority: false
            ),
            HardwareBackend(
                id: "ibm_kyoto",
                name: "IBM Kyoto",
                provider: "IBM Quantum",
                qubitCount: 127,
                queueDepth: 89,
                averageWaitTime: 3600,  // 60 min
                costPerShot: 0.00008,
                fidelity: 0.9958,
                status: .busy,
                isPriority: false
            ),
            HardwareBackend(
                id: "qb_priority",
                name: "QuantumBridge Priority",
                provider: "QuantumBridge",
                qubitCount: 256,
                queueDepth: 3,
                averageWaitTime: 120,  // 2 min
                costPerShot: 0.0005,
                fidelity: 0.9985,
                status: .online,
                isPriority: true
            ),
            HardwareBackend(
                id: "harvard_mit_sim",
                name: "Harvard-MIT Simulator",
                provider: "Research Partner",
                qubitCount: 3000,
                queueDepth: 0,
                averageWaitTime: 0,
                costPerShot: 0,
                fidelity: 0.9999,
                status: .online,
                isPriority: true
            )
        ]
    }

    func startQueueUpdates() {
        queueUpdateTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateQueuePositions()
            }
        }
    }

    func updateQueuePositions() {
        guard liveQueueAnimation else { return }

        // 시뮬레이션된 큐 포지션 업데이트
        var positions: [QueuePosition] = []
        for i in 0..<min(10, Int.random(in: 5...15)) {
            let isPriority = i < 2
            positions.append(QueuePosition(
                id: UUID(),
                jobId: "JOB-\(String(format: "%04d", Int.random(in: 1000...9999)))",
                circuitName: ["Bell State", "Grover-4", "VQE-H2", "QAOA-MaxCut", "QFT-8"].randomElement()!,
                position: i + 1,
                estimatedStart: Date().addingTimeInterval(Double(i * 120)),
                isPriority: isPriority,
                status: i == 0 ? .running : (i < 3 ? .preparing : .waiting)
            ))
        }
        queuePositions = positions
    }

    func calculateCost(circuit: QuantumCircuit, backend: HardwareBackend, shots: Int, isPriority: Bool) -> CostEstimation {
        let baseCost = Double(shots) * backend.costPerShot
        let complexityMultiplier = 1.0 + (Double(circuit.gates.count) * 0.01)
        let prioritySurcharge = isPriority ? baseCost * 0.5 : 0
        let totalCost = (baseCost * complexityMultiplier) + prioritySurcharge

        let estimation = CostEstimation(
            shots: shots,
            qubitCount: circuit.qubitCount,
            gateCount: circuit.gates.count,
            backendName: backend.name,
            baseCost: baseCost * complexityMultiplier,
            prioritySurcharge: prioritySurcharge,
            totalCost: totalCost,
            creditsRemaining: 100,  // From user subscription
            estimatedTime: isPriority ? 120 : backend.averageWaitTime
        )

        costEstimation = estimation
        return estimation
    }

    func selectBackend(_ backend: HardwareBackend) {
        selectedBackend = backend
    }
}

// MARK: - Bridge Marketplace View
struct BridgeMarketplaceView: View {
    @StateObject private var viewModel = BridgeMarketplaceViewModel()
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @State private var selectedCircuit: QuantumCircuit?
    @State private var shots: Int = 1000
    @State private var usePriority = false
    @State private var showPremiumUpgrade = false

    // 사용자 티어 (시뮬레이션)
    private var userTier: SubscriptionTier? = .pro

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with live status
                    headerSection

                    // Priority Access Banner (Enterprise)
                    if userTier == .premium {
                        priorityAccessBanner
                    } else {
                        priorityUpgradeBanner
                    }

                    // Hardware Backends
                    backendsSection

                    // Live Queue Visualization
                    liveQueueSection

                    // Cost Estimator
                    costEstimatorSection

                    // Your Jobs
                    yourJobsSection
                }
                .padding()
            }
            .background(Color.bgDark.ignoresSafeArea())
            .navigationTitle("Bridge Marketplace")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showPremiumUpgrade) {
            PremiumUpgradeView()
                .environmentObject(progressViewModel)
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("Live Hardware Feed")
                        .font(.caption)
                        .foregroundColor(.green)
                }

                Text("Deploy to Real Quantum Hardware")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("Credits")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                Text("100")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.quantumCyan)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.bgCard)
            )
        }
    }

    // MARK: - Priority Access Banner
    private var priorityAccessBanner: some View {
        HStack(spacing: 16) {
            Image(systemName: "bolt.shield.fill")
                .font(.title)
                .foregroundColor(.yellow)
                .symbolEffect(.pulse)

            VStack(alignment: .leading, spacing: 4) {
                Text("Priority Access Active")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Your jobs skip to front of queue (<2 min wait)")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text("50x")
                    .font(.title)
                    .fontWeight(.black)
                    .foregroundColor(.yellow)
                Text("Faster")
                    .font(.caption)
                    .foregroundColor(.yellow)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "FFD700").opacity(0.3), Color(hex: "FF8C00").opacity(0.1)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "FFD700").opacity(0.5), lineWidth: 2)
                )
        )
    }

    // MARK: - Priority Upgrade Banner
    private var priorityUpgradeBanner: some View {
        Button {
            showPremiumUpgrade = true
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "tortoise.fill")
                    .font(.title)
                    .foregroundColor(.textSecondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Standard Queue Access")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("Average wait: 30-60 minutes")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Get Priority")
                        .font(.caption)
                        .fontWeight(.bold)
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

                    Text("<2 min wait")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.bgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.textSecondary.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }

    // MARK: - Backends Section
    private var backendsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Available Hardware")
                .font(.headline)
                .foregroundColor(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.backends) { backend in
                        BackendCard(
                            backend: backend,
                            isSelected: viewModel.selectedBackend?.id == backend.id,
                            userHasPriority: userTier == .premium
                        ) {
                            viewModel.selectBackend(backend)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Live Queue Section
    private var liveQueueSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Live Queue")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Toggle("", isOn: $viewModel.liveQueueAnimation)
                    .toggleStyle(SwitchToggleStyle(tint: .quantumCyan))
                    .labelsHidden()

                Text(viewModel.liveQueueAnimation ? "Live" : "Paused")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }

            // Miami Night Sky Particle Queue
            MiamiQueueVisualization(
                queuePositions: viewModel.queuePositions,
                userHasPriority: userTier == .premium
            )
            .frame(height: 200)
        }
    }

    // MARK: - Cost Estimator Section
    private var costEstimatorSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Cost Estimator")
                .font(.headline)
                .foregroundColor(.white)

            VStack(spacing: 12) {
                // Shots slider
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Shots")
                            .foregroundColor(.textSecondary)
                        Spacer()
                        Text("\(shots)")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }

                    Slider(value: Binding(
                        get: { Double(shots) },
                        set: { shots = Int($0) }
                    ), in: 100...8000, step: 100)
                    .tint(.quantumCyan)
                }

                // Priority toggle
                Toggle(isOn: $usePriority) {
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.yellow)
                        Text("Priority Queue")
                            .foregroundColor(.white)
                        if userTier != .premium {
                            Text("(Enterprise)")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .yellow))
                .disabled(userTier != .premium)

                Divider()
                    .background(Color.white.opacity(0.1))

                // Cost breakdown
                if let backend = viewModel.selectedBackend {
                    let estimation = viewModel.calculateCost(
                        circuit: QuantumCircuit(qubitCount: 4),
                        backend: backend,
                        shots: shots,
                        isPriority: usePriority
                    )

                    HStack {
                        Text("Estimated Cost")
                            .foregroundColor(.textSecondary)
                        Spacer()
                        Text(estimation.formattedCredits)
                            .fontWeight(.bold)
                            .foregroundColor(.quantumCyan)
                    }

                    HStack {
                        Text("Wait Time")
                            .foregroundColor(.textSecondary)
                        Spacer()
                        Text(formatTime(estimation.estimatedTime))
                            .fontWeight(.bold)
                            .foregroundColor(usePriority ? .yellow : .white)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.bgCard)
            )
        }
    }

    // MARK: - Your Jobs Section
    private var yourJobsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Jobs")
                .font(.headline)
                .foregroundColor(.white)

            if viewModel.userJobsInQueue.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundColor(.textSecondary)

                    Text("No jobs in queue")
                        .foregroundColor(.textSecondary)

                    Text("Deploy a circuit to see it here")
                        .font(.caption)
                        .foregroundColor(.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.bgCard)
                )
            }
        }
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        if seconds < 60 {
            return "\(Int(seconds))s"
        } else if seconds < 3600 {
            return "\(Int(seconds / 60)) min"
        } else {
            return "\(Int(seconds / 3600))h \(Int((seconds.truncatingRemainder(dividingBy: 3600)) / 60))m"
        }
    }
}

// MARK: - Backend Card
struct BackendCard: View {
    let backend: HardwareBackend
    let isSelected: Bool
    let userHasPriority: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Circle()
                        .fill(backend.status.color)
                        .frame(width: 8, height: 8)

                    Text(backend.status.rawValue)
                        .font(.caption2)
                        .foregroundColor(backend.status.color)

                    Spacer()

                    if backend.isPriority {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.yellow)
                    }
                }

                // Name
                Text(backend.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(backend.provider)
                    .font(.caption)
                    .foregroundColor(.textSecondary)

                Divider()
                    .background(Color.white.opacity(0.1))

                // Specs
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(backend.qubitCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.quantumCyan)
                        Text("Qubits")
                            .font(.caption2)
                            .foregroundColor(.textSecondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text(String(format: "%.2f%%", backend.fidelity * 100))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        Text("Fidelity")
                            .font(.caption2)
                            .foregroundColor(.textSecondary)
                    }
                }

                // Queue info
                HStack {
                    Image(systemName: "person.3.fill")
                        .font(.caption)
                        .foregroundColor(.textSecondary)

                    Text("\(backend.queueDepth) in queue")
                        .font(.caption)
                        .foregroundColor(.textSecondary)

                    Spacer()

                    if backend.isPriority && !userHasPriority {
                        Text("Enterprise")
                            .font(.caption2)
                            .foregroundColor(.quantumOrange)
                    }
                }
            }
            .padding()
            .frame(width: 180)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.bgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? Color.quantumCyan :
                                    (backend.isPriority ? Color.yellow.opacity(0.5) : Color.clear),
                                lineWidth: 2
                            )
                    )
            )
        }
        .opacity(backend.isPriority && !userHasPriority ? 0.6 : 1)
    }
}

// MARK: - Miami Queue Visualization
struct MiamiQueueVisualization: View {
    let queuePositions: [QueuePosition]
    let userHasPriority: Bool

    @State private var animationPhase: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Miami night sky background
                LinearGradient(
                    colors: [
                        Color(hex: "0a0a2e"),
                        Color(hex: "16213e"),
                        Color(hex: "1a1a4e")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Stars/particles
                ForEach(0..<50, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(Double.random(in: 0.3...0.8)))
                        .frame(width: CGFloat.random(in: 1...3))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .opacity(Darwin.sin(animationPhase + Double(i) * 0.1) * 0.5 + 0.5)
                }

                // Queue items as glowing orbs
                ForEach(Array(queuePositions.enumerated()), id: \.element.id) { index, position in
                    let xPos = CGFloat(index + 1) / CGFloat(queuePositions.count + 1) * geometry.size.width
                    let yPos = geometry.size.height * 0.5 + Darwin.sin(animationPhase + Double(index)) * 20

                    ZStack {
                        // Glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        (position.isPriority ? Color.yellow : Color.quantumCyan).opacity(0.6),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 30
                                )
                            )
                            .frame(width: 60, height: 60)

                        // Core
                        Circle()
                            .fill(position.isPriority ? Color.yellow : Color.quantumCyan)
                            .frame(width: position.status == .running ? 20 : 12)

                        // Position number
                        Text("\(position.position)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .offset(y: -30)

                        // Priority badge
                        if position.isPriority {
                            Image(systemName: "bolt.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                                .offset(y: 25)
                        }
                    }
                    .position(x: xPos, y: yPos)
                    .animation(.easeInOut(duration: 0.5), value: position.position)
                }

                // Miami neon line
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geometry.size.height * 0.8))
                    for i in 0..<Int(geometry.size.width / 10) {
                        let x = CGFloat(i * 10)
                        let y = geometry.size.height * 0.8 + Darwin.sin(animationPhase + Double(i) * 0.2) * 10
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                .stroke(
                    LinearGradient(
                        colors: [.quantumCyan, .quantumPurple, Color(hex: "FF1493")],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2
                )

                // Legend
                VStack {
                    HStack(spacing: 20) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.quantumCyan)
                                .frame(width: 8, height: 8)
                            Text("Standard")
                                .font(.caption2)
                                .foregroundColor(.textSecondary)
                        }

                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.yellow)
                                .frame(width: 8, height: 8)
                            Text("Priority")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(8)

                    Spacer()
                }
                .padding(.top, 8)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                animationPhase = .pi * 2
            }
        }
    }
}

// MARK: - Preview
#Preview {
    BridgeMarketplaceView()
        .environmentObject(ProgressViewModel())
}
