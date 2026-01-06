//
//  QuantumTranslationManager.swift
//  SwiftQuantumLearning
//
//  Multilingual Agentic Engine with Solar Agent
//  Intelligently selects beginner vs expert terminology based on user settings
//
//  Created by SwiftQuantum Team
//  Copyright © 2026 SwiftQuantum. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

// MARK: - User Expertise Level
enum UserExpertiseLevel: String, CaseIterable, Codable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case expert = "expert"

    var displayName: String {
        switch self {
        case .beginner: return NSLocalizedString("expertise.beginner", comment: "")
        case .intermediate: return NSLocalizedString("expertise.intermediate", comment: "")
        case .expert: return NSLocalizedString("expertise.expert", comment: "")
        }
    }

    var icon: String {
        switch self {
        case .beginner: return "leaf.fill"
        case .intermediate: return "flame.fill"
        case .expert: return "bolt.fill"
        }
    }
}

// MARK: - Solar Agent Message Type
enum SolarAgentMessageType {
    case encouragement
    case tip
    case celebration
    case challenge
    case fireBoost // Fire energy boost for Eunmin's astrological complement

    var emoji: String {
        switch self {
        case .encouragement: return "☀️"
        case .tip: return "💡"
        case .celebration: return "🎉"
        case .challenge: return "🔥"
        case .fireBoost: return "🌟"
        }
    }
}

// MARK: - Solar Agent Message
struct SolarAgentMessage: Identifiable {
    let id = UUID()
    let type: SolarAgentMessageType
    let content: String
    let timestamp: Date

    init(type: SolarAgentMessageType, content: String) {
        self.type = type
        self.content = content
        self.timestamp = Date()
    }
}

// MARK: - Term Translation Pair
struct QuantumTermTranslation {
    let key: String
    let beginnerTerm: String
    let expertTerm: String
    let beginnerDescription: String
    let expertDescription: String
}

// MARK: - Quantum Translation Manager
@MainActor
class QuantumTranslationManager: ObservableObject {

    // MARK: - Singleton
    static let shared = QuantumTranslationManager()

