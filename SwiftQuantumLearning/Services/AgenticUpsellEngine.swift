//
//  AgenticUpsellEngine.swift
//  SwiftQuantumLearning
//
//  지능형 수익화 엔진: Agentic Upsell
//  사용자 학습 데이터 및 회로 설계 능력 분석 기반 AI 업그레이드 제안
//  손실 회피 심리학 극대화
//
//  Created by SwiftQuantum Team
//  Copyright © 2026 SwiftQuantum. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import UserNotifications

// MARK: - Upsell Trigger Type
enum UpsellTriggerType: String, Codable {
    case highErrorRate = "High Error Rate"
    case complexCircuit = "Complex Circuit"
    case frequentUsage = "Frequent Usage"
    case advancedAlgorithm = "Advanced Algorithm"
    case hardwareComparison = "Hardware Comparison"
    case competitorAdvantage = "Competitor Advantage"
    case timeLimit = "Time Limited Offer"
    case streakBonus = "Streak Bonus"

    var priority: Int {
        switch self {
        case .highErrorRate: return 100
        case .hardwareComparison: return 90
        case .advancedAlgorithm: return 80
        case .complexCircuit: return 70
        case .frequentUsage: return 60
        case .competitorAdvantage: return 50
        case .timeLimit: return 40
        case .streakBonus: return 30
        }
    }

    var icon: String {
        switch self {
        case .highErrorRate: return "exclamationmark.triangle.fill"
        case .complexCircuit: return "cpu.fill"
        case .frequentUsage: return "flame.fill"
        case .advancedAlgorithm: return "wand.and.stars"
        case .hardwareComparison: return "bolt.horizontal.fill"
        case .competitorAdvantage: return "chart.line.uptrend.xyaxis"
        case .timeLimit: return "clock.badge.exclamationmark"
        case .streakBonus: return "star.circle.fill"
        }
    }
}

// MARK: - Upsell Recommendation
struct UpsellRecommendation: Identifiable {
    let id: UUID
    let triggerType: UpsellTriggerType
    let targetTier: SubscriptionTier
    let headline: String
    let technicalReason: String
    let benefitStatement: String
    let urgencyMessage: String
    let potentialImprovement: String
    let timestamp: Date
    var dismissed: Bool = false

    init(
        triggerType: UpsellTriggerType,
        targetTier: SubscriptionTier,
        headline: String,
        technicalReason: String,
        benefitStatement: String,
        urgencyMessage: String,
        potentialImprovement: String
    ) {
        self.id = UUID()
        self.triggerType = triggerType
        self.targetTier = targetTier
        self.headline = headline
        self.technicalReason = technicalReason
        self.benefitStatement = benefitStatement
        self.urgencyMessage = urgencyMessage
        self.potentialImprovement = potentialImprovement
        self.timestamp = Date()
    }
}

// MARK: - Circuit Analysis Result
struct CircuitAnalysisResult {
    let circuitName: String
    let qubitCount: Int
    let gateCount: Int
    let estimatedErrorRate: Double
    let complexityScore: Double
    let recommendedMode: ContinuousOperationMode
    let optimizationPotential: Double
    let bottlenecks: [String]
}

// MARK: - Agentic Upsell Engine
@MainActor
class AgenticUpsellEngine: ObservableObject {
    static let shared = AgenticUpsellEngine()

    // MARK: - Published Properties
    @Published var activeRecommendations: [UpsellRecommendation] = []
    @Published var currentAnalysis: CircuitAnalysisResult?
    @Published var showUpsellPopup = false
    @Published var selectedRecommendation: UpsellRecommendation?
    @Published var userEngagementScore: Double = 0
    @Published var conversionProbability: Double = 0

    // MARK: - Configuration
    private let errorRateThreshold: Double = 0.10  // 10% 오차
    private let complexityThreshold: Double = 0.7
    private let frequencyThreshold: Int = 10  // 10회 이상 사용
    private let cooldownPeriod: TimeInterval = 3600  // 1시간 쿨다운

    private var lastUpsellTime: Date?
    private var cancellables = Set<AnyCancellable>()

    private init() {
        setupNotificationPermissions()
    }

