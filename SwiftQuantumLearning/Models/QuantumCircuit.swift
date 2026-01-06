//
//  QuantumCircuit.swift
//  SwiftQuantumLearning
//
//  Harvard-MIT 2026 논문 기반 양자 회로 시뮬레이션
//  3,000 큐비트 어레이 연속 가동 아키텍처 참조
//
//  Created by SwiftQuantum Team
//  Copyright © 2026 SwiftQuantum. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Quantum Gate Types
enum QuantumGateType: String, CaseIterable, Codable {
    case hadamard = "H"
    case pauliX = "X"
    case pauliY = "Y"
    case pauliZ = "Z"
    case phase = "S"
    case tGate = "T"
    case cnot = "CNOT"
    case swap = "SWAP"
    case toffoli = "CCX"
    case measure = "M"

    var displayName: String {
        switch self {
        case .hadamard: return "Hadamard"
        case .pauliX: return "Pauli-X"
        case .pauliY: return "Pauli-Y"
        case .pauliZ: return "Pauli-Z"
        case .phase: return "Phase (S)"
        case .tGate: return "T Gate"
        case .cnot: return "CNOT"
        case .swap: return "SWAP"
        case .toffoli: return "Toffoli"
        case .measure: return "Measure"
        }
    }

    var isSingleQubit: Bool {
        switch self {
        case .hadamard, .pauliX, .pauliY, .pauliZ, .phase, .tGate, .measure:
            return true
        case .cnot, .swap, .toffoli:
            return false
        }
    }

    var color: Color {
        switch self {
        case .hadamard: return .quantumCyan
        case .pauliX, .pauliY, .pauliZ: return .quantumPurple
        case .phase, .tGate: return .quantumOrange
        case .cnot, .swap: return .green
        case .toffoli: return .yellow
        case .measure: return .gray
        }
    }
}

// MARK: - Quantum Gate
struct QuantumGate: Identifiable, Codable {
    let id: UUID
    let type: QuantumGateType
    let targetQubit: Int
    var controlQubit: Int?
    var controlQubit2: Int?  // For Toffoli
    var timestamp: Date

    init(type: QuantumGateType, targetQubit: Int, controlQubit: Int? = nil, controlQubit2: Int? = nil) {
        self.id = UUID()
        self.type = type
        self.targetQubit = targetQubit
        self.controlQubit = controlQubit
        self.controlQubit2 = controlQubit2
        self.timestamp = Date()
    }
}

// MARK: - Noise Model (Harvard-MIT 2026 기반)
struct NoiseModel: Codable {
    var dephasingRate: Double = 0.001  // T2 감쇠
    var relaxationRate: Double = 0.002 // T1 감쇠
    var gateErrorRate: Double = 0.0005 // 단일 게이트 오류율
    var measurementError: Double = 0.01
    var atomLossRate: Double = 0.0001  // 원자 소실률 (하버드-MIT 논문 핵심)

    // 연속 가동 모드에서의 에러 보정 효율
    var continuousOperationCorrection: Double = 0.95

    static let ideal = NoiseModel(
        dephasingRate: 0,
        relaxationRate: 0,
        gateErrorRate: 0,
        measurementError: 0,
        atomLossRate: 0
    )

    static let harvardMIT2026 = NoiseModel(
        dephasingRate: 0.0005,
        relaxationRate: 0.001,
        gateErrorRate: 0.0001,
        measurementError: 0.005,
        atomLossRate: 0.00005,
        continuousOperationCorrection: 0.98
    )

    static let realistic = NoiseModel()
}

// MARK: - Continuous Operation Mode (하버드-MIT 2026 핵심 기능)
enum ContinuousOperationMode: String, CaseIterable {
    case standard = "Standard"
    case continuous = "Continuous (Harvard-MIT)"
    case faultTolerant = "Fault-Tolerant"

