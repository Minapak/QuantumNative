//
//  NoiseVisualizationView.swift
//  SwiftQuantumLearning
//
//  실시간 노이즈 시각화 뷰
//  하버드-MIT 에러 정보 피드백 루프 기반
//
//  Created by SwiftQuantum Team
//  Copyright © 2026 SwiftQuantum. All rights reserved.
//

import SwiftUI
import Charts

// MARK: - Noise Visualization View
struct NoiseVisualizationView: View {
    @ObservedObject var bridgeService = QuantumBridgeService.shared
    @State private var selectedQubit: Int?
    @State private var timeWindow: TimeWindow = .realtime
    @State private var noiseHistory: [NoiseDataPoint] = []

    enum TimeWindow: String, CaseIterable {
        case realtime = "Real-time"
        case minute = "1 min"
        case fiveMinutes = "5 min"

        var seconds: Int {
            switch self {
            case .realtime: return 10
            case .minute: return 60
            case .fiveMinutes: return 300
            }
        }
    }

    struct NoiseDataPoint: Identifiable {
        let id = UUID()
        let timestamp: Date
        let qubit: Int
        let dephasing: Double
        let relaxation: Double
        let gateError: Double
    }

    var body: some View {
        VStack(spacing: 16) {
            // Header
            headerSection

            // Overall Metrics
            overallMetricsSection

            // Qubit Grid
            qubitGridSection

            // Noise Chart
            noiseChartSection

            // Harvard-MIT Status
            harvardMITStatusSection
        }
        .padding()
        .background(Color.bgDark)
        .onAppear {
            generateSampleData()
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Noise Monitor")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Real-time error feedback loop")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            Picker("Time Window", selection: $timeWindow) {
                ForEach(TimeWindow.allCases, id: \.rawValue) { window in
                    Text(window.rawValue).tag(window)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 200)
        }
    }

    // MARK: - Overall Metrics Section
    private var overallMetricsSection: some View {
        HStack(spacing: 16) {
            MetricCard(
                title: "Fidelity",
                value: String(format: "%.3f", bridgeService.realTimeNoiseData?.overallFidelity ?? 0.998),
                icon: "checkmark.seal.fill",
                color: .green
            )

            MetricCard(
                title: "Coherence",
                value: String(format: "%.1f%%", (bridgeService.realTimeNoiseData?.coherenceRemaining ?? 0.95) * 100),
                icon: "waveform.path",
                color: .quantumCyan
            )

            MetricCard(
                title: "Atom Loss",
                value: String(format: "%.4f%%", (bridgeService.realTimeNoiseData?.atomLossRate ?? 0.0001) * 100),
                icon: "atom",
                color: .quantumOrange
            )

            MetricCard(
                title: "Replenishment",
                value: String(format: "%.2f%%", (bridgeService.realTimeNoiseData?.replenishmentRate ?? 0.99) * 100),
                icon: "arrow.triangle.2.circlepath",
                color: .quantumPurple
            )
        }
    }