    // MARK: - Circuit Analysis
    func analyzeCircuit(_ circuit: QuantumCircuit) -> CircuitAnalysisResult {
        let qubitCount = circuit.qubitCount
        let gateCount = circuit.gates.count

        // 에러율 추정 (게이트 수 및 큐비트 수 기반)
        let baseErrorRate = 0.001  // 게이트당 기본 오류율
        let dephasingFactor = Double(qubitCount) * 0.005
        let gateErrorAccumulation = Double(gateCount) * baseErrorRate
        let estimatedErrorRate = min(1.0, gateErrorAccumulation + dephasingFactor)

        // 복잡도 점수 (0-1)
        let complexityScore = min(1.0, (Double(gateCount) / 20.0) * (Double(qubitCount) / 8.0))

        // 권장 모드 결정
        let recommendedMode: ContinuousOperationMode
        if qubitCount > 64 || complexityScore > 0.8 {
            recommendedMode = .faultTolerant
        } else if qubitCount > 8 || complexityScore > 0.5 {
            recommendedMode = .continuous
        } else {
            recommendedMode = .standard
        }

        // 최적화 잠재력 계산
        let currentFidelity = 1.0 - estimatedErrorRate
        let potentialFidelity = currentFidelity * 1.5  // BOSS 코드 적용 시
        let optimizationPotential = min(1.0, (potentialFidelity - currentFidelity) / currentFidelity)

        // 병목 지점 식별
        var bottlenecks: [String] = []
        if qubitCount > 8 && circuit.operationMode == .standard {
            bottlenecks.append("Qubit count exceeds Standard mode limit")
        }
        if gateCount > 15 {
            bottlenecks.append("High gate count increases cumulative error")
        }
        if circuit.errorCorrectionLayers.isEmpty && estimatedErrorRate > 0.05 {
            bottlenecks.append("No error correction applied")
        }

        let result = CircuitAnalysisResult(
            circuitName: circuit.name,
            qubitCount: qubitCount,
            gateCount: gateCount,
            estimatedErrorRate: estimatedErrorRate,
            complexityScore: complexityScore,
            recommendedMode: recommendedMode,
            optimizationPotential: optimizationPotential,
            bottlenecks: bottlenecks
        )

        currentAnalysis = result
        return result
    }

