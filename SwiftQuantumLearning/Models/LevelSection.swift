//
//  LevelSection.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//
//  MARK: - Data Model: Level Section
//  Represents a section within a learning level.
//  Sections can be theory, interactive demos, quizzes, or practice.
//

import SwiftUI

// MARK: - Section Type
/// Types of content sections within a level
enum SectionType: String, Codable, CaseIterable {
    case theory = "Theory"
    case interactive = "Interactive"
    case quiz = "Quiz"
    case practice = "Practice"
    
    /// Icon name for section type
    var iconName: String {
        switch self {
        case .theory: return "book.fill"
        case .interactive: return "hand.tap.fill"
        case .quiz: return "questionmark.circle.fill"
        case .practice: return "flask.fill"
        }
    }
    
    /// Color for section type
    var color: Color {
        switch self {
        case .theory: return .quantumCyan
        case .interactive: return .quantumPurple
        case .quiz: return .quantumOrange
        case .practice: return .completed
        }
    }
    
    /// Description of section type
    var description: String {
        switch self {
        case .theory: return "Learn the concept"
        case .interactive: return "Explore interactively"
        case .quiz: return "Test your knowledge"
        case .practice: return "Apply what you learned"
        }
    }
}

// MARK: - Level Section Model
/// A single section within a learning level
struct LevelSection: Identifiable, Codable {
    
    // MARK: - Properties
    
    /// Unique identifier
    let id: String
    
    /// Section title
    let title: String
    
    /// Type of section (theory, interactive, quiz, practice)
    let type: SectionType
    
    /// Main content text
    let content: String
    
    /// Key points for theory sections
    var keyPoints: [String]
    
    /// Whether section has visual content
    var hasVisual: Bool
    
    /// Visual content type if available
    var visualType: VisualType?
    
    // MARK: - Quiz Properties
    
    /// Quiz answer options
    var quizOptions: [String]
    
    /// Index of correct answer (for quiz sections)
    var correctAnswerIndex: Int
    
    /// Explanation shown after answering
    var explanation: String
    
    // MARK: - Interactive Properties
    
    /// Type of interactive element
    var interactiveType: InteractiveType?
    
    /// Configuration for interactive element
    var interactiveConfig: InteractiveConfig?
    
    // MARK: - Computed Properties
    
    /// Whether this section has been completed
    var isCompleted: Bool {
        // This would be connected to progress tracking
        false
    }
    
    // MARK: - Initializers
    
    /// Full initializer with all properties
    init(
        id: String,
        title: String,
        type: SectionType,
        content: String,
        keyPoints: [String] = [],
        hasVisual: Bool = false,
        visualType: VisualType? = nil,
        quizOptions: [String] = [],
        correctAnswerIndex: Int = 0,
        explanation: String = "",
        interactiveType: InteractiveType? = nil,
        interactiveConfig: InteractiveConfig? = nil
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.content = content
        self.keyPoints = keyPoints
        self.hasVisual = hasVisual
        self.visualType = visualType
        self.quizOptions = quizOptions
        self.correctAnswerIndex = correctAnswerIndex
        self.explanation = explanation
        self.interactiveType = interactiveType
        self.interactiveConfig = interactiveConfig
    }
}

// MARK: - Visual Type
/// Types of visual content in sections
enum VisualType: String, Codable {
    case blochSphere = "Bloch Sphere"
    case circuit = "Quantum Circuit"
    case histogram = "Measurement Histogram"
    case stateVector = "State Vector"
    case animation = "Animation"
    case image = "Image"
    
    var iconName: String {
        switch self {
        case .blochSphere: return "globe"
        case .circuit: return "square.grid.3x3"
        case .histogram: return "chart.bar"
        case .stateVector: return "arrow.up.right"
        case .animation: return "play.circle"
        case .image: return "photo"
        }
    }
}

// MARK: - Interactive Type
/// Types of interactive elements
enum InteractiveType: String, Codable {
    case blochSphereRotation = "Bloch Sphere Rotation"
    case gateApplication = "Gate Application"
    case measurement = "Measurement"
    case circuitBuilder = "Circuit Builder"
    case stateCreation = "State Creation"
    
