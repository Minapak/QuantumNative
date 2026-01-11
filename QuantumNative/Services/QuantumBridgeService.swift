//
//  QuantumBridgeService.swift
//  SwiftQuantumLearning
//
//  QuantumBridge 클라우드 연동 서비스
//  실제 양자 하드웨어 연산 및 에러 피드백 루프
//
//  Created by SwiftQuantum Team
//  Copyright © 2026 SwiftQuantum. All rights reserved.
//

import Foundation
import Combine

// MARK: - QuantumBridge Configuration
struct QuantumBridgeConfig {
    static let baseURL = "https://api.quantumbridge.io/v1"
    static let wsURL = "wss://ws.quantumbridge.io/v1"
    static let timeout: TimeInterval = 30

    // 하버드-MIT 2026 연구 기반 하드웨어 스펙
    struct HardwareSpecs {
        static let maxQubits = 3000
        static let continuousOperationHours = 2.0
        static let faultTolerantLogicalQubits = 96
        static let atomReplenishmentLatencyMs = 50.0
        static let averageFidelity = 0.9985
    }
}

// MARK: - Bridge Job Status
enum BridgeJobStatus: String, Codable {
    case queued = "queued"
    case running = "running"
    case completed = "completed"
    case failed = "failed"
    case cancelled = "cancelled"

    var displayName: String {
        switch self {
        case .queued: return "Queued"
        case .running: return "Running"
        case .completed: return "Completed"
        case .failed: return "Failed"
        case .cancelled: return "Cancelled"
        }
    }

    var isTerminal: Bool {
        switch self {
        case .completed, .failed, .cancelled: return true
        default: return false
        }
    }
}

// MARK: - Bridge Job
struct BridgeJob: Identifiable, Codable {
    let id: String
    let circuitData: QuantumCircuitData
    var status: BridgeJobStatus
    var createdAt: Date
    var startedAt: Date?
    var completedAt: Date?
    var results: BridgeJobResults?
    var error: String?
    var estimatedTime: TimeInterval?
    var queuePosition: Int?

    init(circuitData: QuantumCircuitData) {
        self.id = UUID().uuidString
        self.circuitData = circuitData
        self.status = .queued
        self.createdAt = Date()
    }
}

// MARK: - Bridge Job Results
struct BridgeJobResults: Codable {
    let measurements: [Int: [Int: Int]]  // qubit -> (result -> count)
    let finalStateVector: [ComplexNumber]?
    let fidelity: Double
    let executionTimeMs: Double
    let noiseEvents: [NoiseEventData]
    let atomReplenishments: Int
    let coherenceTimeSeconds: Double

    // 실시간 노이즈 시각화용 데이터
    struct NoiseEventData: Codable {
        let timestamp: TimeInterval
        let qubit: Int
        let type: String
        let magnitude: Double
    }

    struct ComplexNumber: Codable {
        let real: Double
        let imaginary: Double
    }
}

// MARK: - Bridge Error
enum QuantumBridgeError: LocalizedError {
    case notAuthenticated
    case insufficientTier
    case circuitTooLarge
    case hardwareUnavailable
    case executionFailed(String)
    case networkError
    case timeout
    case invalidCircuit

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Please sign in to use QuantumBridge hardware"
        case .insufficientTier:
            return "Upgrade to Pro or Enterprise to access QuantumBridge hardware"
        case .circuitTooLarge:
            return "Circuit exceeds maximum qubit limit for your tier"
        case .hardwareUnavailable:
            return "Quantum hardware is currently unavailable"
        case .executionFailed(let reason):
            return "Execution failed: \(reason)"
        case .networkError:
            return "Network connection error"
        case .timeout:
            return "Request timed out"
        case .invalidCircuit:
            return "Invalid circuit configuration"
        }
    }
}

// MARK: - Real-time Noise Data
struct RealTimeNoiseData: Codable {
    let timestamp: Date
    let qubitNoiseMap: [Int: QubitNoiseLevel]
    let overallFidelity: Double
    let coherenceRemaining: Double
    let atomLossRate: Double
    let replenishmentRate: Double

    struct QubitNoiseLevel: Codable {
        let dephasing: Double
        let relaxation: Double
        let gateError: Double
        let status: QubitStatus

        enum QubitStatus: String, Codable {
            case optimal = "optimal"
            case degraded = "degraded"
            case critical = "critical"
            case replenishing = "replenishing"
        }
    }
}

