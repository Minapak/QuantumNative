//
//  LearnViewModel.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Learning Strategy Models
struct MemoryTrigger: Identifiable {
    let id: String
    let title: String
    let description: String
    let mnemonic: String
    let difficulty: String
}

struct ConceptMap: Identifiable {
    let id: String
    let title: String
    let centralConcept: String
    let relatedConcepts: [String]
    let connections: [String: [String]]
    let description: String
}

struct FeynmanExplanation: Identifiable {
    let id: String
    let conceptName: String
    let simpleExplanation: String
    let details: String
    let analogies: [String]
    let commonMisconceptions: [String]
}

// MARK: - Learn View Model
@MainActor
class LearnViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var tracks: [LearningTrack] = []
    @Published var currentTrack: Track = .beginner
    @Published var isLoading = false
    @Published var completedLevels: Set<Int> = []
    @Published var errorMessage: String?
    @Published var availableLevels: [LevelListResponse] = []
    
    // MARK: - Learning Strategy Properties
    @Published var memoryTriggers: [MemoryTrigger] = []
    @Published var conceptMaps: [ConceptMap] = []
    @Published var feynmanExplanations: [FeynmanExplanation] = []
    @Published var selectedStrategy: LearningStrategy = .memory
    @Published var strategiesLoaded = false
    
    // MARK: - User Learning Preferences
    @Published var preferredStrategy: LearningStrategy = .memory
    @Published var learningPace: LearningPace = .balanced
    @Published var showHints = true
    @Published var enableGameification = true
    
    enum LearningStrategy: String, CaseIterable {
        case memory = "Memory Triggers"
        case conceptMap = "Concept Maps"
        case feynman = "Feynman Technique"
        
        var icon: String {
            switch self {
            case .memory: return "brain.head.profile"
            case .conceptMap: return "networkprobe"
            case .feynman: return "sparkles"
            }
        }
        
        var description: String {
            switch self {
            case .memory: return "Mnemonics and memory anchors"
            case .conceptMap: return "Visual relationship mapping"
            case .feynman: return "Explain it simply"
            }
        }
    }
    
    enum LearningPace: String, CaseIterable {
        case slow = "Slow"
        case balanced = "Balanced"
        case fast = "Fast"
    }
    
    // MARK: - Private Properties
    private let learningService = LearningService.shared
    private let progressService = ProgressService.shared
    private let apiClient = APIClient.shared
    
    // MARK: - Initialization
    init() {
        print("✅ LearnViewModel initialized")
    }
    
    // MARK: - Public Methods
    
    /// Load all tracks and learning content
    func loadTracks() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // 각 트랙별로 레벨 로드
                for track in Track.allCases {
                    let levels: [LevelListResponse] = try await apiClient.get(
                        endpoint: "/api/v1/learning/levels/\(track.rawValue.lowercased())"
                    )
                    
                    DispatchQueue.main.async {
                        self.availableLevels.append(contentsOf: levels)
                    }
                }
                
                DispatchQueue.main.async {
                    self.createTracksFromLevels()
                    self.loadProgress()
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    self.createTracksFromLocalData()
                }
                print("❌ Failed to load tracks: \(error)")
            }
        }
    }
    
    /// Load learning strategies for current level
    func loadLearningStrategies(for level: LearningLevel) {
        strategiesLoaded = false
        
        memoryTriggers = generateMemoryTriggers(for: level)
        conceptMaps = generateConceptMaps(for: level)
        feynmanExplanations = generateFeynmanExplanations(for: level)
        
        strategiesLoaded = true
    }
    
    /// Load user progress
    func loadProgress() {
        completedLevels = progressService.userProgress.completedLevels
    }
    
    /// Check if level is unlocked
    func isLevelUnlocked(_ levelId: Int) -> Bool {
        guard let level = LearningLevel.allLevels.first(where: { $0.id == levelId }) else {
            return false
        }
        
        if level.number == 1 {
            return true
        }
        
        for prereq in level.prerequisites {
            if !completedLevels.contains(prereq) {
                return false
            }
        }
        
        return true
    }
    
    /// Complete a level
    func completeLevel(_ levelId: Int) {
        Task {
            do {
                let request = CompleteLevelRequest(quiz_score: nil)
                let _: CompleteLevelResponse = try await apiClient.post(
                    endpoint: "/api/v1/learning/progress/complete/\(levelId)/practice",
                    body: request
                )
                
                DispatchQueue.main.async {
                    self.progressService.completeLevel(levelId)
                    self.loadProgress()
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                print("❌ Failed to complete level: \(error)")
            }
        }
    }
    
    /// Get next recommended level
    func getNextLevel() -> LearningLevel? {
        for level in LearningLevel.allLevels {
            if !completedLevels.contains(level.id) && isLevelUnlocked(level.id) {
                return level
            }
        }
        return nil
    }
    
    /// Get progress for track
    func getProgress(for track: LearningTrack) -> Double {
        let completedInTrack = track.levels.filter { completedLevels.contains($0.id) }.count
        return track.levels.isEmpty ? 0 : Double(completedInTrack) / Double(track.levels.count)
    }
    
    /// Update learning preference
    func setPreferredStrategy(_ strategy: LearningStrategy) {
        preferredStrategy = strategy
        selectedStrategy = strategy
    }
    
    /// Update learning pace
    func setLearningPace(_ pace: LearningPace) {
        learningPace = pace
    }
    
    // MARK: - Private Methods
    
    private func createTracksFromLevels() {
        // Use the new Quantum Curriculum Content from Localizable strings
        tracks = QuantumCurriculumContent.allTracks.enumerated().map { index, track in
            track.toLearningTrack(index: index)
        }

        // Fallback to old method if no tracks available
        if tracks.isEmpty {
            let beginnerLevels = LearningLevel.allLevels.filter { $0.track == .beginner }
            let intermediateLevels = LearningLevel.allLevels.filter { $0.track == .intermediate }
            let advancedLevels = LearningLevel.allLevels.filter { $0.track == .advanced }

            tracks = [
                LearningTrack(
                    name: "Beginner",
                    description: "Start your quantum journey",
                    iconName: "star.fill",
                    levels: beginnerLevels
                ),
                LearningTrack(
                    name: "Intermediate",
                    description: "Build on the fundamentals",
                    iconName: "star.leadinghalf.filled",
                    levels: intermediateLevels
                ),
                LearningTrack(
                    name: "Advanced",
                    description: "Master quantum computing",
                    iconName: "star.circle.fill",
                    levels: advancedLevels
                )
            ]
        }
    }
    
    private func createTracksFromLocalData() {
        createTracksFromLevels()
    }
    
    // MARK: - Learning Strategy Generation
    
    private func generateMemoryTriggers(for level: LearningLevel) -> [MemoryTrigger] {
        // Try to find corresponding curriculum lesson
        for (trackIndex, track) in QuantumCurriculumContent.allTracks.enumerated() {
            for lesson in track.lessons {
                let lessonLevelId = (trackIndex + 1) * 100 + lesson.number
                if lessonLevelId == level.id {
                    return [
                        MemoryTrigger(
                            id: "\(lesson.id)_mnemonic",
                            title: lesson.title,
                            description: lesson.description,
                            mnemonic: lesson.mnemonic,
                            difficulty: lesson.difficulty
                        )
                    ]
                }
            }
        }

        // Fallback to original content
        switch level.id {
        case 1:
            return [
                MemoryTrigger(
                    id: "qc_intro_1",
                    title: "Q-bits are Quantum Bits",
                    description: "Remember: Q = Quantum, bit = binary digit",
                    mnemonic: "QBits = Quantum Binary digits",
                    difficulty: "Beginner"
                ),
                MemoryTrigger(
                    id: "qc_intro_2",
                    title: "Classical vs Quantum",
                    description: "Classical bits: 0 or 1. Quantum bits: 0 AND 1 simultaneously",
                    mnemonic: "C(lassical) = Either/Or, Q(uantum) = Both/And",
                    difficulty: "Beginner"
                ),
                MemoryTrigger(
                    id: "qc_intro_3",
                    title: "Superposition State",
                    description: "Particles exist in multiple states until measured",
                    mnemonic: "S.U.P.E.R. = Simultaneous Unified Probability Exists Randomly",
                    difficulty: "Beginner"
                )
            ]
        case 2:
            return [
                MemoryTrigger(
                    id: "qubit_1",
                    title: "State Notation",
                    description: "|0⟩ and |1⟩ are the basis states",
                    mnemonic: "Kets (|⟩) Keep quantum states",
                    difficulty: "Beginner"
                ),
                MemoryTrigger(
                    id: "qubit_2",
                    title: "Measurement Collapse",
                    description: "Measuring forces the qubit into a definite state",
                    mnemonic: "M.E.A.S. = Measurement Eliminates All Superposition",
                    difficulty: "Beginner"
                ),
                MemoryTrigger(
                    id: "qubit_3",
                    title: "Probability Amplitude",
                    description: "Alpha and Beta are complex numbers representing probability amplitudes",
                    mnemonic: "A.B. = Amplitude Bits",
                    difficulty: "Intermediate"
                )
            ]
        default:
            return []
        }
    }
    
    private func generateConceptMaps(for level: LearningLevel) -> [ConceptMap] {
        switch level.id {
        case 1:
            return [
                ConceptMap(
                    id: "qc_overview",
                    title: "Quantum Computing Basics",
                    centralConcept: "Quantum Computing",
                    relatedConcepts: ["Qubits", "Classical Computing", "Quantum Mechanics", "Superposition", "Entanglement"],
                    connections: [
                        "Quantum Computing": ["uses Qubits", "differs from Classical Computing", "relies on Quantum Mechanics"],
                        "Qubits": ["exhibit Superposition", "can be Entangled", "collapse on Measurement"],
                        "Classical Computing": ["uses Bits", "deterministic", "sequential processing"]
                    ],
                    description: "Understanding the fundamental relationship between quantum and classical computing"
                )
            ]
        case 2:
            return [
                ConceptMap(
                    id: "qubit_concept",
                    title: "Qubit States and Properties",
                    centralConcept: "Qubit",
                    relatedConcepts: ["|0⟩ State", "|1⟩ State", "Superposition", "Measurement", "Bloch Sphere"],
                    connections: [
                        "Qubit": ["has |0⟩ and |1⟩ states", "can be in Superposition", "exists on Bloch Sphere"],
                        "Superposition": ["combines multiple states", "collapses on Measurement", "probability-based"],
                        "Measurement": ["forces definite state", "reveals result", "destroys superposition"]
                    ],
                    description: "Understanding the properties and behavior of quantum bits"
                )
            ]
        default:
            return []
        }
    }
    
    private func generateFeynmanExplanations(for level: LearningLevel) -> [FeynmanExplanation] {
        switch level.id {
        case 1:
            return [
                FeynmanExplanation(
                    id: "qc_simple",
                    conceptName: "Quantum Computing",
                    simpleExplanation: "A quantum computer uses special bits that can be both 0 and 1 at the same time, unlike regular computers that use bits that are strictly 0 or 1.",
                    details: "Classical computers process information using bits that are definitively 0 or 1. Quantum computers use quantum bits (qubits) that can exist in a 'superposition' - simultaneously representing both 0 and 1 with different probabilities. Additionally, qubits can be entangled, meaning the state of one qubit instantly relates to another, even at a distance.",
                    analogies: [
                        "A classical bit is like a light switch: it's either ON (1) or OFF (0)",
                        "A qubit is like a spinning coin: while spinning, it's both heads AND tails simultaneously"
                    ],
                    commonMisconceptions: [
                        "Qubits are not 'uncertain bits' - they have definite probability amplitudes",
                        "Superposition doesn't mean we don't know the state - the particle truly exists in multiple states",
                        "Quantum computers won't magically solve all problems - they're better for specific types of problems"
                    ]
                ),
                FeynmanExplanation(
                    id: "superposition_simple",
                    conceptName: "Superposition",
                    simpleExplanation: "Superposition is when a quantum particle exists in multiple states at once. Like a coin spinning in the air is both heads and tails until it lands.",
                    details: "In quantum mechanics, particles can exist in a superposition of states, meaning they are in a combination of all possible states simultaneously with specific probabilities. When we measure the particle, the superposition 'collapses' to a single definite state.",
                    analogies: [
                        "Like a spinning coin being both heads and tails",
                        "Like being on multiple paths at the same time before someone observes which path you took"
                    ],
                    commonMisconceptions: [
                        "Superposition doesn't mean we don't know which state it is",
                        "The particle isn't in one state that we just haven't measured yet",
                        "Superposition is unique to quantum mechanics, not classical randomness"
                    ]
                )
            ]
        case 2:
            return [
                FeynmanExplanation(
                    id: "qubit_state_simple",
                    conceptName: "Qubit States",
                    simpleExplanation: "A qubit can be in state |0⟩, state |1⟩, or both at the same time (superposition). The |⟩ symbols (called 'kets') are just notation for quantum states.",
                    details: "A qubit's state is described mathematically as a linear combination of the basis states |0⟩ and |1⟩. The coefficients (α and β) are complex numbers called probability amplitudes. The squared magnitude of these amplitudes gives the probability of measuring that state.",
                    analogies: [
                        "|0⟩ and |1⟩ are like the 'axis' of a 3D sphere (Bloch sphere), and a qubit is a point on that sphere",
                        "Probability amplitudes are like the 'strength' of each possible outcome before measurement"
                    ],
                    commonMisconceptions: [
                        "The ket notation |⟩ is not a mathematical bracket - it's a specific quantum notation",
                        "Probability amplitudes are not probabilities themselves - we square them to get probabilities",
                        "|α|² + |β|² must equal 1 (normalization), not α + β = 1"
                    ]
                )
            ]
        default:
            return []
        }
    }
}

// MARK: - Sample Data
extension LearnViewModel {
    static let sample: LearnViewModel = {
        let vm = LearnViewModel()
        vm.completedLevels = [1, 2]
        vm.strategiesLoaded = true
        return vm
    }()
}