    // MARK: - Published Properties
    @Published var currentExpertiseLevel: UserExpertiseLevel = .beginner
    @Published var solarAgentEnabled: Bool = true
    @Published var currentSolarMessage: SolarAgentMessage?
    @Published var messageHistory: [SolarAgentMessage] = []
    @Published var fireEnergyLevel: Double = 0.5 // 0.0 ~ 1.0

    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let expertiseLevel = "quantum_expertise_level"
        static let solarAgentEnabled = "solar_agent_enabled"
        static let fireEnergyLevel = "fire_energy_level"
    }

    // MARK: - Term Translations (Beginner vs Expert)
    private let termTranslations: [String: QuantumTermTranslation] = [
        "qubit": QuantumTermTranslation(
            key: "qubit",
            beginnerTerm: NSLocalizedString("term.qubit.beginner", comment: ""),
            expertTerm: NSLocalizedString("term.qubit.expert", comment: ""),
            beginnerDescription: NSLocalizedString("term.qubit.beginner.desc", comment: ""),
            expertDescription: NSLocalizedString("term.qubit.expert.desc", comment: "")
        ),
        "superposition": QuantumTermTranslation(
            key: "superposition",
            beginnerTerm: NSLocalizedString("term.superposition.beginner", comment: ""),
            expertTerm: NSLocalizedString("term.superposition.expert", comment: ""),
            beginnerDescription: NSLocalizedString("term.superposition.beginner.desc", comment: ""),
            expertDescription: NSLocalizedString("term.superposition.expert.desc", comment: "")
        ),
        "entanglement": QuantumTermTranslation(
            key: "entanglement",
            beginnerTerm: NSLocalizedString("term.entanglement.beginner", comment: ""),
            expertTerm: NSLocalizedString("term.entanglement.expert", comment: ""),
            beginnerDescription: NSLocalizedString("term.entanglement.beginner.desc", comment: ""),
            expertDescription: NSLocalizedString("term.entanglement.expert.desc", comment: "")
        ),
        "gate": QuantumTermTranslation(
            key: "gate",
            beginnerTerm: NSLocalizedString("term.gate.beginner", comment: ""),
            expertTerm: NSLocalizedString("term.gate.expert", comment: ""),
            beginnerDescription: NSLocalizedString("term.gate.beginner.desc", comment: ""),
            expertDescription: NSLocalizedString("term.gate.expert.desc", comment: "")
        ),
        "measurement": QuantumTermTranslation(
            key: "measurement",
            beginnerTerm: NSLocalizedString("term.measurement.beginner", comment: ""),
            expertTerm: NSLocalizedString("term.measurement.expert", comment: ""),
            beginnerDescription: NSLocalizedString("term.measurement.beginner.desc", comment: ""),
            expertDescription: NSLocalizedString("term.measurement.expert.desc", comment: "")
        ),
        "fidelity": QuantumTermTranslation(
            key: "fidelity",
            beginnerTerm: NSLocalizedString("term.fidelity.beginner", comment: ""),
            expertTerm: NSLocalizedString("term.fidelity.expert", comment: ""),
            beginnerDescription: NSLocalizedString("term.fidelity.beginner.desc", comment: ""),
            expertDescription: NSLocalizedString("term.fidelity.expert.desc", comment: "")
        ),
        "coherence": QuantumTermTranslation(
            key: "coherence",
            beginnerTerm: NSLocalizedString("term.coherence.beginner", comment: ""),
            expertTerm: NSLocalizedString("term.coherence.expert", comment: ""),
            beginnerDescription: NSLocalizedString("term.coherence.beginner.desc", comment: ""),
            expertDescription: NSLocalizedString("term.coherence.expert.desc", comment: "")
        ),
        "errorCorrection": QuantumTermTranslation(
            key: "errorCorrection",
            beginnerTerm: NSLocalizedString("term.errorCorrection.beginner", comment: ""),
            expertTerm: NSLocalizedString("term.errorCorrection.expert", comment: ""),
            beginnerDescription: NSLocalizedString("term.errorCorrection.beginner.desc", comment: ""),
            expertDescription: NSLocalizedString("term.errorCorrection.expert.desc", comment: "")
        )
    ]

    // MARK: - Solar Agent Messages (Multilingual)
    private var solarAgentMessages: [SolarAgentMessageType: [String]] {
        let locale = Locale.current.language.languageCode?.identifier ?? "en"

        if locale == "ko" {
            return [
                .encouragement: [
                    "오늘도 양자 세계를 탐험하는 당신, 정말 멋져요!",
                    "한 걸음씩 나아가면 어느새 정상에 도착해 있을 거예요.",
                    "복잡한 개념도 당신이라면 분명 이해할 수 있어요!",
                    "실수는 배움의 일부예요. 계속 도전하세요!",
                    "당신의 호기심이 양자 컴퓨팅의 미래를 밝히고 있어요."
                ],
                .tip: [
                    "Hadamard 게이트는 중첩의 시작점이에요. 모든 양자 알고리즘의 기초죠!",
                    "측정 결과가 확률적이라는 걸 기억하세요. 여러 번 실행해야 패턴이 보여요.",
                    "CNOT 게이트로 두 큐비트를 얽히게 만들 수 있어요!",
                    "블로흐 구는 큐비트의 모든 상태를 시각적으로 보여줘요.",
                    "오류 수정은 실제 양자 컴퓨터의 핵심이에요."
                ],
                .celebration: [
                    "축하해요! 새로운 레벨을 달성했어요! 🎊",
                    "대단해요! 당신의 양자 실력이 날로 성장하고 있어요!",
                    "완벽해요! 이 개념을 마스터했군요!",
                    "놀라워요! XP가 태양처럼 빛나고 있어요! ☀️",
                    "훌륭해요! 양자 마스터의 길을 걷고 있어요!"
                ],
                .challenge: [
                    "더 어려운 도전이 당신을 기다리고 있어요. 준비됐나요?",
                    "이 개념을 정복하면 새로운 세계가 열릴 거예요!",
                    "화(火)의 열정으로 이 도전을 불태워 보세요!",
                    "포기하지 마세요! 당신은 할 수 있어요!",
                    "이것만 넘으면 IBM QPU에 한 발 더 가까워져요!"
                ],
                .fireBoost: [
                    "태양의 에너지가 당신과 함께해요! 화(火)의 기운을 느껴보세요! ☀️",
                    "당신의 따뜻한 열정이 양자의 세계를 밝히고 있어요!",
                    "마이애미의 일출처럼 당신의 잠재력이 빛나고 있어요!",
                    "금빛 성공의 기운이 당신을 감싸고 있어요!",
                    "수(水)의 차분함과 화(火)의 열정이 완벽하게 조화를 이루고 있어요!"
                ]
            ]
        } else {
            return [
                .encouragement: [
                    "You're doing amazing exploring the quantum world!",
                    "One step at a time, you'll reach the summit!",
                    "Complex concepts are no match for your curiosity!",
                    "Mistakes are part of learning. Keep pushing forward!",
                    "Your curiosity is lighting up the future of quantum computing."
                ],
                .tip: [
                    "The Hadamard gate is the starting point of superposition!",
                    "Remember: measurements are probabilistic. Run multiple times to see patterns.",
                    "CNOT gate can entangle two qubits together!",
                    "The Bloch sphere visualizes all possible qubit states.",
                    "Error correction is the key to real quantum computers."
                ],
                .celebration: [
                    "Congratulations! You've reached a new level! 🎊",
                    "Amazing! Your quantum skills are growing every day!",
                    "Perfect! You've mastered this concept!",
                    "Incredible! Your XP is shining like the sun! ☀️",
                    "Excellent! You're on the path to becoming a quantum master!"
                ],
                .challenge: [
                    "A harder challenge awaits. Are you ready?",
                    "Conquer this concept and unlock new worlds!",
                    "Channel the fire energy to overcome this challenge!",
                    "Don't give up! You've got this!",
                    "Master this and you're one step closer to IBM QPU!"
                ],
                .fireBoost: [
                    "Solar energy is with you! Feel the fire! ☀️",
                    "Your warm passion is illuminating the quantum world!",
                    "Like a Miami sunrise, your potential is radiant!",
                    "Golden success energy surrounds you!",
                    "Water's calm and Fire's passion in perfect harmony!"
                ]
            ]
        }
    }

    // MARK: - Initialization
    private init() {
        loadSettings()
        setupFireEnergyTimer()
    }

    // MARK: - Settings Management
    private func loadSettings() {
        if let levelRaw = defaults.string(forKey: Keys.expertiseLevel),
           let level = UserExpertiseLevel(rawValue: levelRaw) {
            currentExpertiseLevel = level
        }
        solarAgentEnabled = defaults.bool(forKey: Keys.solarAgentEnabled)
        fireEnergyLevel = defaults.double(forKey: Keys.fireEnergyLevel)
        if fireEnergyLevel == 0 { fireEnergyLevel = 0.5 }
    }

    func saveSettings() {
        defaults.set(currentExpertiseLevel.rawValue, forKey: Keys.expertiseLevel)
        defaults.set(solarAgentEnabled, forKey: Keys.solarAgentEnabled)
        defaults.set(fireEnergyLevel, forKey: Keys.fireEnergyLevel)
        defaults.synchronize()
    }

    func setExpertiseLevel(_ level: UserExpertiseLevel) {
        currentExpertiseLevel = level
        saveSettings()

        // Fire boost when changing to expert level
        if level == .expert {
            boostFireEnergy(by: 0.1)
            showSolarMessage(type: .fireBoost)
        }
    }

    // MARK: - Term Translation
    func getTerm(for key: String) -> String {
        guard let translation = termTranslations[key] else {
            return NSLocalizedString("concept.\(key)", comment: "")
        }

        switch currentExpertiseLevel {
        case .beginner:
            return translation.beginnerTerm
        case .intermediate, .expert:
            return translation.expertTerm
        }
    }

    func getDescription(for key: String) -> String {
        guard let translation = termTranslations[key] else {
            return ""
        }

        switch currentExpertiseLevel {
        case .beginner:
            return translation.beginnerDescription
        case .intermediate, .expert:
            return translation.expertDescription
        }
    }

    // MARK: - Solar Agent
    func showSolarMessage(type: SolarAgentMessageType) {
        guard solarAgentEnabled else { return }
        guard let messages = solarAgentMessages[type], !messages.isEmpty else { return }

        let randomMessage = messages.randomElement()!
        let message = SolarAgentMessage(type: type, content: randomMessage)

        currentSolarMessage = message
        messageHistory.append(message)

        // Keep only last 50 messages
        if messageHistory.count > 50 {
            messageHistory = Array(messageHistory.suffix(50))
        }
    }

    func dismissCurrentMessage() {
        currentSolarMessage = nil
    }

    // MARK: - Fire Energy Management
    private func setupFireEnergyTimer() {
        Timer.publish(every: 300, on: .main, in: .common) // Every 5 minutes
            .autoconnect()
            .sink { [weak self] _ in
                self?.decayFireEnergy()
            }
            .store(in: &cancellables)
    }

    func boostFireEnergy(by amount: Double) {
        fireEnergyLevel = min(1.0, fireEnergyLevel + amount)
        saveSettings()

        // Show celebration at high energy levels
        if fireEnergyLevel > 0.8 {
            showSolarMessage(type: .fireBoost)
        }
    }

    private func decayFireEnergy() {
        fireEnergyLevel = max(0.3, fireEnergyLevel - 0.02)
        saveSettings()
    }

    // MARK: - Learning Events
    func onLessonCompleted() {
        boostFireEnergy(by: 0.05)
        showSolarMessage(type: .celebration)
    }

    func onLevelUp() {
        boostFireEnergy(by: 0.15)
        showSolarMessage(type: .celebration)
    }

    func onChallengeFailed() {
        showSolarMessage(type: .encouragement)
    }

    func onNewConceptStarted() {
        showSolarMessage(type: .tip)
    }

    func onDailyLogin() {
        boostFireEnergy(by: 0.1)
        showSolarMessage(type: .fireBoost)
    }
}