    var description: String {
        switch self {
        case .blochSphereRotation: return "Rotate and explore the Bloch sphere"
        case .gateApplication: return "Apply quantum gates to qubits"
        case .measurement: return "Measure quantum states"
        case .circuitBuilder: return "Build quantum circuits"
        case .stateCreation: return "Create custom quantum states"
        }
    }
}

// MARK: - Interactive Config
/// Configuration for interactive elements
struct InteractiveConfig: Codable {
    /// Available gates (for gate application)
    var availableGates: [String]?
    
    /// Initial state
    var initialState: String?
    
    /// Number of qubits
    var numQubits: Int?
    
    /// Target state (for state creation challenges)
    var targetState: String?
    
    /// Show measurement controls
    var showMeasurement: Bool?
    
    /// Number of measurement shots
    var measurementShots: Int?
    
    init(
        availableGates: [String]? = nil,
        initialState: String? = nil,
        numQubits: Int? = nil,
        targetState: String? = nil,
        showMeasurement: Bool? = nil,
        measurementShots: Int? = nil
    ) {
        self.availableGates = availableGates
        self.initialState = initialState
        self.numQubits = numQubits
        self.targetState = targetState
        self.showMeasurement = showMeasurement
        self.measurementShots = measurementShots
    }
}

// MARK: - Sample Data
extension LevelSection {
    
    /// Sample theory section
    static var sampleTheory: LevelSection {
        LevelSection(
            id: "theory-sample",
            title: "Understanding Qubits",
            type: .theory,
            content: """
            A qubit is the fundamental unit of quantum information. Unlike classical bits \
            that can only be 0 or 1, qubits can exist in a superposition of both states \
            simultaneously.
            
            This property is what gives quantum computers their potential to solve \
            certain problems much faster than classical computers.
            """,
            keyPoints: [
                "Qubits can be 0, 1, or both at the same time",
                "Superposition enables quantum parallelism",
                "Measurement collapses the superposition",
                "Qubits are represented on the Bloch sphere"
            ],
            hasVisual: true,
            visualType: .blochSphere
        )
    }
    
    /// Sample interactive section
    static var sampleInteractive: LevelSection {
        LevelSection(
            id: "interactive-sample",
            title: "Explore Superposition",
            type: .interactive,
            content: "Use the controls below to create a superposition state and see how it's represented on the Bloch sphere.",
            interactiveType: .blochSphereRotation,
            interactiveConfig: InteractiveConfig(
                availableGates: ["H", "X", "Z"],
                initialState: "|0⟩",
                showMeasurement: true,
                measurementShots: 100
            )
        )
    }
    
    /// Sample quiz section
    static var sampleQuiz: LevelSection {
        LevelSection(
            id: "quiz-sample",
            title: "Knowledge Check",
            type: .quiz,
            content: "What happens when you apply a Hadamard gate to the |0⟩ state?",
            quizOptions: [
                "It becomes |1⟩",
                "It becomes (|0⟩ + |1⟩)/√2",
                "It becomes (|0⟩ - |1⟩)/√2",
                "Nothing happens"
            ],
            correctAnswerIndex: 1,
            explanation: "The Hadamard gate transforms |0⟩ into an equal superposition of |0⟩ and |1⟩, creating the |+⟩ state."
        )
    }
    
    /// Sample practice section
    static var samplePractice: LevelSection {
        LevelSection(
            id: "practice-sample",
            title: "Create a Bell State",
            type: .practice,
            content: "Your challenge: Create a Bell state (maximally entangled state) using the available gates. Start with two qubits in the |00⟩ state.",
            interactiveType: .circuitBuilder,
            interactiveConfig: InteractiveConfig(
                availableGates: ["H", "CNOT", "X", "Z"],
                initialState: "|00⟩",
                numQubits: 2,
                targetState: "(|00⟩ + |11⟩)/√2"
            )
        )
    }
}

// MARK: - Equatable
extension LevelSection: Equatable {
    static func == (lhs: LevelSection, rhs: LevelSection) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension LevelSection: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
