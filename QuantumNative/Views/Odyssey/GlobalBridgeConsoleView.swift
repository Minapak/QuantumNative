//
//  GlobalBridgeConsoleView.swift
//  SwiftQuantumLearning
//
//  Frame 3: Bridge Terminal - Global Bridge Console
//  Harvard-MIT 2026 Data Comparison with QuantumBridge integration
//  Local simulation vs IBM QPU results with fidelity analysis
//
//  Created by SwiftQuantum Team
//  Copyright © 2026 SwiftQuantum. All rights reserved.
//

import SwiftUI
import Combine

// MARK: - Simulation Result Model
struct SimulationResult: Identifiable {
    let id = UUID()
    let timestamp: Date
    let type: ResultType
    let qubitCount: Int
    let gateCount: Int
    let measurements: [String: Double] // "00": 0.48, "01": 0.02, etc.
    let fidelity: Double
    let executionTime: TimeInterval
    let noiseLevel: Double

    enum ResultType {
        case local
        case ibmQPU

        var displayName: String {
            switch self {
            case .local: return "Local Simulator"
            case .ibmQPU: return "IBM QPU"
            }
        }

        var icon: String {
            switch self {
            case .local: return "laptopcomputer"
            case .ibmQPU: return "server.rack"
            }
        }

        var color: Color {
            switch self {
            case .local: return .quantumCyan
            case .ibmQPU: return .solarGold
            }
        }
    }
}

// MARK: - Harvard-MIT 2026 Benchmark
struct HarvardMITBenchmark {
    let name: String
    let targetFidelity: Double
    let logicalQubits: Int
    let coherenceTime: TimeInterval
    let errorThreshold: Double

    static let faultTolerant = HarvardMITBenchmark(
        name: "Fault-Tolerant Threshold",
        targetFidelity: 0.99,
        logicalQubits: 96,
        coherenceTime: 7200, // 2+ hours
        errorThreshold: 0.001
    )

    static let continuousOperation = HarvardMITBenchmark(
        name: "Continuous Operation",
        targetFidelity: 0.98,
        logicalQubits: 64,
        coherenceTime: 3600,
        errorThreshold: 0.005
    )
}

// MARK: - Global Bridge Console ViewModel
@MainActor
class GlobalBridgeConsoleViewModel: ObservableObject {
    @Published var localResult: SimulationResult?
    @Published var ibmResult: SimulationResult?
    @Published var isRunningLocal = false
    @Published var isRunningIBM = false
    @Published var comparisonFidelity: Double = 0
    @Published var showSuccessAnimation = false

    private let bridgeService = QuantumBridgeService.shared

    // Generate mock local simulation result
    func runLocalSimulation(qubitCount: Int, gateCount: Int) async {
        isRunningLocal = true

        // Simulate processing time
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        let result = SimulationResult(
            timestamp: Date(),
            type: .local,
            qubitCount: qubitCount,
            gateCount: gateCount,
            measurements: generateMockMeasurements(qubitCount: qubitCount),
            fidelity: Double.random(in: 0.95...0.99),
            executionTime: Double.random(in: 0.1...0.5),
            noiseLevel: 0
        )

        localResult = result
        isRunningLocal = false
        calculateComparisonFidelity()
    }