    var description: String {
        switch self {
        case .standard:
            return "Basic quantum simulation"
        case .continuous:
            return "2+ hour continuous operation with optical lattice conveyor belt atom replenishment (Harvard-MIT 2026)"
        case .faultTolerant:
            return "96+ logical qubit fault-tolerant architecture with error correction layers"
        }
    }

    var requiredTier: SubscriptionTier? {
        switch self {
        case .standard: return nil
        case .continuous: return .pro
        case .faultTolerant: return .premium
        }
    }

    var maxQubits: Int {
        switch self {
        case .standard: return 8
        case .continuous: return 64
        case .faultTolerant: return 256  // 논리 큐비트 기준
        }
    }
}

// MARK: - Error Correction Layer (결함 허용 교육 과정용)
struct ErrorCorrectionLayer: Identifiable, Codable {
    let id: UUID
    var name: String
    var code: ErrorCorrectionCode
    var syndromeQubits: Int
    var dataQubits: Int
    var threshold: Double

    init(name: String, code: ErrorCorrectionCode, syndromeQubits: Int, dataQubits: Int, threshold: Double) {
        self.id = UUID()
        self.name = name
        self.code = code
        self.syndromeQubits = syndromeQubits
        self.dataQubits = dataQubits
        self.threshold = threshold
    }
}

enum ErrorCorrectionCode: String, CaseIterable, Codable {
    case surfaceCode = "Surface Code"
    case steaneCode = "Steane [[7,1,3]]"
    case shorCode = "Shor [[9,1,3]]"
    case colorCode = "Color Code"
    case bossCode = "BOSS Code"  // 2026 하버드-MIT 논문 참조

    var logicalQubitsPerPhysical: Double {
        switch self {
        case .surfaceCode: return 0.1
        case .steaneCode: return 0.143
        case .shorCode: return 0.111
        case .colorCode: return 0.12
        case .bossCode: return 0.15  // 향상된 효율
        }
    }
}

// MARK: - Quantum Circuit
@MainActor
class QuantumCircuit: ObservableObject, Codable {
    @Published var name: String
    @Published var qubitCount: Int
    @Published var gates: [QuantumGate]
    @Published var stateVector: [Complex]
    @Published var measurementResults: [Int: Int]  // qubit -> result
    @Published var operationMode: ContinuousOperationMode
    @Published var noiseModel: NoiseModel
    @Published var errorCorrectionLayers: [ErrorCorrectionLayer]
    @Published var isRunning: Bool = false
    @Published var executionTime: TimeInterval = 0
    @Published var noiseHistory: [NoiseEvent] = []

    // 하버드-MIT 연속 가동 메트릭
    @Published var atomReplenishmentCount: Int = 0
    @Published var coherenceTime: TimeInterval = 0
    @Published var fidelity: Double = 1.0

    private var cancellables = Set<AnyCancellable>()

    struct NoiseEvent: Identifiable, Codable {
        let id: UUID
        let timestamp: Date
        let qubit: Int
        let type: NoiseType
        let magnitude: Double

        enum NoiseType: String, Codable {
            case dephasing
            case relaxation
            case gateError
            case atomLoss
            case measurementError
        }
    }

    enum CodingKeys: String, CodingKey {
        case name, qubitCount, gates, stateVector, measurementResults
        case operationMode, noiseModel, errorCorrectionLayers
        case atomReplenishmentCount, coherenceTime, fidelity, noiseHistory
    }

