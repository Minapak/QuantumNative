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
import UIKit

// MARK: - QuantumBridge Configuration
struct QuantumBridgeConfig {
    static let baseURL = "https://api.quantumbridge.io/v1"
    static let wsURL = "wss://ws.quantumbridge.io/v1"
    static let timeout: TimeInterval = 30
    static let pollingInterval: TimeInterval = 3.0

    // 하버드-MIT 2026 연구 기반 하드웨어 스펙
    struct HardwareSpecs {
        static let maxQubits = 3000
        static let continuousOperationHours = 2.0
        static let faultTolerantLogicalQubits = 96
        static let atomReplenishmentLatencyMs = 50.0
        static let averageFidelity = 0.9985
    }
}

// MARK: - Bridge Job API Request
struct BridgeJobRequest: Codable {
    let circuitName: String
    let qubitCount: Int
    let gates: [GateDTO]
    let operationMode: String
    let shots: Int

    struct GateDTO: Codable {
        let type: String
        let targetQubit: Int
        let controlQubit: Int?
        let controlQubit2: Int?

        enum CodingKeys: String, CodingKey {
            case type
            case targetQubit = "target_qubit"
            case controlQubit = "control_qubit"
            case controlQubit2 = "control_qubit_2"
        }
    }

    enum CodingKeys: String, CodingKey {
        case circuitName = "circuit_name"
        case qubitCount = "qubit_count"
        case gates
        case operationMode = "operation_mode"
        case shots
    }

    init(from circuitData: QuantumCircuitData, shots: Int = 1024) {
        self.circuitName = circuitData.name
        self.qubitCount = circuitData.qubitCount
        self.gates = circuitData.gates.map { gate in
            GateDTO(
                type: gate.type.rawValue,
                targetQubit: gate.targetQubit,
                controlQubit: gate.controlQubit,
                controlQubit2: gate.controlQubit2
            )
        }
        self.operationMode = circuitData.operationMode
        self.shots = shots
    }
}

// MARK: - Bridge Job API Response
struct BridgeJobResponse: Codable {
    let jobId: String
    let status: String
    let createdAt: String
    let startedAt: String?
    let completedAt: String?
    let results: BridgeResultsDTO?
    let error: String?
    let estimatedTime: Double?
    let queuePosition: Int?

    enum CodingKeys: String, CodingKey {
        case jobId = "job_id"
        case status
        case createdAt = "created_at"
        case startedAt = "started_at"
        case completedAt = "completed_at"
        case results
        case error
        case estimatedTime = "estimated_time"
        case queuePosition = "queue_position"
    }

    struct BridgeResultsDTO: Codable {
        let measurements: [String: [String: Int]]
        let fidelity: Double
        let executionTimeMs: Double
        let coherenceTimeSeconds: Double?
        let atomReplenishments: Int?

        enum CodingKeys: String, CodingKey {
            case measurements
            case fidelity
            case executionTimeMs = "execution_time_ms"
            case coherenceTimeSeconds = "coherence_time_seconds"
            case atomReplenishments = "atom_replenishments"
        }
    }
}

// MARK: - Terminal Log Entry
struct TerminalLogEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let message: String
    let type: LogType

    enum LogType {
        case info
        case success
        case error
        case warning
        case system

        var color: String {
            switch self {
            case .info: return "cyan"
            case .success: return "green"
            case .error: return "red"
            case .warning: return "yellow"
            case .system: return "gray"
            }
        }

        var prefix: String {
            switch self {
            case .info: return "[INFO]"
            case .success: return "[SUCCESS]"
            case .error: return "[ERROR]"
            case .warning: return "[WARN]"
            case .system: return "[SYS]"
            }
        }
    }
}

// MARK: - User Evidence for Portfolio
struct UserEvidence: Codable, Identifiable {
    let id: UUID
    let jobId: String
    let circuitName: String
    let qubitCount: Int
    let gateCount: Int
    let fidelity: Double
    let executionTimeMs: Double
    let completedAt: Date
    let hardwareBackend: String