    // Generate mock IBM QPU result
    func runIBMSimulation(qubitCount: Int, gateCount: Int) async {
        isRunningIBM = true

        // Simulate longer processing time for IBM
        try? await Task.sleep(nanoseconds: 2_500_000_000)

        let result = SimulationResult(
            timestamp: Date(),
            type: .ibmQPU,
            qubitCount: qubitCount,
            gateCount: gateCount,
            measurements: generateMockMeasurements(qubitCount: qubitCount, withNoise: true),
            fidelity: Double.random(in: 0.90...0.97),
            executionTime: Double.random(in: 1.0...3.0),
            noiseLevel: Double.random(in: 0.01...0.05)
        )

        ibmResult = result
        isRunningIBM = false
        calculateComparisonFidelity()

        // Trigger success animation
        if comparisonFidelity > 0.85 {
            withAnimation(.spring()) {
                showSuccessAnimation = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    self.showSuccessAnimation = false
                }
            }
        }
    }

    private func generateMockMeasurements(qubitCount: Int, withNoise: Bool = false) -> [String: Double] {
        var measurements: [String: Double] = [:]
        let stateCount = 1 << qubitCount
        var remaining = 1.0

        for i in 0..<stateCount {
            let binaryString = String(i, radix: 2).padLeft(toLength: qubitCount, withPad: "0")
            var prob = Double.random(in: 0...remaining)

            if withNoise {
                prob *= Double.random(in: 0.9...1.1)
            }

            if i == stateCount - 1 {
                prob = remaining
            }

            measurements[binaryString] = max(0, min(prob, remaining))
            remaining -= measurements[binaryString]!
        }

        // Normalize
        let total = measurements.values.reduce(0, +)
        for key in measurements.keys {
            measurements[key] = (measurements[key] ?? 0) / total
        }

        return measurements
    }

    private func calculateComparisonFidelity() {
        guard let local = localResult, let ibm = ibmResult else {
            comparisonFidelity = 0
            return
        }

        // Simple fidelity comparison
        var fidelity = 0.0
        for (state, localProb) in local.measurements {
            if let ibmProb = ibm.measurements[state] {
                fidelity += sqrt(localProb * ibmProb)
            }
        }

        comparisonFidelity = fidelity * fidelity
    }
}

// MARK: - Global Bridge Console View
struct GlobalBridgeConsoleView: View {
    @StateObject private var viewModel = GlobalBridgeConsoleViewModel()
    @StateObject private var storeKitService = StoreKitService.shared
    @ObservedObject var translationManager = QuantumTranslationManager.shared

    @State private var selectedQubitCount = 2
    @State private var selectedGateCount = 4
    @State private var showPaywall = false

    let benchmark = HarvardMITBenchmark.faultTolerant

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.bgDark.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Console Header
                        consoleHeader

                        // Circuit Configuration
                        circuitConfiguration

                        // Results Comparison (Side by Side)
                        resultsComparison

                        // Harvard-MIT Benchmark
                        benchmarkSection

                        // Fidelity Analysis
                        if viewModel.comparisonFidelity > 0 {
                            fidelityAnalysis
                        }