    init(name: String = "New Circuit", qubitCount: Int = 2, operationMode: ContinuousOperationMode = .standard) {
        self.name = name
        self.qubitCount = min(qubitCount, operationMode.maxQubits)
        self.gates = []
        self.stateVector = Self.initializeStateVector(qubitCount: qubitCount)
        self.measurementResults = [:]
        self.operationMode = operationMode
        self.noiseModel = operationMode == .standard ? .ideal : .harvardMIT2026
        self.errorCorrectionLayers = []
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        qubitCount = try container.decode(Int.self, forKey: .qubitCount)
        gates = try container.decode([QuantumGate].self, forKey: .gates)
        stateVector = try container.decode([Complex].self, forKey: .stateVector)
        measurementResults = try container.decode([Int: Int].self, forKey: .measurementResults)
        let modeRaw = try container.decode(String.self, forKey: .operationMode)
        operationMode = ContinuousOperationMode(rawValue: modeRaw) ?? .standard
        noiseModel = try container.decode(NoiseModel.self, forKey: .noiseModel)
        errorCorrectionLayers = try container.decode([ErrorCorrectionLayer].self, forKey: .errorCorrectionLayers)
        atomReplenishmentCount = try container.decodeIfPresent(Int.self, forKey: .atomReplenishmentCount) ?? 0
        coherenceTime = try container.decodeIfPresent(TimeInterval.self, forKey: .coherenceTime) ?? 0
        fidelity = try container.decodeIfPresent(Double.self, forKey: .fidelity) ?? 1.0
        noiseHistory = try container.decodeIfPresent([NoiseEvent].self, forKey: .noiseHistory) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(qubitCount, forKey: .qubitCount)
        try container.encode(gates, forKey: .gates)
        try container.encode(stateVector, forKey: .stateVector)
        try container.encode(measurementResults, forKey: .measurementResults)
        try container.encode(operationMode.rawValue, forKey: .operationMode)
        try container.encode(noiseModel, forKey: .noiseModel)
        try container.encode(errorCorrectionLayers, forKey: .errorCorrectionLayers)
        try container.encode(atomReplenishmentCount, forKey: .atomReplenishmentCount)
        try container.encode(coherenceTime, forKey: .coherenceTime)
        try container.encode(fidelity, forKey: .fidelity)
        try container.encode(noiseHistory, forKey: .noiseHistory)
    }

    // MARK: - State Vector Initialization
    static func initializeStateVector(qubitCount: Int) -> [Complex] {
        let size = 1 << qubitCount  // 2^n
        var vector = [Complex](repeating: .zero, count: size)
        vector[0] = Complex(real: 1, imaginary: 0)
        return vector
    }

    // MARK: - Gate Operations
    func addGate(_ type: QuantumGateType, target: Int, control: Int? = nil, control2: Int? = nil) {
        guard target < qubitCount else { return }
        if let ctrl = control, ctrl >= qubitCount { return }

        let gate = QuantumGate(type: type, targetQubit: target, controlQubit: control, controlQubit2: control2)
        gates.append(gate)
    }

    func removeGate(at index: Int) {
        guard index < gates.count else { return }
        gates.remove(at: index)
    }

    func clearGates() {
        gates.removeAll()
        reset()
    }

    // MARK: - Circuit Execution
    func execute() async {
        isRunning = true
        let startTime = Date()
        reset()

        for gate in gates {
            await applyGate(gate)

            // 노이즈 적용 (연속 가동 모드에서)
            if operationMode != .standard {
                await applyNoise(to: gate.targetQubit)
            }

            // 원자 소실 및 보충 시뮬레이션 (하버드-MIT 2026)
            if operationMode == .continuous || operationMode == .faultTolerant {
                await simulateAtomReplenishment()
            }

            // 에러 수정 레이어 적용
            if operationMode == .faultTolerant && !errorCorrectionLayers.isEmpty {
                await applyErrorCorrection()
            }
        }

        executionTime = Date().timeIntervalSince(startTime)
        isRunning = false
    }

    private func applyGate(_ gate: QuantumGate) async {
        switch gate.type {
        case .hadamard:
            applyHadamard(to: gate.targetQubit)
        case .pauliX:
            applyPauliX(to: gate.targetQubit)
        case .pauliY:
            applyPauliY(to: gate.targetQubit)
        case .pauliZ:
            applyPauliZ(to: gate.targetQubit)
        case .phase:
            applyPhase(to: gate.targetQubit)
        case .tGate:
            applyT(to: gate.targetQubit)
        case .cnot:
            if let control = gate.controlQubit {
                applyCNOT(control: control, target: gate.targetQubit)
            }
        case .swap:
            if let other = gate.controlQubit {
                applySWAP(qubit1: gate.targetQubit, qubit2: other)
            }
        case .toffoli:
            if let control1 = gate.controlQubit, let control2 = gate.controlQubit2 {
                applyToffoli(control1: control1, control2: control2, target: gate.targetQubit)
            }
        case .measure:
            _ = measure(qubit: gate.targetQubit)
        }
    }