    init(from job: BridgeJob, hardwareBackend: String = "IBM Quantum") {
        self.id = UUID()
        self.jobId = job.id
        self.circuitName = job.circuitData.name
        self.qubitCount = job.circuitData.qubitCount
        self.gateCount = job.circuitData.gates.count
        self.fidelity = job.results?.fidelity ?? 0
        self.executionTimeMs = job.results?.executionTimeMs ?? 0
        self.completedAt = job.completedAt ?? Date()
        self.hardwareBackend = hardwareBackend
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

    // 터미널 로그
    @Published var terminalLogs: [TerminalLogEntry] = []

    // 사용자 포트폴리오 증거
    @Published var userEvidences: [UserEvidence] = []

    // 구독 상태
    @Published var currentTier: SubscriptionTier?
    @Published var remainingCredits: Int = 0

    // 하드웨어 상태
    @Published var hardwareStatus: HardwareStatus = .unknown
    @Published var estimatedQueueTime: TimeInterval = 0

    // 폴링 상태
    @Published var isPolling = false
    private var pollingTask: Task<Void, Never>?

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
    private let apiClient = APIClient.shared

    private init() {
        // 시뮬레이션 모드 초기화
        hardwareStatus = .online
        remainingCredits = 100
        loadUserEvidences()
    }

    // MARK: - Terminal Logging
    func addLog(_ message: String, type: TerminalLogEntry.LogType = .info) {
        let entry = TerminalLogEntry(timestamp: Date(), message: message, type: type)
        terminalLogs.append(entry)
        // 최대 100개 로그 유지
        if terminalLogs.count > 100 {
            terminalLogs.removeFirst()
        }
    }

    func clearLogs() {
        terminalLogs.removeAll()
    }

    // MARK: - Haptic Feedback
    func triggerHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    func triggerImpactHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
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

    // MARK: - Job Submission (Real API)
    func submitJob(circuitData: QuantumCircuitData, tier: SubscriptionTier? = nil) async throws -> String {
        // 티어 검증
        guard let userTier = tier ?? currentTier else {
            addLog("Authentication required", type: .error)
            throw QuantumBridgeError.insufficientTier
        }

        // 큐비트 제한 확인
        let maxQubits = getMaxQubits(for: userTier)
        guard circuitData.qubitCount <= maxQubits else {
            addLog("Circuit exceeds \(maxQubits) qubit limit for \(userTier) tier", type: .error)
            throw QuantumBridgeError.circuitTooLarge
        }

        addLog("Preparing circuit for submission...", type: .system)
        addLog("Circuit: \(circuitData.name) | Qubits: \(circuitData.qubitCount) | Gates: \(circuitData.gates.count)", type: .info)

        let request = BridgeJobRequest(from: circuitData)

        do {
            // POST /jobs 엔드포인트 호출
            let response: BridgeJobResponse = try await apiClient.post(
                endpoint: "/api/v1/jobs",
                body: request
            )

            addLog("Job submitted successfully!", type: .success)
            addLog("Job ID: \(response.jobId)", type: .info)

            // BridgeJob 객체 생성
            var job = BridgeJob(circuitData: circuitData)
            job = BridgeJob(circuitData: circuitData)
            currentJob = job
            currentJob?.status = BridgeJobStatus(rawValue: response.status) ?? .queued

            if let queuePosition = response.queuePosition {
                addLog("Queue position: #\(queuePosition)", type: .info)
            }

            triggerImpactHaptic(.light)

            return response.jobId

        } catch {
            addLog("Failed to submit job: \(error.localizedDescription)", type: .error)
            triggerHaptic(.error)
            throw error
        }
    }

    // MARK: - Job Polling
    func startPolling(jobId: String) {
        stopPolling()
        isPolling = true

        addLog("Starting status polling for job \(jobId.prefix(8))...", type: .system)

        pollingTask = Task { [weak self] in
            guard let self = self else { return }

            while !Task.isCancelled {
                let shouldContinue = await self.isPolling
                guard shouldContinue else { break }

                do {
                    let status = try await self.fetchJobStatus(jobId: jobId)

                    await MainActor.run {
                        self.handleStatusUpdate(status)
                    }

                    if status.status == "completed" || status.status == "failed" || status.status == "cancelled" {
                        await MainActor.run {
                            self.isPolling = false
                        }
                        break
                    }

                    try await Task.sleep(nanoseconds: UInt64(QuantumBridgeConfig.pollingInterval * 1_000_000_000))
                } catch {
                    await MainActor.run {
                        self.addLog("Polling error: \(error.localizedDescription)", type: .warning)
                    }
                    try? await Task.sleep(nanoseconds: 5_000_000_000) // 에러 시 5초 대기
                }
            }
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
        isPolling = false
    }

    private func fetchJobStatus(jobId: String) async throws -> BridgeJobResponse {
        let response: BridgeJobResponse = try await apiClient.get(endpoint: "/api/v1/jobs/\(jobId)")
        return response
    }

    private func handleStatusUpdate(_ response: BridgeJobResponse) {
        guard var job = currentJob else { return }

        let previousStatus = job.status
        let newStatus = BridgeJobStatus(rawValue: response.status) ?? .queued

        job.status = newStatus
        job.queuePosition = response.queuePosition
        job.estimatedTime = response.estimatedTime

        // 상태별 로그 출력
        switch newStatus {
        case .queued:
            if let position = response.queuePosition {
                addLog("Waiting in queue... Position: #\(position)", type: .info)
            }

        case .running:
            if previousStatus != .running {
                addLog("IBM 큐비트 초기화 중...", type: .info)
                addLog("Executing quantum circuit on IBM QPU...", type: .system)
                triggerImpactHaptic(.medium)
            }
            addLog("Processing... Estimated time: \(String(format: "%.1f", response.estimatedTime ?? 0))s", type: .info)

        case .completed:
            addLog("Quantum execution completed!", type: .success)
            if let results = response.results {
                job.results = convertResults(results)
                addLog("Fidelity: \(String(format: "%.2f%%", results.fidelity * 100))", type: .success)
                addLog("Execution time: \(String(format: "%.2f", results.executionTimeMs))ms", type: .info)

                // 포트폴리오에 증거 추가
                let evidence = UserEvidence(from: job)
                saveEvidence(evidence)
                addLog("Evidence saved to portfolio!", type: .success)
            }
            job.completedAt = Date()
            triggerHaptic(.success)

        case .failed:
            addLog("Job failed: \(response.error ?? "Unknown error")", type: .error)
            job.error = response.error
            triggerHaptic(.error)

        case .cancelled:
            addLog("Job cancelled", type: .warning)
            triggerHaptic(.warning)
        }

        currentJob = job

        // 완료된 작업을 히스토리에 추가
        if newStatus.isTerminal && !jobHistory.contains(where: { $0.id == job.id }) {
            jobHistory.insert(job, at: 0)
        }
    }

    private func convertResults(_ dto: BridgeJobResponse.BridgeResultsDTO) -> BridgeJobResults {
        // measurements 변환: [String: [String: Int]] -> [Int: [Int: Int]]
        var measurements: [Int: [Int: Int]] = [:]
        for (qubitStr, results) in dto.measurements {
            if let qubit = Int(qubitStr) {
                var qubitResults: [Int: Int] = [:]
                for (resultStr, count) in results {
                    if let result = Int(resultStr) {
                        qubitResults[result] = count
                    }
                }
                measurements[qubit] = qubitResults
            }
        }

        return BridgeJobResults(
            measurements: measurements,
            finalStateVector: nil,
            fidelity: dto.fidelity,
            executionTimeMs: dto.executionTimeMs,
            noiseEvents: [],
            atomReplenishments: dto.atomReplenishments ?? 0,
            coherenceTimeSeconds: dto.coherenceTimeSeconds ?? 0
        )
    }

    // MARK: - Legacy Job Submission (Simulation Mode)
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

        addLog("Starting local simulation...", type: .system)

        // 시뮬레이션 모드: 즉시 실행
        job.status = .running
        job.startedAt = Date()
        currentJob = job

        addLog("IBM 큐비트 초기화 중...", type: .info)
        triggerImpactHaptic(.medium)

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

        addLog("Simulation completed!", type: .success)
        addLog("Fidelity: \(String(format: "%.2f%%", results.fidelity * 100))", type: .success)

        // 포트폴리오 증거 저장
        let evidence = UserEvidence(from: job, hardwareBackend: "Local Simulator")
        saveEvidence(evidence)

        triggerHaptic(.success)

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

// MARK: - User Evidence Persistence
extension QuantumBridgeService {
    private static let evidenceKey = "quantum_user_evidences"

    func saveEvidence(_ evidence: UserEvidence) {
        userEvidences.insert(evidence, at: 0)
        persistEvidences()
    }

    func loadUserEvidences() {
        guard let data = UserDefaults.standard.data(forKey: Self.evidenceKey),
              let evidences = try? JSONDecoder().decode([UserEvidence].self, from: data) else {
            return
        }
        userEvidences = evidences
    }

    private func persistEvidences() {
        guard let data = try? JSONEncoder().encode(userEvidences) else { return }
        UserDefaults.standard.set(data, forKey: Self.evidenceKey)
    }

    func clearEvidences() {
        userEvidences.removeAll()
        UserDefaults.standard.removeObject(forKey: Self.evidenceKey)
    }

    var totalJobsCompleted: Int {
        userEvidences.count
    }

    var averageFidelity: Double {
        guard !userEvidences.isEmpty else { return 0 }
        return userEvidences.reduce(0) { $0 + $1.fidelity } / Double(userEvidences.count)
    }

    var totalQubitsUsed: Int {
        userEvidences.reduce(0) { $0 + $1.qubitCount }
    }
}