    // MARK: - Generate Recommendations
    func generateRecommendations(
        circuit: QuantumCircuit,
        userProgress: UserProgress,
        currentTier: SubscriptionTier?
    ) {
        let analysis = analyzeCircuit(circuit)
        var recommendations: [UpsellRecommendation] = []

        // 1. 고에러율 기반 추천 (핵심 트리거)
        if analysis.estimatedErrorRate > errorRateThreshold {
            let errorPercentage = Int(analysis.estimatedErrorRate * 100)
            let improvementPercentage = Int(analysis.optimizationPotential * 100)

            let recommendation = UpsellRecommendation(
                triggerType: .highErrorRate,
                targetTier: .pro,
                headline: "Your Algorithm Needs Error Correction",
                technicalReason: """
                    Your current circuit design shows a \(errorPercentage)% error rate in local simulation. \
                    This exceeds the acceptable threshold for reliable quantum computation.
                    """,
                benefitStatement: """
                    Apply Harvard-MIT's BOSS Error Correction Code to reduce errors by up to \(improvementPercentage)%. \
                    The BOSS code, validated in Nature (Jan 2026), achieves 99.85% fidelity on 3,000+ qubit arrays.
                    """,
                urgencyMessage: "Upgrade to Pro to unlock BOSS error correction before your algorithm produces unreliable results.",
                potentialImprovement: "\(improvementPercentage)% fidelity improvement"
            )
            recommendations.append(recommendation)
        }

        // 2. 복잡한 회로 추천
        if analysis.complexityScore > complexityThreshold && currentTier == nil {
            let recommendation = UpsellRecommendation(
                triggerType: .complexCircuit,
                targetTier: .pro,
                headline: "Your Circuit Complexity Exceeds Free Tier",
                technicalReason: """
                    Circuit '\(analysis.circuitName)' uses \(analysis.gateCount) gates across \(analysis.qubitCount) qubits. \
                    This complexity requires continuous operation mode for accurate simulation.
                    """,
                benefitStatement: """
                    Pro tier enables Harvard-MIT continuous operation with optical lattice atom replenishment, \
                    maintaining coherence for 2+ hours of complex computations.
                    """,
                urgencyMessage: "Don't let circuit complexity limit your quantum potential.",
                potentialImprovement: "64 qubits, 2+ hour coherence"
            )
            recommendations.append(recommendation)
        }

        // 3. 하드웨어 비교 추천
        if analysis.qubitCount > 4 && currentTier != .premium {
            let localTime = Double(analysis.gateCount) * 0.1  // 시뮬레이션 시간 (초)
            let hardwareTime = localTime * 0.01  // 하드웨어는 100배 빠름

            let recommendation = UpsellRecommendation(
                triggerType: .hardwareComparison,
                targetTier: .premium,
                headline: "Real Hardware: 150x Faster Execution",
                technicalReason: """
                    Local simulation: \(String(format: "%.1f", localTime))s
                    QuantumBridge hardware: \(String(format: "%.3f", hardwareTime))s
                    Your '\(analysis.circuitName)' circuit would execute 150x faster on real quantum hardware.
                    """,
                benefitStatement: """
                    Enterprise tier grants direct IBM Quantum access with priority queue. \
                    Deploy your algorithms to ibm_brisbane (127 qubits) with <5 min queue time.
                    """,
                urgencyMessage: "Experience quantum advantage now. Your competitors already are.",
                potentialImprovement: "150x speed, 127 real qubits"
            )
            recommendations.append(recommendation)
        }

        // 4. 고급 알고리즘 감지
        let advancedGates = circuit.gates.filter { $0.type == .toffoli || $0.type == .cnot }
        if advancedGates.count >= 3 && currentTier == nil {
            let recommendation = UpsellRecommendation(
                triggerType: .advancedAlgorithm,
                targetTier: .pro,
                headline: "Advanced Algorithm Detected",
                technicalReason: """
                    Your circuit uses \(advancedGates.count) multi-qubit gates (CNOT/Toffoli). \
                    This indicates an advanced algorithm like Grover's or Shor's.
                    """,
                benefitStatement: """
                    Unlock Level 9-11 courses: Bell States, Grover's Search (O(√N)), and Simon's Algorithm. \
                    Master the algorithms you're already implementing.
                    """,
                urgencyMessage: "Learn the theory behind your practice. $9.99/month unlocks your potential.",
                potentialImprovement: "530+ XP, 3 expert courses"
            )
            recommendations.append(recommendation)
        }

        // 5. 사용 빈도 기반 추천
        if userProgress.practiceSessionsCompleted >= frequencyThreshold && currentTier == nil {
            let recommendation = UpsellRecommendation(
                triggerType: .frequentUsage,
                targetTier: .pro,
                headline: "You're Ready for Pro",
                technicalReason: """
                    You've completed \(userProgress.practiceSessionsCompleted) practice sessions and earned \(userProgress.totalXP) XP. \
                    Your engagement places you in the top 10% of quantum learners.
                    """,
                benefitStatement: """
                    Pro users advance 3x faster with unlimited simulations, advanced courses, and QuantumBridge access.
                    """,
                urgencyMessage: "Your dedication deserves professional tools. Upgrade now and accelerate your journey.",
                potentialImprovement: "3x learning speed"
            )
            recommendations.append(recommendation)
        }

        // 우선순위로 정렬
        activeRecommendations = recommendations.sorted { $0.triggerType.priority > $1.triggerType.priority }

        // 최상위 추천 표시
        if let topRecommendation = activeRecommendations.first, canShowUpsell() {
            selectedRecommendation = topRecommendation
            showUpsellPopup = true
            lastUpsellTime = Date()

            // 푸시 알림 전송
            sendUpsellNotification(topRecommendation)
        }

        // 전환 확률 계산
        calculateConversionProbability(userProgress: userProgress, analysis: analysis)
    }

    // MARK: - Conversion Probability
    private func calculateConversionProbability(userProgress: UserProgress, analysis: CircuitAnalysisResult) {
        var score = 0.0

        // 사용 빈도 (최대 30점)
        score += min(30, Double(userProgress.practiceSessionsCompleted) * 3)

        // XP 레벨 (최대 20점)
        score += min(20, Double(userProgress.userLevel) * 4)

        // 스트릭 (최대 15점)
        score += min(15, Double(userProgress.currentStreak) * 3)

        // 회로 복잡도 (최대 20점)
        score += analysis.complexityScore * 20

        // 에러율이 높을수록 업그레이드 필요성 증가 (최대 15점)
        score += min(15, analysis.estimatedErrorRate * 150)

        conversionProbability = min(1.0, score / 100)
        userEngagementScore = score
    }

    // MARK: - Cooldown Check
    private func canShowUpsell() -> Bool {
        guard let lastTime = lastUpsellTime else { return true }
        return Date().timeIntervalSince(lastTime) > cooldownPeriod
    }