    // MARK: - Single Qubit Gates
    private func applyHadamard(to qubit: Int) {
        let factor = 1.0 / sqrt(2.0)
        let size = stateVector.count
        let mask = 1 << qubit

        for i in stride(from: 0, to: size, by: mask * 2) {
            for j in i..<(i + mask) {
                let a = stateVector[j]
                let b = stateVector[j + mask]
                stateVector[j] = Complex(
                    real: factor * (a.real + b.real),
                    imaginary: factor * (a.imaginary + b.imaginary)
                )
                stateVector[j + mask] = Complex(
                    real: factor * (a.real - b.real),
                    imaginary: factor * (a.imaginary - b.imaginary)
                )
            }
        }
    }

    private func applyPauliX(to qubit: Int) {
        let size = stateVector.count
        let mask = 1 << qubit

        for i in stride(from: 0, to: size, by: mask * 2) {
            for j in i..<(i + mask) {
                let temp = stateVector[j]
                stateVector[j] = stateVector[j + mask]
                stateVector[j + mask] = temp
            }
        }
    }

    private func applyPauliY(to qubit: Int) {
        let size = stateVector.count
        let mask = 1 << qubit

        for i in stride(from: 0, to: size, by: mask * 2) {
            for j in i..<(i + mask) {
                let a = stateVector[j]
                let b = stateVector[j + mask]
                stateVector[j] = Complex(real: b.imaginary, imaginary: -b.real)
                stateVector[j + mask] = Complex(real: -a.imaginary, imaginary: a.real)
            }
        }
    }

    private func applyPauliZ(to qubit: Int) {
        let size = stateVector.count
        let mask = 1 << qubit

        for i in stride(from: 0, to: size, by: mask * 2) {
            for j in (i + mask)..<(i + mask * 2) {
                stateVector[j] = Complex(
                    real: -stateVector[j].real,
                    imaginary: -stateVector[j].imaginary
                )
            }
        }
    }

    private func applyPhase(to qubit: Int) {
        let size = stateVector.count
        let mask = 1 << qubit

        for i in stride(from: 0, to: size, by: mask * 2) {
            for j in (i + mask)..<(i + mask * 2) {
                let a = stateVector[j]
                stateVector[j] = Complex(real: -a.imaginary, imaginary: a.real)
            }
        }
    }

    private func applyT(to qubit: Int) {
        let size = stateVector.count
        let mask = 1 << qubit
        let cos45 = cos(.pi / 4)
        let sin45 = sin(.pi / 4)

        for i in stride(from: 0, to: size, by: mask * 2) {
            for j in (i + mask)..<(i + mask * 2) {
                let a = stateVector[j]
                stateVector[j] = Complex(
                    real: cos45 * a.real - sin45 * a.imaginary,
                    imaginary: sin45 * a.real + cos45 * a.imaginary
                )
            }
        }
    }

    // MARK: - Multi-Qubit Gates
    private func applyCNOT(control: Int, target: Int) {
        let size = stateVector.count
        let controlMask = 1 << control
        let targetMask = 1 << target

        for i in 0..<size {
            if (i & controlMask) != 0 && (i & targetMask) == 0 {
                let j = i | targetMask
                let temp = stateVector[i]
                stateVector[i] = stateVector[j]
                stateVector[j] = temp
            }
        }
    }