// MARK: - QuantumBridge Service
@MainActor
class QuantumBridgeService: ObservableObject {
    static let shared = QuantumBridgeService()

    @Published var isConnected = false
    @Published var currentJob: BridgeJob?
    @Published var jobHistory: [BridgeJob] = []
    @Published var realTimeNoiseData: RealTimeNoiseData?
    @Published var isLoadingJobs = false
    @Published var error: QuantumBridgeError?

    // 구독 상태
    @Published var currentTier: SubscriptionTier?
    @Published var remainingCredits: Int = 0

    // 하드웨어 상태
    @Published var hardwareStatus: HardwareStatus = .unknown
    @Published var estimatedQueueTime: TimeInterval = 0

    enum HardwareStatus: String {
        case online = "Online"
        case busy = "Busy"
        case maintenance = "Maintenance"
        case unknown = "Unknown"

        var color: String {
            switch self {
            case .online: return "green"
            case .busy: return "yellow"
            case .maintenance: return "orange"
            case .unknown: return "gray"
            }
        }
    }

    private var webSocketTask: URLSessionWebSocketTask?
    private var cancellables = Set<AnyCancellable>()

    private init() {
        // 시뮬레이션 모드 초기화
        hardwareStatus = .online
        remainingCredits = 100
    }

    // MARK: - Connection Management
    func connect(apiKey: String) async throws {
        guard let url = URL(string: QuantumBridgeConfig.wsURL + "/connect") else {
            throw QuantumBridgeError.networkError
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let session = URLSession.shared
        webSocketTask = session.webSocketTask(with: request)
        webSocketTask?.resume()

        isConnected = true
        await startReceivingMessages()
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
    }

    private func startReceivingMessages() async {
        guard let task = webSocketTask else { return }

        do {
            while isConnected {
                let message = try await task.receive()
                await handleWebSocketMessage(message)
            }
        } catch {
            isConnected = false
        }
    }

    private func handleWebSocketMessage(_ message: URLSessionWebSocketTask.Message) async {
        switch message {
        case .string(let text):
            if let data = text.data(using: .utf8) {
                await processMessage(data)
            }
        case .data(let data):
            await processMessage(data)
        @unknown default:
            break
        }
    }

    private func processMessage(_ data: Data) async {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        // 실시간 노이즈 데이터
        if let noiseData = try? decoder.decode(RealTimeNoiseData.self, from: data) {
            realTimeNoiseData = noiseData
        }

        // Job 상태 업데이트
        if let jobUpdate = try? decoder.decode(BridgeJob.self, from: data) {
            if var current = currentJob, current.id == jobUpdate.id {
                current.status = jobUpdate.status
                current.results = jobUpdate.results
                current.error = jobUpdate.error
                current.completedAt = jobUpdate.completedAt
                currentJob = current
            }
        }
    }

    // MARK: - Job Submission
    func submitCircuit(_ circuit: QuantumCircuit, tier: SubscriptionTier? = nil) async throws -> BridgeJob {
        // 티어 검증
        guard let userTier = tier ?? currentTier else {
            throw QuantumBridgeError.insufficientTier
        }

        // 큐비트 제한 확인
        let maxQubits = getMaxQubits(for: userTier)
        guard circuit.qubitCount <= maxQubits else {
            throw QuantumBridgeError.circuitTooLarge
        }

        let circuitData = circuit.exportForBridge()
        var job = BridgeJob(circuitData: circuitData)

        // 시뮬레이션 모드: 즉시 실행
        job.status = .running
        job.startedAt = Date()
        currentJob = job

        // 회로 실행 (시뮬레이션)
        await circuit.execute()

        // 결과 생성
        let results = generateSimulatedResults(for: circuit)
        job.status = .completed
        job.completedAt = Date()
        job.results = results

        currentJob = job
        jobHistory.insert(job, at: 0)
        remainingCredits -= 1

        return job
    }

    private func generateSimulatedResults(for circuit: QuantumCircuit) -> BridgeJobResults {
        // 측정 결과 집계
        var measurements: [Int: [Int: Int]] = [:]
        for (qubit, result) in circuit.measurementResults {
            measurements[qubit] = [result: 100]
        }

        // 상태 벡터 변환
        let stateVector = circuit.stateVector.map {
            BridgeJobResults.ComplexNumber(real: $0.real, imaginary: $0.imaginary)
        }

        // 노이즈 이벤트 변환
        let noiseEvents = circuit.noiseHistory.map {
            BridgeJobResults.NoiseEventData(
                timestamp: $0.timestamp.timeIntervalSince1970,
                qubit: $0.qubit,
                type: $0.type.rawValue,
                magnitude: $0.magnitude
            )
        }

        return BridgeJobResults(
            measurements: measurements,
            finalStateVector: stateVector,
            fidelity: circuit.fidelity,
            executionTimeMs: circuit.executionTime * 1000,
            noiseEvents: noiseEvents,
            atomReplenishments: circuit.atomReplenishmentCount,
            coherenceTimeSeconds: circuit.coherenceTime
        )
    }

    // MARK: - Tier-based Limits
    func getMaxQubits(for tier: SubscriptionTier) -> Int {
        switch tier {
        case .pro: return 64
        case .premium: return 256
        }
    }

    func getMonthlyCredits(for tier: SubscriptionTier) -> Int {
        switch tier {
        case .pro: return 100
        case .premium: return 1000
        }
    }

    // MARK: - Job Management
    func cancelJob(_ jobId: String) async throws {
        guard var job = currentJob, job.id == jobId else { return }
        job.status = .cancelled
        job.completedAt = Date()
        currentJob = job
    }

    func refreshJobHistory() async {
        isLoadingJobs = true
        // 시뮬레이션: 기존 히스토리 유지
        isLoadingJobs = false
    }

    // MARK: - Hardware Status
    func checkHardwareStatus() async {
        // 시뮬레이션: 항상 온라인
        hardwareStatus = .online
        estimatedQueueTime = Double.random(in: 0...5)
    }

    // MARK: - Noise Visualization Data
    func startNoiseMonitoring(for job: BridgeJob) {
        // 실시간 노이즈 데이터 스트리밍 시작
        Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.generateSimulatedNoiseData(qubitCount: job.circuitData.qubitCount)
            }
            .store(in: &cancellables)
    }