    // MARK: - Push Notifications
    private func setupNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("✅ Notification permission granted")
            }
        }
    }

    private func sendUpsellNotification(_ recommendation: UpsellRecommendation) {
        let content = UNMutableNotificationContent()
        content.title = recommendation.headline
        content.body = recommendation.technicalReason
        content.sound = .default
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(
            identifier: recommendation.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Dismiss Recommendation
    func dismissRecommendation(_ id: UUID) {
        if let index = activeRecommendations.firstIndex(where: { $0.id == id }) {
            activeRecommendations[index].dismissed = true
        }
        showUpsellPopup = false
        selectedRecommendation = nil
    }

    // MARK: - Track Conversion
    func trackConversion(recommendationId: UUID, converted: Bool) {
        // 전환 분석 데이터 저장 (서버로 전송)
        let eventData: [String: Any] = [
            "recommendation_id": recommendationId.uuidString,
            "converted": converted,
            "timestamp": Date().timeIntervalSince1970,
            "conversion_probability": conversionProbability,
            "engagement_score": userEngagementScore
        ]

        print("📊 Conversion Event: \(eventData)")
        // APIClient.shared.post(endpoint: "/analytics/conversion", body: eventData)
    }
}

// MARK: - Upsell Popup View
struct AgenticUpsellPopupView: View {
    @ObservedObject var engine = AgenticUpsellEngine.shared
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @State private var showPremiumUpgrade = false
    @State private var animateGlow = false

    var body: some View {
        if let recommendation = engine.selectedRecommendation {
            ZStack {
                // Background overlay
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture {
                        engine.dismissRecommendation(recommendation.id)
                    }

                // Popup card
                VStack(spacing: 20) {
                    // Header with icon
                    HStack {
                        Image(systemName: recommendation.triggerType.icon)
                            .font(.title)
                            .foregroundColor(.quantumOrange)
                            .symbolEffect(.pulse, value: animateGlow)

                        Spacer()

                        Button {
                            engine.dismissRecommendation(recommendation.id)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.textSecondary)
                        }
                    }

                    // AI Badge
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.quantumCyan)
                        Text("AI Analysis")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.quantumCyan)
                        Image(systemName: "sparkles")
                            .foregroundColor(.yellow)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.quantumCyan.opacity(0.2)))

                    // Headline
                    Text(recommendation.headline)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    // Technical Reason
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Technical Analysis", systemImage: "cpu")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.quantumPurple)

                        Text(recommendation.technicalReason)
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.bgCard)
                    )

                    // Benefit Statement
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Harvard-MIT Solution", systemImage: "graduationcap.fill")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)

                        Text(recommendation.benefitStatement)
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                    )

                    // Improvement Badge
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.green)
                        Text(recommendation.potentialImprovement)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green.opacity(0.2))
                    )

                    // Urgency Message
                    Text(recommendation.urgencyMessage)
                        .font(.caption)
                        .foregroundColor(.quantumOrange)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    // CTA Button
                    Button {
                        engine.trackConversion(recommendationId: recommendation.id, converted: true)
                        showPremiumUpgrade = true
                    } label: {
                        HStack {
                            Text("Upgrade to \(recommendation.targetTier.rawValue.capitalized)")
                                .fontWeight(.bold)
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "FFD700"), Color(hex: "FF8C00")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: Color(hex: "FF8C00").opacity(0.5), radius: animateGlow ? 15 : 5)
                    }

                    // Dismiss text
                    Button {
                        engine.trackConversion(recommendationId: recommendation.id, converted: false)
                        engine.dismissRecommendation(recommendation.id)
                    } label: {
                        Text("Maybe later")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.bgDark)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(
                                    LinearGradient(
                                        colors: [.quantumCyan, .quantumPurple, .quantumOrange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                )
                .padding(24)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    animateGlow = true
                }
            }
            .sheet(isPresented: $showPremiumUpgrade) {
                PremiumUpgradeView()
                    .environmentObject(progressViewModel)
            }
        }
    }
}

// MARK: - Inline Upsell Banner
struct InlineUpsellBanner: View {
    let recommendation: UpsellRecommendation
    let onUpgrade: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: recommendation.triggerType.icon)
                .font(.title2)
                .foregroundColor(.quantumOrange)

            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.headline)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(recommendation.potentialImprovement)
                    .font(.caption)
                    .foregroundColor(.green)
            }

            Spacer()

            Button(action: onUpgrade) {
                Text("Upgrade")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
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

            Button(action: onDismiss) {
                Image(systemName: "xmark")
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
                        .stroke(Color.quantumOrange.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.bgDark.ignoresSafeArea()

        AgenticUpsellPopupView()
            .environmentObject(ProgressViewModel())
            .onAppear {
                let engine = AgenticUpsellEngine.shared
                engine.selectedRecommendation = UpsellRecommendation(
                    triggerType: .highErrorRate,
                    targetTier: .pro,
                    headline: "Your Algorithm Needs Error Correction",
                    technicalReason: "Your current circuit design shows a 15% error rate in local simulation.",
                    benefitStatement: "Apply Harvard-MIT's BOSS Error Correction Code to reduce errors by up to 85%.",
                    urgencyMessage: "Upgrade to Pro before your algorithm produces unreliable results.",
                    potentialImprovement: "85% fidelity improvement"
                )
            }
    }
}