    private func applySWAP(qubit1: Int, qubit2: Int) {
        let size = stateVector.count
        let mask1 = 1 << qubit1
        let mask2 = 1 << qubit2

        for i in 0..<size {
            let bit1 = (i & mask1) != 0
            let bit2 = (i & mask2) != 0

            if bit1 != bit2 {
                var j = i
                j ^= mask1
                j ^= mask2
                if i < j {
                    let temp = stateVector[i]
                    stateVector[i] = stateVector[j]
                    stateVector[j] = temp
                }
            }
        }
    }

    private func applyToffoli(control1: Int, control2: Int, target: Int) {
        let size = stateVector.count
        let mask1 = 1 << control1
        let mask2 = 1 << control2
        let targetMask = 1 << target

        for i in 0..<size {
            if (i & mask1) != 0 && (i & mask2) != 0 && (i & targetMask) == 0 {
                let j = i | targetMask
                let temp = stateVector[i]
                stateVector[i] = stateVector[j]
                stateVector[j] = temp
            }
        }
    }

    // MARK: - Measurement
    func measure(qubit: Int) -> Int {
        let mask = 1 << qubit
        var prob0 = 0.0

        for i in 0..<stateVector.count {
            if (i & mask) == 0 {
                prob0 += stateVector[i].magnitude * stateVector[i].magnitude
            }
        }

        // 노이즈 적용
        if operationMode != .standard {
            prob0 += Double.random(in: -noiseModel.measurementError...noiseModel.measurementError)
            prob0 = max(0, min(1, prob0))
        }

        let result = Double.random(in: 0...1) < prob0 ? 0 : 1
        measurementResults[qubit] = result

        // 상태 붕괴
        collapseState(qubit: qubit, result: result)

        return result
    }

    private func collapseState(qubit: Int, result: Int) {
        let mask = 1 << qubit
        var norm = 0.0

        // 측정 결과에 해당하지 않는 상태 제거
        for i in 0..<stateVector.count {
            let bit = (i & mask) != 0 ? 1 : 0
            if bit != result {
                stateVector[i] = .zero
            } else {
                norm += stateVector[i].magnitude * stateVector[i].magnitude
            }
        }

        // 정규화
        if norm > 0 {
            let factor = 1.0 / sqrt(norm)
            for i in 0..<stateVector.count {
                stateVector[i] = Complex(
                    real: stateVector[i].real * factor,
                    imaginary: stateVector[i].imaginary * factor
                )
            }
        }
    }

    // MARK: - Noise Simulation (하버드-MIT 2026)
    private func applyNoise(to qubit: Int) async {
        // 디페이징 노이즈
        if Double.random(in: 0...1) < noiseModel.dephasingRate {
            let event = NoiseEvent(
                id: UUID(),
                timestamp: Date(),
                qubit: qubit,
                type: .dephasing,
                magnitude: noiseModel.dephasingRate
            )
            noiseHistory.append(event)
            applyRandomPhase(to: qubit)
        }

        // 이완 노이즈
        if Double.random(in: 0...1) < noiseModel.relaxationRate {
            let event = NoiseEvent(
                id: UUID(),
                timestamp: Date(),
                qubit: qubit,
                type: .relaxation,
                magnitude: noiseModel.relaxationRate
            )
            noiseHistory.append(event)
            // T1 감쇠 시뮬레이션
            applyRelaxation(to: qubit)
        }

        // 원자 소실 (하버드-MIT 핵심)
        if Double.random(in: 0...1) < noiseModel.atomLossRate {
            let event = NoiseEvent(
                id: UUID(),
                timestamp: Date(),
                qubit: qubit,
                type: .atomLoss,
                magnitude: noiseModel.atomLossRate
            )
            noiseHistory.append(event)
        }

        // 연속 가동 모드에서 충실도 업데이트
        fidelity *= (1.0 - noiseModel.gateErrorRate)
        fidelity *= noiseModel.continuousOperationCorrection
        fidelity = max(0.5, fidelity)  // 최소 충실도 유지
    }