    func stopNoiseMonitoring() {
        cancellables.removeAll()
        realTimeNoiseData = nil
    }

    private func generateSimulatedNoiseData(qubitCount: Int) {
        var qubitNoiseMap: [Int: RealTimeNoiseData.QubitNoiseLevel] = [:]

        for i in 0..<qubitCount {
            let status: RealTimeNoiseData.QubitNoiseLevel.QubitStatus
            let random = Double.random(in: 0...1)
            if random > 0.95 {
                status = .replenishing
            } else if random > 0.85 {
                status = .critical
            } else if random > 0.7 {
                status = .degraded
            } else {
                status = .optimal
            }

            qubitNoiseMap[i] = RealTimeNoiseData.QubitNoiseLevel(
                dephasing: Double.random(in: 0...0.01),
                relaxation: Double.random(in: 0...0.02),
                gateError: Double.random(in: 0...0.001),
                status: status
            )
        }

        realTimeNoiseData = RealTimeNoiseData(
            timestamp: Date(),
            qubitNoiseMap: qubitNoiseMap,
            overallFidelity: Double.random(in: 0.98...0.999),
            coherenceRemaining: Double.random(in: 0.7...1.0),
            atomLossRate: Double.random(in: 0...0.0001),
            replenishmentRate: Double.random(in: 0.99...1.0)
        )
    }

    // MARK: - Efficiency Calculator (마케팅용)
    func calculateEfficiencyImprovement(localTime: TimeInterval, hardwareTime: TimeInterval) -> Double {
        guard hardwareTime > 0 else { return 0 }
        return ((localTime - hardwareTime) / hardwareTime) * 100
    }
}

// MARK: - Premium Feature Availability
extension QuantumBridgeService {
    func checkFeatureAvailability(for feature: PremiumFeature, tier: SubscriptionTier?) -> Bool {
        guard let userTier = tier else { return false }

        switch feature {
        case .continuousOperation:
            return true  // Pro 이상
        case .faultTolerant:
            return userTier == .premium
        case .unlimitedErrorCorrection:
            return userTier == .premium
        case .priorityQueue:
            return userTier == .premium
        case .advancedNoiseVisualization:
            return true  // Pro 이상
        }
    }

    enum PremiumFeature {
        case continuousOperation
        case faultTolerant
        case unlimitedErrorCorrection
        case priorityQueue
        case advancedNoiseVisualization
    }
}