                        Spacer().frame(height: 100)
                    }
                    .padding(.horizontal)
                }

                // Success Animation Overlay
                if viewModel.showSuccessAnimation {
                    successOverlay
                }
            }
            .navigationTitle(NSLocalizedString("bridge.title", comment: ""))
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    // MARK: - Console Header
    private var consoleHeader: some View {
        HStack(spacing: 16) {
            // Bridge Status
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 10, height: 10)
                    .overlay(
                        Circle()
                            .stroke(Color.green.opacity(0.5), lineWidth: 2)
                            .scaleEffect(1.3)
                    )

                Text(NSLocalizedString("bridge.online", comment: ""))
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            // Harvard-MIT Badge
            HStack(spacing: 6) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.solarGold)
                Text("Harvard-MIT 2026")
                    .font(.caption2.bold())
                    .foregroundColor(.solarGold)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.solarGold.opacity(0.15))
            )

            // Premium Indicator
            if storeKitService.isPremium {
                Text("PRO")
                    .font(.caption2.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.fireGradient)
                    )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.bgCard)
        )
    }

    // MARK: - Circuit Configuration
    private var circuitConfiguration: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(NSLocalizedString("bridge.circuitConfig", comment: ""))
                .font(.headline)
                .foregroundColor(.white)

            HStack(spacing: 16) {
                // Qubit Count
                VStack(alignment: .leading, spacing: 8) {
                    Text(NSLocalizedString("bridge.qubits", comment: ""))
                        .font(.caption)
                        .foregroundColor(.textSecondary)

                    Stepper(value: $selectedQubitCount, in: 1...8) {
                        Text("\(selectedQubitCount)")
                            .font(.title2.bold())
                            .foregroundColor(.quantumCyan)
                    }
                }
                .padding()
                .background(Color.bgCard)
                .cornerRadius(12)

                // Gate Count
                VStack(alignment: .leading, spacing: 8) {
                    Text(NSLocalizedString("bridge.gates", comment: ""))
                        .font(.caption)
                        .foregroundColor(.textSecondary)

                    Stepper(value: $selectedGateCount, in: 1...20) {
                        Text("\(selectedGateCount)")
                            .font(.title2.bold())
                            .foregroundColor(.quantumPurple)
                    }
                }
                .padding()
                .background(Color.bgCard)
                .cornerRadius(12)
            }

            // Run Buttons
            HStack(spacing: 12) {
                Button {
                    Task {
                        await viewModel.runLocalSimulation(qubitCount: selectedQubitCount, gateCount: selectedGateCount)
                    }
                } label: {
                    HStack {
                        if viewModel.isRunningLocal {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "play.fill")
                        }
                        Text(NSLocalizedString("bridge.runLocal", comment: ""))
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.quantumCyan)
                    )
                }
                .disabled(viewModel.isRunningLocal)

                Button {
                    if !storeKitService.isPremium {
                        showPaywall = true
                    } else {
                        Task {
                            await viewModel.runIBMSimulation(qubitCount: selectedQubitCount, gateCount: selectedGateCount)
                        }
                    }
                } label: {
                    HStack {
                        if viewModel.isRunningIBM {
                            ProgressView()
                                .tint(.black)
                        } else {
                            Image(systemName: "bolt.fill")
                        }
                        Text(NSLocalizedString("bridge.runIBM", comment: ""))
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(colors: [.solarGold, .miamiGlow], startPoint: .leading, endPoint: .trailing)
                            )
                    )
                }
                .disabled(viewModel.isRunningIBM)
            }
        }
    }

    // MARK: - Results Comparison
    private var resultsComparison: some View {
        HStack(spacing: 12) {
            // Local Result
            resultCard(result: viewModel.localResult, type: .local, isLoading: viewModel.isRunningLocal)

            // IBM Result
            resultCard(result: viewModel.ibmResult, type: .ibmQPU, isLoading: viewModel.isRunningIBM)
        }
    }

    private func resultCard(result: SimulationResult?, type: SimulationResult.ResultType, isLoading: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: type.icon)
                    .foregroundColor(type.color)
                Text(type.displayName)
                    .font(.caption.bold())
                    .foregroundColor(.white)
            }

            if isLoading {
                VStack {
                    ProgressView()
                        .tint(type.color)
                    Text(NSLocalizedString("bridge.processing", comment: ""))
                        .font(.caption2)
                        .foregroundColor(.textSecondary)
                }
                .frame(maxWidth: .infinity, minHeight: 120)
            } else if let result = result {
                // Fidelity
                VStack(spacing: 4) {
                    Text(String(format: "%.1f%%", result.fidelity * 100))
                        .font(.title.bold())
                        .foregroundColor(type.color)
                    Text(NSLocalizedString("bridge.fidelity", comment: ""))
                        .font(.caption2)
                        .foregroundColor(.textSecondary)
                }

                Divider().background(Color.white.opacity(0.1))

                // Measurements histogram (simplified)
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(result.measurements.keys.sorted().prefix(4)), id: \.self) { state in
                        HStack {
                            Text("|\(state)⟩")
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundColor(.textSecondary)
                            Spacer()
                            GeometryReader { geo in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(type.color.opacity(0.8))
                                    .frame(width: geo.size.width * (result.measurements[state] ?? 0))
                            }
                            .frame(height: 8)
                            Text(String(format: "%.0f%%", (result.measurements[state] ?? 0) * 100))
                                .font(.caption2)
                                .foregroundColor(.textTertiary)
                                .frame(width: 30, alignment: .trailing)
                        }
                    }
                }

                // Execution time
                Text(String(format: NSLocalizedString("bridge.execTime", comment: ""), result.executionTime))
                    .font(.caption2)
                    .foregroundColor(.textTertiary)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: type.icon)
                        .font(.largeTitle)
                        .foregroundColor(.textTertiary)
                    Text(NSLocalizedString("bridge.noResult", comment: ""))
                        .font(.caption)
                        .foregroundColor(.textTertiary)
                }
                .frame(maxWidth: .infinity, minHeight: 120)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(type.color.opacity(0.3), lineWidth: 1)
                )
        )
    }

    // MARK: - Benchmark Section
    private var benchmarkSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.doc.horizontal")
                    .foregroundColor(.solarGold)
                Text(NSLocalizedString("bridge.harvardMIT", comment: ""))
                    .font(.headline)
                    .foregroundColor(.white)
            }

            HStack(spacing: 16) {
                benchmarkItem(title: NSLocalizedString("bridge.benchmark.fidelity", comment: ""), value: "\(Int(benchmark.targetFidelity * 100))%", icon: "checkmark.seal")
                benchmarkItem(title: NSLocalizedString("bridge.benchmark.qubits", comment: ""), value: "\(benchmark.logicalQubits)", icon: "cpu")
                benchmarkItem(title: NSLocalizedString("bridge.benchmark.coherence", comment: ""), value: "2h+", icon: "clock")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.solarGold.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private func benchmarkItem(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.solarGold)
            Text(value)
                .font(.headline.bold())
                .foregroundColor(.white)
            Text(title)
                .font(.caption2)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Fidelity Analysis
    private var fidelityAnalysis: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("bridge.fidelityAnalysis", comment: ""))
                .font(.headline)
                .foregroundColor(.white)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(NSLocalizedString("bridge.comparisonFidelity", comment: ""))
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    Text(String(format: "%.2f%%", viewModel.comparisonFidelity * 100))
                        .font(.title.bold())
                        .foregroundColor(viewModel.comparisonFidelity > 0.9 ? .completed : .quantumOrange)
                }

                Spacer()

                // Harvard-MIT comparison
                VStack(alignment: .trailing, spacing: 4) {
                    Text(NSLocalizedString("bridge.harvardMITTarget", comment: ""))
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    Text(String(format: "%.0f%%", benchmark.targetFidelity * 100))
                        .font(.title2.bold())
                        .foregroundColor(.solarGold)
                }
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            viewModel.comparisonFidelity > 0.9
                                ? LinearGradient(colors: [.completed, .quantumGreen], startPoint: .leading, endPoint: .trailing)
                                : LinearGradient(colors: [.quantumOrange, .miamiSunrise], startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(width: geo.size.width * viewModel.comparisonFidelity)

                    // Target marker
                    Rectangle()
                        .fill(Color.solarGold)
                        .frame(width: 2)
                        .offset(x: geo.size.width * benchmark.targetFidelity - 1)
                }
            }
            .frame(height: 12)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.bgCard)
        )
    }

    // MARK: - Success Overlay
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Gold particles effect (simplified)
                ZStack {
                    ForEach(0..<20, id: \.self) { i in
                        Circle()
                            .fill(Color.solarGold)
                            .frame(width: CGFloat.random(in: 4...12))
                            .offset(
                                x: CGFloat.random(in: -100...100),
                                y: CGFloat.random(in: -100...100)
                            )
                            .opacity(Double.random(in: 0.3...1.0))
                    }

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(colors: [.solarGold, .miamiGlow], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                }

                Text(NSLocalizedString("bridge.success.title", comment: ""))
                    .font(.title.bold())
                    .foregroundColor(.white)

                Text(NSLocalizedString("bridge.success.subtitle", comment: ""))
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)

                // Miami beach wave sound indicator
                HStack(spacing: 8) {
                    Image(systemName: "speaker.wave.3.fill")
                        .foregroundColor(.quantumCyan)
                    Text("🌊 Miami Beach")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(40)
        }
        .transition(.opacity)
    }
}

// MARK: - Preview
#Preview {
    GlobalBridgeConsoleView()
}