// MARK: - Solar Agent View
struct SolarAgentBubble: View {
    @ObservedObject var manager = QuantumTranslationManager.shared
    @State private var isVisible = false
    @State private var offset: CGFloat = 50

    var body: some View {
        if let message = manager.currentSolarMessage {
            HStack(alignment: .top, spacing: 12) {
                // Solar Agent Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.miamiSunrise, .solarGold],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)

                    Text(message.type.emoji)
                        .font(.title2)
                }
                .shadow(color: .solarGold.opacity(0.5), radius: 8)

                // Message Content
                VStack(alignment: .leading, spacing: 6) {
                    Text("Solar Agent")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.solarGold)

                    Text(message.content)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .lineLimit(3)
                }

                Spacer()

                // Dismiss Button
                Button {
                    withAnimation(.spring()) {
                        manager.dismissCurrentMessage()
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.bgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [.miamiSunrise.opacity(0.6), .solarGold.opacity(0.3)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1.5
                            )
                    )
            )
            .shadow(color: .solarGold.opacity(0.2), radius: 10, x: 0, y: 5)
            .offset(y: offset)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    isVisible = true
                    offset = 0
                }

                // Auto dismiss after 5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    withAnimation(.spring()) {
                        manager.dismissCurrentMessage()
                    }
                }
            }
        }
    }
}