    private func applyRandomPhase(to qubit: Int) {
        let randomPhase = Double.random(in: 0...(2 * .pi))
        let cos = Foundation.cos(randomPhase)
        let sin = Foundation.sin(randomPhase)
        let mask = 1 << qubit

        for i in 0..<stateVector.count {
            if (i & mask) != 0 {
                let a = stateVector[i]
                stateVector[i] = Complex(
                    real: cos * a.real - sin * a.imaginary,
                    imaginary: sin * a.real + cos * a.imaginary
                )
            }
        }
    }

    private func applyRelaxation(to qubit: Int) {
        let dampingFactor = 0.99
        let mask = 1 << qubit

        for i in 0..<stateVector.count {
            if (i & mask) != 0 {
                stateVector[i] = Complex(
                    real: stateVector[i].real * dampingFactor,
                    imaginary: stateVector[i].imaginary * dampingFactor
                )
            }
        }
    }

    // MARK: - Atom Replenishment (하버드-MIT 2026 광학 격자 컨베이어 벨트)
    private func simulateAtomReplenishment() async {
        // 원자 소실 감지 및 보충 시뮬레이션
        let lossEvents = noiseHistory.filter { $0.type == .atomLoss }

        if lossEvents.count > atomReplenishmentCount {
            atomReplenishmentCount = lossEvents.count

            // 보충 후 충실도 회복
            fidelity = min(1.0, fidelity * 1.02)
            coherenceTime += 0.1
        }
    }

    // MARK: - Error Correction (결함 허용 아키텍처)
    func addErrorCorrectionLayer(_ layer: ErrorCorrectionLayer) {
        errorCorrectionLayers.append(layer)
    }

    private func applyErrorCorrection() async {
        for layer in errorCorrectionLayers {
            // 신드롬 측정 시뮬레이션
            let syndromeDetected = Double.random(in: 0...1) < layer.threshold

            if syndromeDetected {
                // 에러 수정 적용
                fidelity = min(1.0, fidelity * 1.01)
            }
        }
    }

    // MARK: - Utility Methods
    func reset() {
        stateVector = Self.initializeStateVector(qubitCount: qubitCount)
        measurementResults = [:]
        noiseHistory = []
        atomReplenishmentCount = 0
        fidelity = 1.0
        coherenceTime = 0
    }

    func getProbabilities() -> [Double] {
        stateVector.map { $0.magnitude * $0.magnitude }
    }

    func getStateDescription() -> String {
        var parts: [String] = []
        let probabilities = getProbabilities()

        for (index, prob) in probabilities.enumerated() where prob > 0.001 {
            let binary = String(index, radix: 2).padLeft(toLength: qubitCount, withPad: "0")
            let amplitude = stateVector[index]
            let amplitudeStr = String(format: "%.3f", amplitude.real)
            parts.append("\(amplitudeStr)|" + binary + "⟩")
        }

        return parts.isEmpty ? "|" + String(repeating: "0", count: qubitCount) + "⟩" : parts.joined(separator: " + ")
    }

    // MARK: - Export for QuantumBridge
    func exportForBridge() -> QuantumCircuitData {
        QuantumCircuitData(
            name: name,
            qubitCount: qubitCount,
            gates: gates,
            operationMode: operationMode.rawValue,
            noiseModel: noiseModel,
            errorCorrectionLayers: errorCorrectionLayers
        )
    }
}

// MARK: - Export Data Structure
struct QuantumCircuitData: Codable {
    let name: String
    let qubitCount: Int
    let gates: [QuantumGate]
    let operationMode: String
    let noiseModel: NoiseModel
    let errorCorrectionLayers: [ErrorCorrectionLayer]
    let timestamp: Date = Date()
    let version: String = "1.0.0"

    var jsonString: String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

// MARK: - String Extension
extension String {
    func padLeft(toLength length: Int, withPad pad: String) -> String {
        let count = length - self.count
        if count > 0 {
            return String(repeating: pad, count: count) + self
        }
        return self
    }
}