    // MARK: - Qubit Grid Section
    private var qubitGridSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Qubit Health Map")
                .font(.headline)
                .foregroundColor(.white)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 8), spacing: 8) {
                ForEach(0..<32, id: \.self) { qubit in
                    QubitHealthCell(
                        qubit: qubit,
                        status: getQubitStatus(qubit),
                        isSelected: selectedQubit == qubit
                    ) {
                        withAnimation(.spring()) {
                            selectedQubit = selectedQubit == qubit ? nil : qubit
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.bgCard)
        )
    }

    private func getQubitStatus(_ qubit: Int) -> RealTimeNoiseData.QubitNoiseLevel.QubitStatus {
        bridgeService.realTimeNoiseData?.qubitNoiseMap[qubit]?.status ?? .optimal
    }

    // MARK: - Noise Chart Section
    private var noiseChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Error Rate History")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                if let qubit = selectedQubit {
                    Text("Qubit \(qubit)")
                        .font(.caption)
                        .foregroundColor(.quantumCyan)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.quantumCyan.opacity(0.2)))
                }
            }

            if #available(iOS 16.0, macOS 13.0, *) {
                Chart(noiseHistory.filter { selectedQubit == nil || $0.qubit == selectedQubit }) { point in
                    LineMark(
                        x: .value("Time", point.timestamp),
                        y: .value("Dephasing", point.dephasing),
                        series: .value("Type", "Dephasing")
                    )
                    .foregroundStyle(Color.quantumCyan)
                    .lineStyle(StrokeStyle(lineWidth: 2))

                    LineMark(
                        x: .value("Time", point.timestamp),
                        y: .value("Relaxation", point.relaxation),
                        series: .value("Type", "Relaxation")
                    )
                    .foregroundStyle(Color.quantumPurple)
                    .lineStyle(StrokeStyle(lineWidth: 2))

                    LineMark(
                        x: .value("Time", point.timestamp),
                        y: .value("Gate Error", point.gateError),
                        series: .value("Type", "Gate Error")
                    )
                    .foregroundStyle(Color.quantumOrange)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine()
                            .foregroundStyle(Color.white.opacity(0.1))
                    }
                }
                .chartYAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisGridLine()
                            .foregroundStyle(Color.white.opacity(0.1))
                        AxisValueLabel()
                            .foregroundStyle(Color.textSecondary)
                    }
                }
                .chartLegend(position: .bottom)
                .frame(height: 200)
            } else {
                // Fallback for older iOS versions
                Text("Chart requires iOS 16+")
                    .foregroundColor(.textSecondary)
                    .frame(height: 200)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.bgCard)
        )
    }

    // MARK: - Harvard-MIT Status Section
    private var harvardMITStatusSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "graduationcap.fill")
                    .foregroundColor(.quantumPurple)

                Text("Harvard-MIT Continuous Operation")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("Active")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }

            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Optical Lattice")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    Text("Conveyor Belt Active")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }

                Divider()
                    .frame(height: 30)
                    .background(Color.white.opacity(0.2))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Atom Replenishment")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    Text("< 50ms Latency")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }

                Divider()
                    .frame(height: 30)
                    .background(Color.white.opacity(0.2))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Continuous Runtime")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    Text("2+ Hours Verified")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.quantumCyan)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.quantumPurple.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.quantumPurple.opacity(0.3), lineWidth: 1)
                )
        )
    }

    // MARK: - Sample Data Generation
    private func generateSampleData() {
        let now = Date()
        noiseHistory = (0..<50).map { i in
            NoiseDataPoint(
                timestamp: now.addingTimeInterval(Double(-50 + i)),
                qubit: Int.random(in: 0..<32),
                dephasing: Double.random(in: 0...0.01),
                relaxation: Double.random(in: 0...0.02),
                gateError: Double.random(in: 0...0.001)
            )
        }
    }
}

// MARK: - Metric Card
struct MetricCard: View {
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
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.bgCard)
        )
    }
}

// MARK: - Qubit Health Cell
struct QubitHealthCell: View {
    let qubit: Int
    let status: RealTimeNoiseData.QubitNoiseLevel.QubitStatus
    let isSelected: Bool
    let onTap: () -> Void

    private var statusColor: Color {
        switch status {
        case .optimal: return .green
        case .degraded: return .yellow
        case .critical: return .red
        case .replenishing: return .quantumCyan
        }
    }

    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(statusColor.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isSelected ? Color.white : Color.clear, lineWidth: 2)
                    )

                if status == .replenishing {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.caption2)
                        .foregroundColor(.quantumCyan)
                        .symbolEffect(.rotate)
                } else {
                    Text("\(qubit)")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
            }
            .frame(width: 32, height: 32)
        }
    }
}

// MARK: - Preview
#Preview {
    NoiseVisualizationView()
}