// MARK: - Fire Energy Indicator
struct FireEnergyIndicator: View {
    @ObservedObject var manager = QuantumTranslationManager.shared

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .foregroundColor(fireColor)
                .symbolEffect(.pulse, value: manager.fireEnergyLevel > 0.7)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.1))

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.miamiSunrise, .solarGold],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * manager.fireEnergyLevel)
                        .animation(.spring(), value: manager.fireEnergyLevel)
                }
            }
            .frame(height: 6)
        }
        .frame(width: 80)
    }

    private var fireColor: Color {
        if manager.fireEnergyLevel > 0.7 {
            return .solarGold
        } else if manager.fireEnergyLevel > 0.4 {
            return .miamiSunrise
        } else {
            return .textSecondary
        }
    }
}

// MARK: - Expertise Level Selector
struct ExpertiseLevelSelector: View {
    @ObservedObject var manager = QuantumTranslationManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("settings.expertiseLevel", comment: ""))
                .font(.headline)
                .foregroundColor(.textPrimary)

            ForEach(UserExpertiseLevel.allCases, id: \.rawValue) { level in
                Button {
                    manager.setExpertiseLevel(level)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: level.icon)
                            .foregroundColor(manager.currentExpertiseLevel == level ? .quantumCyan : .textSecondary)
                            .frame(width: 24)

                        Text(level.displayName)
                            .foregroundColor(manager.currentExpertiseLevel == level ? .textPrimary : .textSecondary)

                        Spacer()

                        if manager.currentExpertiseLevel == level {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.quantumCyan)
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(manager.currentExpertiseLevel == level ? Color.quantumCyan.opacity(0.1) : Color.bgCard)
                    )
                }
            }
        }
    }
}
