//
//  AdvancedLessons.swift
//  SwiftQuantumLearning
//
//  고급 레슨 콘텐츠 (Level 9-13)
//  Bell State, Grover, Simon 알고리즘, IBM Quantum 통합
//  수익 극대화를 위한 프리미엄 콘텐츠 구조
//
//  Created by SwiftQuantum Team
//  Copyright © 2026 SwiftQuantum. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - Advanced Lesson Model
struct AdvancedLesson: Identifiable, Codable {
    let id: String
    let number: Int
    let title: String
    let subtitle: String
    let description: String
    let objectives: [String]
    let prerequisites: [String]
    let estimatedMinutes: Int
    let xpReward: Int
    let difficulty: Difficulty
    let tier: RequiredTier
    let modules: [LessonModule]
    let practiceExercises: [PracticeExercise]
    let quiz: LessonQuiz?

    enum Difficulty: String, Codable {
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        case expert = "Expert"

        var color: Color {
            switch self {
            case .intermediate: return .yellow
            case .advanced: return .orange
            case .expert: return .red
            }
        }
    }

    enum RequiredTier: String, Codable {
        case free = "Free"
        case pro = "Pro"
        case enterprise = "Enterprise"

        var color: Color {
            switch self {
            case .free: return .textSecondary
            case .pro: return .quantumCyan
            case .enterprise: return .quantumOrange
            }
        }

        var monthlyPrice: Double {
            switch self {
            case .free: return 0
            case .pro: return 9.99
            case .enterprise: return 29.99
            }
        }
    }

    struct LessonModule: Identifiable, Codable {
        let id: String
        let title: String
        let content: String
        let codeExample: String?
        let visualizationType: VisualizationType?
        let durationMinutes: Int

        enum VisualizationType: String, Codable {
            case circuitDiagram = "Circuit Diagram"
            case blochSphere = "Bloch Sphere"
            case probabilityChart = "Probability Chart"
            case entanglementMap = "Entanglement Map"
            case algorithmFlow = "Algorithm Flow"
        }
    }

    struct PracticeExercise: Identifiable, Codable {
        let id: String
        let title: String
        let instruction: String
        let starterCode: String
        let solution: String
        let hints: [String]
        let xpReward: Int
    }

    struct LessonQuiz: Codable {
        let questions: [QuizQuestion]
        let passingScore: Int
        let xpReward: Int

        struct QuizQuestion: Identifiable, Codable {
            let id: String
            let question: String
            let options: [String]
            let correctIndex: Int
            let explanation: String
        }
    }
}

// MARK: - Advanced Lessons Content
struct AdvancedLessonsContent {

    // MARK: - Level 9: Bell State & Entanglement
    static let level9_BellState = AdvancedLesson(
        id: "level_9",
        number: 9,
        title: "Bell States & Quantum Entanglement",
        subtitle: "Create and manipulate maximally entangled qubit pairs",
        description: "Master the fundamental building blocks of quantum communication and teleportation. Learn to create all four Bell states and understand their unique properties.",
        objectives: [
            "Understand quantum entanglement fundamentals",
            "Create all four Bell states (Phi+, Phi-, Psi+, Psi-)",
            "Implement entanglement verification protocols",
            "Apply Bell states to quantum key distribution"
        ],
        prerequisites: ["Level 1-4", "Basic Quantum Gates"],
        estimatedMinutes: 45,
        xpReward: 150,
        difficulty: .intermediate,
        tier: .pro,
        modules: [
            AdvancedLesson.LessonModule(
                id: "bell_intro",
                title: "Introduction to Entanglement",
                content: """
                Quantum entanglement is one of the most fascinating phenomena in quantum mechanics. When two qubits become entangled, measuring one instantly affects the other, regardless of the distance between them.

                Einstein famously called this "spooky action at a distance," but today we harness it for:
                - Quantum cryptography (unhackable communication)
                - Quantum teleportation
                - Quantum computing error correction

                The Harvard-MIT 2026 research demonstrates entanglement fidelity of 99.85% across their 3,000 qubit array.
                """,
                codeExample: nil,
                visualizationType: .entanglementMap,
                durationMinutes: 8
            ),
            AdvancedLesson.LessonModule(
                id: "bell_creation",
                title: "Creating Bell States",
                content: """
                The four Bell states are maximally entangled two-qubit states:

                |Φ⁺⟩ = (|00⟩ + |11⟩) / √2
                |Φ⁻⟩ = (|00⟩ - |11⟩) / √2
                |Ψ⁺⟩ = (|01⟩ + |10⟩) / √2
                |Ψ⁻⟩ = (|01⟩ - |10⟩) / √2

                To create |Φ⁺⟩:
                1. Start with |00⟩
                2. Apply Hadamard to first qubit
                3. Apply CNOT with first qubit as control

                This simple circuit creates perfect entanglement!
                """,
                codeExample: """
                // SwiftQuantum Bell State Circuit
                let circuit = QuantumCircuit(qubitCount: 2)

                // Create |Φ⁺⟩ Bell state
                circuit.addGate(.hadamard, target: 0)
                circuit.addGate(.cnot, target: 1, control: 0)

                await circuit.execute()
                // Result: 50% |00⟩, 50% |11⟩
                """,
                visualizationType: .circuitDiagram,
                durationMinutes: 12
            ),
            AdvancedLesson.LessonModule(
                id: "bell_measurement",
                title: "Bell State Measurement",
                content: """
                Measuring entangled qubits reveals their correlated nature:

                - Measure qubit 0 → Get 0 or 1 with 50% probability
                - Qubit 1 is instantly determined (same value for |Φ⁺⟩)

                This correlation holds regardless of distance!

                Bell Inequality Test:
                Classical systems cannot achieve >75% correlation in certain tests.
                Quantum systems consistently achieve ~85% (violating Bell's inequality).
                """,
                codeExample: """
                // Verify entanglement
                let result0 = circuit.measure(qubit: 0)
                let result1 = circuit.measure(qubit: 1)

                // For |Φ⁺⟩: result0 == result1 (always!)
                print("Correlated: \\(result0 == result1)")
                """,
                visualizationType: .probabilityChart,
                durationMinutes: 10
            ),
            AdvancedLesson.LessonModule(
                id: "bell_applications",
                title: "Real-World Applications",
                content: """
                Bell states enable groundbreaking technologies:

                1. Quantum Key Distribution (QKD)
                   - BB84 and E91 protocols
                   - Unhackable communication (any eavesdropping disturbs the state)

                2. Quantum Teleportation
                   - Transfer quantum states without physical transmission
                   - Essential for distributed quantum computing

                3. Superdense Coding
                   - Transmit 2 classical bits using 1 qubit
                   - Doubles communication bandwidth

                Harvard-MIT Achievement: 96+ logical qubits using entangled error correction codes.
                """,
                codeExample: nil,
                visualizationType: .algorithmFlow,
                durationMinutes: 15
            )
        ],
        practiceExercises: [
            AdvancedLesson.PracticeExercise(
                id: "bell_ex1",
                title: "Create |Ψ⁺⟩ Bell State",
                instruction: "Modify the circuit to create the |Ψ⁺⟩ state instead of |Φ⁺⟩",
                starterCode: """
                let circuit = QuantumCircuit(qubitCount: 2)
                // Add gates here to create |Ψ⁺⟩ = (|01⟩ + |10⟩) / √2
                """,
                solution: """
                let circuit = QuantumCircuit(qubitCount: 2)
                circuit.addGate(.pauliX, target: 1)  // Flip second qubit
                circuit.addGate(.hadamard, target: 0)
                circuit.addGate(.cnot, target: 1, control: 0)
                """,
                hints: [
                    "Think about what differs between |Φ⁺⟩ and |Ψ⁺⟩",
                    "You need to flip one qubit before entangling"
                ],
                xpReward: 25
            ),
            AdvancedLesson.PracticeExercise(
                id: "bell_ex2",
                title: "Bell State Verification",
                instruction: "Run 100 measurements and verify the correlation",
                starterCode: """
                let circuit = QuantumCircuit(qubitCount: 2)
                circuit.addGate(.hadamard, target: 0)
                circuit.addGate(.cnot, target: 1, control: 0)

                var correlatedCount = 0
                // Run 100 measurements and count correlations
                """,
                solution: """
                let circuit = QuantumCircuit(qubitCount: 2)
                circuit.addGate(.hadamard, target: 0)
                circuit.addGate(.cnot, target: 1, control: 0)

                var correlatedCount = 0
                for _ in 0..<100 {
                    await circuit.execute()
                    let r0 = circuit.measure(qubit: 0)
                    let r1 = circuit.measure(qubit: 1)
                    if r0 == r1 { correlatedCount += 1 }
                    circuit.reset()
                }
                // correlatedCount should be 100 (perfect correlation)
                """,
                hints: [
                    "Remember to reset the circuit between measurements",
                    "For |Φ⁺⟩, both qubits always give the same result"
                ],
                xpReward: 30
            )
        ],
        quiz: AdvancedLesson.LessonQuiz(
            questions: [
                AdvancedLesson.LessonQuiz.QuizQuestion(
                    id: "bell_q1",
                    question: "What is the minimum number of gates needed to create a Bell state?",
                    options: ["1", "2", "3", "4"],
                    correctIndex: 1,
                    explanation: "A Bell state requires 2 gates: Hadamard + CNOT"
                ),
                AdvancedLesson.LessonQuiz.QuizQuestion(
                    id: "bell_q2",
                    question: "In the |Φ⁺⟩ state, if qubit 0 measures |0⟩, what is qubit 1?",
                    options: ["|0⟩ with 100%", "|1⟩ with 100%", "50/50 |0⟩ or |1⟩", "Unknown"],
                    correctIndex: 0,
                    explanation: "|Φ⁺⟩ = (|00⟩ + |11⟩)/√2, so measuring |0⟩ on qubit 0 means qubit 1 must also be |0⟩"
                ),
                AdvancedLesson.LessonQuiz.QuizQuestion(
                    id: "bell_q3",
                    question: "Why is entanglement useful for cryptography?",
                    options: [
                        "It's faster than classical encryption",
                        "Any eavesdropping disturbs the quantum state",
                        "It uses less energy",
                        "It's cheaper to implement"
                    ],
                    correctIndex: 1,
                    explanation: "Quantum states collapse when measured, making eavesdropping detectable"
                )
            ],
            passingScore: 2,
            xpReward: 50
        )
    )

    // MARK: - Level 10: Grover's Search Algorithm
    static let level10_Grover = AdvancedLesson(
        id: "level_10",
        number: 10,
        title: "Grover's Search Algorithm",
        subtitle: "Achieve quantum speedup with O(√N) search",
        description: "Implement Grover's algorithm to search unsorted databases quadratically faster than classical computers. Learn the oracle and diffusion operator construction.",
        objectives: [
            "Understand quantum search advantage",
            "Implement the Grover oracle for marked states",
            "Construct the diffusion operator",
            "Calculate optimal iteration count",
            "Apply to real search problems"
        ],
        prerequisites: ["Level 9", "Multi-qubit operations"],
        estimatedMinutes: 60,
        xpReward: 200,
        difficulty: .advanced,
        tier: .pro,
        modules: [
            AdvancedLesson.LessonModule(
                id: "grover_intro",
                title: "The Search Problem",
                content: """
                Classical Search: O(N) - check each item one by one
                Quantum Search: O(√N) - Grover's algorithm

                For N = 1,000,000 items:
                - Classical: ~1,000,000 checks
                - Quantum: ~1,000 iterations

                This is a QUADRATIC speedup - one of quantum computing's killer applications!

                Use cases:
                - Database search
                - Cryptographic key search
                - Optimization problems
                - Machine learning feature selection
                """,
                codeExample: nil,
                visualizationType: .algorithmFlow,
                durationMinutes: 10
            ),
            AdvancedLesson.LessonModule(
                id: "grover_oracle",
                title: "The Oracle Function",
                content: """
                The oracle marks the solution state by flipping its phase:

                |x⟩ → -|x⟩  if x is the solution
                |x⟩ → |x⟩   otherwise

                For a 2-qubit search finding |11⟩:
                The oracle is a Controlled-Z gate that only affects |11⟩.

                In practice, you design the oracle based on your search criteria.
                The oracle is the "black box" that recognizes the answer.
                """,
                codeExample: """
                // Oracle for finding |11⟩
                func groverOracle(_ circuit: QuantumCircuit) {
                    // CZ gate: flips phase of |11⟩
                    circuit.addGate(.hadamard, target: 1)
                    circuit.addGate(.cnot, target: 1, control: 0)
                    circuit.addGate(.hadamard, target: 1)
                }
                """,
                visualizationType: .circuitDiagram,
                durationMinutes: 15
            ),
            AdvancedLesson.LessonModule(
                id: "grover_diffusion",
                title: "Diffusion Operator",
                content: """
                The diffusion operator amplifies the marked state's amplitude:

                D = 2|ψ⟩⟨ψ| - I

                Where |ψ⟩ is the uniform superposition.

                Implementation:
                1. Apply H to all qubits
                2. Apply X to all qubits
                3. Apply multi-controlled Z
                4. Apply X to all qubits
                5. Apply H to all qubits

                This "inverts about the mean" - amplifying above-average amplitudes.
                """,
                codeExample: """
                // Diffusion operator
                func diffusionOperator(_ circuit: QuantumCircuit, qubits: Int) {
                    // Apply H to all
                    for i in 0..<qubits {
                        circuit.addGate(.hadamard, target: i)
                    }
                    // Apply X to all
                    for i in 0..<qubits {
                        circuit.addGate(.pauliX, target: i)
                    }
                    // Multi-controlled Z (simplified for 2 qubits)
                    circuit.addGate(.hadamard, target: 1)
                    circuit.addGate(.cnot, target: 1, control: 0)
                    circuit.addGate(.hadamard, target: 1)
                    // Apply X to all
                    for i in 0..<qubits {
                        circuit.addGate(.pauliX, target: i)
                    }
                    // Apply H to all
                    for i in 0..<qubits {
                        circuit.addGate(.hadamard, target: i)
                    }
                }
                """,
                visualizationType: .probabilityChart,
                durationMinutes: 20
            ),
            AdvancedLesson.LessonModule(
                id: "grover_iterations",
                title: "Optimal Iterations",
                content: """
                Too few iterations: solution not amplified enough
                Too many iterations: solution amplitude decreases!

                Optimal iterations ≈ π/4 × √N

                For N items with M solutions:
                k ≈ π/4 × √(N/M)

                Example:
                - N = 4 (2 qubits): k ≈ 1 iteration
                - N = 256 (8 qubits): k ≈ 12 iterations
                - N = 1,000,000: k ≈ 785 iterations

                After k iterations, measurement probability is ~1 (near certain success)!
                """,
                codeExample: """
                // Complete Grover for 2 qubits, finding |11⟩
                let circuit = QuantumCircuit(qubitCount: 2)

                // Initial superposition
                circuit.addGate(.hadamard, target: 0)
                circuit.addGate(.hadamard, target: 1)

                // One Grover iteration (optimal for N=4)
                groverOracle(circuit)
                diffusionOperator(circuit, qubits: 2)

                // Measure - should get |11⟩ with high probability
                await circuit.execute()
                """,
                visualizationType: .algorithmFlow,
                durationMinutes: 15
            )
        ],
        practiceExercises: [
            AdvancedLesson.PracticeExercise(
                id: "grover_ex1",
                title: "Search for |01⟩",
                instruction: "Modify the oracle to find |01⟩ instead of |11⟩",
                starterCode: """
                let circuit = QuantumCircuit(qubitCount: 2)
                // Set up initial superposition
                circuit.addGate(.hadamard, target: 0)
                circuit.addGate(.hadamard, target: 1)

                // TODO: Create oracle for |01⟩
                """,
                solution: """
                let circuit = QuantumCircuit(qubitCount: 2)
                circuit.addGate(.hadamard, target: 0)
                circuit.addGate(.hadamard, target: 1)

                // Oracle for |01⟩: flip phase when q0=0 and q1=1
                circuit.addGate(.pauliX, target: 0)  // Flip q0
                circuit.addGate(.hadamard, target: 1)
                circuit.addGate(.cnot, target: 1, control: 0)
                circuit.addGate(.hadamard, target: 1)
                circuit.addGate(.pauliX, target: 0)  // Unflip q0

                // Diffusion operator...
                """,
                hints: [
                    "The oracle needs to mark |01⟩, not |11⟩",
                    "Use X gates to convert the problem"
                ],
                xpReward: 35
            )
        ],
        quiz: AdvancedLesson.LessonQuiz(
            questions: [
                AdvancedLesson.LessonQuiz.QuizQuestion(
                    id: "grover_q1",
                    question: "What is the speedup of Grover's algorithm?",
                    options: ["O(1)", "O(log N)", "O(√N)", "O(N)"],
                    correctIndex: 2,
                    explanation: "Grover's algorithm provides quadratic speedup: O(√N) vs O(N)"
                ),
                AdvancedLesson.LessonQuiz.QuizQuestion(
                    id: "grover_q2",
                    question: "What happens if you run too many Grover iterations?",
                    options: [
                        "Better results",
                        "The solution amplitude decreases",
                        "The circuit crashes",
                        "Nothing changes"
                    ],
                    correctIndex: 1,
                    explanation: "Grover's algorithm is periodic - too many iterations reduce success probability"
                )
            ],
            passingScore: 1,
            xpReward: 50
        )
    )

    // MARK: - Level 11: Simon's Algorithm
    static let level11_Simon = AdvancedLesson(
        id: "level_11",
        number: 11,
        title: "Simon's Algorithm",
        subtitle: "Exponential quantum advantage for hidden period problems",
        description: "Learn Simon's algorithm, which provides exponential speedup for finding hidden patterns. This algorithm inspired Shor's factoring algorithm.",
        objectives: [
            "Understand the hidden subgroup problem",
            "Implement Simon's quantum circuit",
            "Analyze the exponential speedup",
            "Connect to Shor's algorithm motivation"
        ],
        prerequisites: ["Level 10", "Linear algebra basics"],
        estimatedMinutes: 50,
        xpReward: 180,
        difficulty: .advanced,
        tier: .pro,
        modules: [
            AdvancedLesson.LessonModule(
                id: "simon_problem",
                title: "The Hidden Period Problem",
                content: """
                Simon's Problem:
                Given a function f(x) where f(x) = f(y) iff x ⊕ y = s or x = y

                Goal: Find the hidden string s

                Classical: O(2^(n/2)) queries needed
                Quantum: O(n) queries with Simon's algorithm

                This is EXPONENTIAL speedup!

                Historical Importance:
                - First algorithm showing clear quantum advantage
                - Inspired Shor's algorithm for factoring
                - Demonstrated quantum parallelism power
                """,
                codeExample: nil,
                visualizationType: .algorithmFlow,
                durationMinutes: 10
            ),
            AdvancedLesson.LessonModule(
                id: "simon_circuit",
                title: "Simon's Circuit",
                content: """
                Simon's Algorithm:
                1. Prepare n+n qubits in |0...0⟩
                2. Apply Hadamard to first n qubits
                3. Apply oracle Uf
                4. Apply Hadamard to first n qubits
                5. Measure first n qubits

                The measurement gives a string y where y·s = 0 (mod 2)

                Repeat n-1 times to get n-1 linearly independent equations.
                Solve the system to find s!
                """,
                codeExample: """
                // Simon's algorithm for n=2
                func simonAlgorithm() -> [Int] {
                    var equations: [[Int]] = []

                    // Repeat until we have enough equations
                    while equations.count < 1 {  // n-1 = 1 for n=2
                        let circuit = QuantumCircuit(qubitCount: 4)

                        // Hadamard on input register
                        circuit.addGate(.hadamard, target: 0)
                        circuit.addGate(.hadamard, target: 1)

                        // Apply oracle (example: s = "11")
                        simonOracle(circuit)

                        // Hadamard on input register
                        circuit.addGate(.hadamard, target: 0)
                        circuit.addGate(.hadamard, target: 1)

                        await circuit.execute()

                        // Measure input register
                        let y0 = circuit.measure(qubit: 0)
                        let y1 = circuit.measure(qubit: 1)

                        if y0 != 0 || y1 != 0 {  // Non-trivial equation
                            equations.append([y0, y1])
                        }
                    }

                    return solveLinearSystem(equations)
                }
                """,
                visualizationType: .circuitDiagram,
                durationMinutes: 20
            ),
            AdvancedLesson.LessonModule(
                id: "simon_solving",
                title: "Solving for s",
                content: """
                Each measurement gives: y·s = 0 (mod 2)

                Example with s = "11":
                - Measurement y = "01": 0·1 + 1·1 = 1 ≡ 0? No, skip
                - Measurement y = "10": 1·1 + 0·1 = 1 ≡ 0? No, skip
                - Measurement y = "11": 1·1 + 1·1 = 2 ≡ 0? Yes! Valid equation
                - Measurement y = "00": trivial, skip

                With enough valid equations, use Gaussian elimination.
                For n qubits, need n-1 linearly independent equations.
                """,
                codeExample: nil,
                visualizationType: .algorithmFlow,
                durationMinutes: 15
            )
        ],
        practiceExercises: [
            AdvancedLesson.PracticeExercise(
                id: "simon_ex1",
                title: "Verify Simon's Equations",
                instruction: "Given measurements [01, 11, 10], verify which satisfy y·s = 0 for s = 11",
                starterCode: """
                let s = [1, 1]  // Hidden string
                let measurements = [[0, 1], [1, 1], [1, 0]]

                for y in measurements {
                    // Calculate y·s mod 2
                    // Print whether it satisfies the equation
                }
                """,
                solution: """
                let s = [1, 1]
                let measurements = [[0, 1], [1, 1], [1, 0]]

                for y in measurements {
                    let dotProduct = (y[0] * s[0] + y[1] * s[1]) % 2
                    let satisfies = dotProduct == 0
                    print("y = \\(y): y·s = \\(dotProduct), valid: \\(satisfies)")
                }
                // Output:
                // y = [0, 1]: y·s = 1, valid: false
                // y = [1, 1]: y·s = 0, valid: true
                // y = [1, 0]: y·s = 1, valid: false
                """,
                hints: [
                    "Dot product: y·s = y₀s₀ + y₁s₁",
                    "Check if result mod 2 equals 0"
                ],
                xpReward: 30
            )
        ],
        quiz: AdvancedLesson.LessonQuiz(
            questions: [
                AdvancedLesson.LessonQuiz.QuizQuestion(
                    id: "simon_q1",
                    question: "What type of speedup does Simon's algorithm provide?",
                    options: ["Constant", "Linear", "Quadratic", "Exponential"],
                    correctIndex: 3,
                    explanation: "Simon's algorithm provides exponential speedup: O(n) vs O(2^(n/2))"
                )
            ],
            passingScore: 1,
            xpReward: 40
        )
    )

    // MARK: - Level 12: Error Correction Fundamentals
    static let level12_ErrorCorrection = AdvancedLesson(
        id: "level_12",
        number: 12,
        title: "Quantum Error Correction",
        subtitle: "Protect quantum information from decoherence",
        description: "Master the foundations of quantum error correction. Learn how to protect fragile quantum states using the Bit-flip, Phase-flip, and Shor codes.",
        objectives: [
            "Understand quantum errors (bit-flip, phase-flip)",
            "Implement the 3-qubit bit-flip code",
            "Learn syndrome measurement",
            "Design error correction circuits",
            "Apply Harvard-MIT fault-tolerant principles"
        ],
        prerequisites: ["Level 9-11", "Understanding of noise"],
        estimatedMinutes: 75,
        xpReward: 250,
        difficulty: .expert,
        tier: .enterprise,
        modules: [
            AdvancedLesson.LessonModule(
                id: "error_intro",
                title: "Why Error Correction?",
                content: """
                Quantum computers are extremely sensitive to noise:
                - Decoherence: quantum states decay over time
                - Gate errors: imperfect operations
                - Measurement errors: incorrect readouts
                - Crosstalk: neighboring qubits interfere

                Without error correction:
                - Computations fail after ~100 operations
                - Large algorithms impossible

                Harvard-MIT 2026 Achievement:
                - 96 logical qubits with fault-tolerant architecture
                - 2+ hours continuous operation
                - 99.85% fidelity maintained through active correction
                """,
                codeExample: nil,
                visualizationType: nil,
                durationMinutes: 10
            ),
            AdvancedLesson.LessonModule(
                id: "bitflip_code",
                title: "3-Qubit Bit-Flip Code",
                content: """
                Classical repetition for quantum:

                Encoding:
                |0⟩ → |000⟩
                |1⟩ → |111⟩

                If one qubit flips:
                |000⟩ → |001⟩ (error on qubit 3)

                Syndrome Measurement:
                - Measure parity of qubits 1&2, and 2&3
                - Parity differences reveal error location

                Correction:
                - Apply X gate to the identified qubit
                """,
                codeExample: """
                // 3-Qubit Bit-Flip Code
                func encodeBitFlip(_ circuit: QuantumCircuit, dataQubit: Int) {
                    // Encode |ψ⟩ into |ψψψ⟩
                    circuit.addGate(.cnot, target: dataQubit + 1, control: dataQubit)
                    circuit.addGate(.cnot, target: dataQubit + 2, control: dataQubit)
                }

                func syndromeMeasurement(_ circuit: QuantumCircuit) -> (Int, Int) {
                    // Add ancilla qubits for syndrome measurement
                    // Measure parity without collapsing data
                    // Returns (s1, s2) indicating error location
                }

                func correctError(_ circuit: QuantumCircuit, syndrome: (Int, Int)) {
                    let errorQubit: Int
                    switch syndrome {
                    case (0, 1): errorQubit = 2
                    case (1, 0): errorQubit = 0
                    case (1, 1): errorQubit = 1
                    default: return  // No error
                    }
                    circuit.addGate(.pauliX, target: errorQubit)
                }
                """,
                visualizationType: .circuitDiagram,
                durationMinutes: 20
            ),
            AdvancedLesson.LessonModule(
                id: "phaseflip_code",
                title: "Phase-Flip Code",
                content: """
                Phase errors flip the sign: |+⟩ → |-⟩

                Encoding (in Hadamard basis):
                |+⟩ → |+++⟩
                |-⟩ → |---⟩

                Detection:
                - Transform to computational basis (apply H)
                - Use bit-flip syndrome measurement
                - Transform back (apply H)

                Correction:
                - Apply Z gate to identified qubit
                """,
                codeExample: """
                // Phase-Flip Code
                func encodePhaseFlip(_ circuit: QuantumCircuit, dataQubit: Int) {
                    // First encode in computational basis
                    encodeBitFlip(circuit, dataQubit: dataQubit)

                    // Transform to Hadamard basis
                    circuit.addGate(.hadamard, target: dataQubit)
                    circuit.addGate(.hadamard, target: dataQubit + 1)
                    circuit.addGate(.hadamard, target: dataQubit + 2)
                }
                """,
                visualizationType: .circuitDiagram,
                durationMinutes: 15
            ),
            AdvancedLesson.LessonModule(
                id: "shor_code",
                title: "Shor's 9-Qubit Code",
                content: """
                Shor's code corrects BOTH bit-flip AND phase-flip errors!

                Uses 9 physical qubits for 1 logical qubit:
                |0_L⟩ = (|000⟩ + |111⟩)(|000⟩ + |111⟩)(|000⟩ + |111⟩) / 2√2

                Structure:
                - Outer code: 3-qubit phase-flip
                - Inner code: 3-qubit bit-flip (for each outer qubit)

                This is the foundation of modern quantum error correction!
                """,
                codeExample: nil,
                visualizationType: .circuitDiagram,
                durationMinutes: 20
            ),
            AdvancedLesson.LessonModule(
                id: "ft_principles",
                title: "Fault-Tolerant Principles (Harvard-MIT)",
                content: """
                Harvard-MIT 2026 Fault-Tolerant Architecture:

                1. Transversal Gates
                   - Apply gates independently to each physical qubit
                   - Errors don't propagate between qubits

                2. Magic State Distillation
                   - Create high-fidelity resource states
                   - Enable universal computation

                3. Surface Code Implementation
                   - 2D grid of qubits
                   - Threshold error rate: ~1%
                   - Currently best practical code

                4. Optical Lattice Conveyor Belt
                   - Real-time atom replenishment
                   - Maintains qubit count during operation
                   - Key to 2+ hour continuous operation
                """,
                codeExample: nil,
                visualizationType: .algorithmFlow,
                durationMinutes: 10
            )
        ],
        practiceExercises: [
            AdvancedLesson.PracticeExercise(
                id: "ec_ex1",
                title: "Design Error Detection",
                instruction: "Implement syndrome measurement for the 3-qubit code",
                starterCode: """
                // Given encoded state on qubits 0, 1, 2
                // Use ancilla qubits 3, 4 for syndrome measurement
                let circuit = QuantumCircuit(qubitCount: 5)

                // TODO: Add CNOT gates to measure parity
                // without collapsing the data qubits
                """,
                solution: """
                let circuit = QuantumCircuit(qubitCount: 5)

                // Measure parity of qubits 0 and 1 → ancilla 3
                circuit.addGate(.cnot, target: 3, control: 0)
                circuit.addGate(.cnot, target: 3, control: 1)

                // Measure parity of qubits 1 and 2 → ancilla 4
                circuit.addGate(.cnot, target: 4, control: 1)
                circuit.addGate(.cnot, target: 4, control: 2)

                // Measure ancillas (doesn't collapse data)
                let s1 = circuit.measure(qubit: 3)
                let s2 = circuit.measure(qubit: 4)
                // Syndrome (s1, s2) identifies error location
                """,
                hints: [
                    "CNOT allows parity measurement without direct measurement",
                    "XOR of multiple qubits accumulates in the target"
                ],
                xpReward: 50
            )
        ],
        quiz: AdvancedLesson.LessonQuiz(
            questions: [
                AdvancedLesson.LessonQuiz.QuizQuestion(
                    id: "ec_q1",
                    question: "How many physical qubits does Shor's code use for one logical qubit?",
                    options: ["3", "5", "7", "9"],
                    correctIndex: 3,
                    explanation: "Shor's 9-qubit code uses 9 physical qubits to encode 1 logical qubit"
                ),
                AdvancedLesson.LessonQuiz.QuizQuestion(
                    id: "ec_q2",
                    question: "What is the key innovation in Harvard-MIT's 2026 continuous operation?",
                    options: [
                        "Faster gates",
                        "Optical lattice conveyor belt atom replenishment",
                        "Lower temperature",
                        "Better detectors"
                    ],
                    correctIndex: 1,
                    explanation: "The optical lattice conveyor belt continuously replenishes lost atoms"
                )
            ],
            passingScore: 1,
            xpReward: 50
        )
    )

    // MARK: - Level 13: IBM Quantum Integration
    static let level13_IBMQuantum = AdvancedLesson(
        id: "level_13",
        number: 13,
        title: "IBM Quantum Integration",
        subtitle: "Run circuits on real quantum hardware",
        description: "Learn to integrate with IBM Quantum systems. Deploy your algorithms to real quantum processors and analyze results from actual hardware.",
        objectives: [
            "Set up IBM Quantum account and API access",
            "Translate SwiftQuantum circuits to QASM",
            "Submit jobs to IBM Quantum backends",
            "Analyze real hardware results vs simulation",
            "Handle hardware-specific noise and errors"
        ],
        prerequisites: ["Level 9-12", "All previous algorithms"],
        estimatedMinutes: 90,
        xpReward: 300,
        difficulty: .expert,
        tier: .enterprise,
        modules: [
            AdvancedLesson.LessonModule(
                id: "ibm_setup",
                title: "IBM Quantum Setup",
                content: """
                Getting Started with IBM Quantum:

                1. Create Account
                   - Visit quantum-computing.ibm.com
                   - Sign up for free tier (limited access)
                   - Enterprise users: Premium access

                2. Get API Token
                   - Navigate to Account settings
                   - Copy your API token
                   - Store securely in SwiftQuantumLearning

                3. Available Backends
                   - ibmq_qasm_simulator: Cloud simulator
                   - ibm_brisbane: 127-qubit Eagle processor
                   - ibm_osaka: 127-qubit Eagle processor
                   - ibm_kyoto: 127-qubit Eagle processor

                Queue times vary: simulators instant, hardware 1-60 min
                """,
                codeExample: """
                // IBM Quantum Configuration
                struct IBMQuantumConfig {
                    let apiToken: String
                    let hub: String = "ibm-q"
                    let group: String = "open"
                    let project: String = "main"

                    var endpoint: URL {
                        URL(string: "https://api.quantum-computing.ibm.com")!
                    }
                }

                // Store token securely
                KeychainService.shared.store(
                    apiToken,
                    for: "ibm_quantum_token"
                )
                """,
                visualizationType: nil,
                durationMinutes: 15
            ),
            AdvancedLesson.LessonModule(
                id: "ibm_qasm",
                title: "OpenQASM Translation",
                content: """
                IBM Quantum uses OpenQASM (Quantum Assembly):

                QASM 3.0 Format:
                ```
                OPENQASM 3.0;
                include "stdgates.inc";

                qubit[2] q;
                bit[2] c;

                h q[0];
                cx q[0], q[1];

                c[0] = measure q[0];
                c[1] = measure q[1];
                ```

                SwiftQuantum automatically exports to QASM!
                """,
                codeExample: """
                // Export SwiftQuantum circuit to QASM
                extension QuantumCircuit {
                    func toQASM() -> String {
                        var qasm = "OPENQASM 3.0;\\n"
                        qasm += "include \\"stdgates.inc\\";\\n\\n"
                        qasm += "qubit[\\(qubitCount)] q;\\n"
                        qasm += "bit[\\(qubitCount)] c;\\n\\n"

                        for gate in gates {
                            switch gate.type {
                            case .hadamard:
                                qasm += "h q[\\(gate.targetQubit)];\\n"
                            case .pauliX:
                                qasm += "x q[\\(gate.targetQubit)];\\n"
                            case .cnot:
                                if let ctrl = gate.controlQubit {
                                    qasm += "cx q[\\(ctrl)], q[\\(gate.targetQubit)];\\n"
                                }
                            case .measure:
                                qasm += "c[\\(gate.targetQubit)] = measure q[\\(gate.targetQubit)];\\n"
                            // ... other gates
                            }
                        }

                        return qasm
                    }
                }
                """,
                visualizationType: .circuitDiagram,
                durationMinutes: 20
            ),
            AdvancedLesson.LessonModule(
                id: "ibm_submit",
                title: "Submitting Jobs",
                content: """
                Job Submission Flow:

                1. Transpile Circuit
                   - Map to hardware topology
                   - Optimize gate count
                   - Add error mitigation

                2. Submit to Backend
                   - Choose backend (simulator/hardware)
                   - Set shots (measurement count)
                   - Wait in queue

                3. Retrieve Results
                   - Poll job status
                   - Download measurement outcomes
                   - Parse histogram data

                Typical hardware run: 1000-8000 shots
                """,
                codeExample: """
                // Submit job to IBM Quantum
                class IBMQuantumService {
                    func submitJob(
                        circuit: QuantumCircuit,
                        backend: String = "ibmq_qasm_simulator",
                        shots: Int = 1000
                    ) async throws -> IBMJobResult {

                        let qasm = circuit.toQASM()

                        let request = IBMJobRequest(
                            qasm: qasm,
                            backend: backend,
                            shots: shots
                        )

                        let job = try await apiClient.post(
                            endpoint: "/jobs",
                            body: request
                        )

                        // Poll until complete
                        return try await waitForCompletion(job.id)
                    }
                }
                """,
                visualizationType: .algorithmFlow,
                durationMinutes: 20
            ),
            AdvancedLesson.LessonModule(
                id: "ibm_analysis",
                title: "Analyzing Hardware Results",
                content: """
                Real Hardware vs Simulation:

                Simulation: Perfect results (within numerical precision)
                Hardware: Noisy results due to:
                - Decoherence (T1, T2 times)
                - Gate errors (~0.1-1%)
                - Readout errors (~1-5%)
                - Crosstalk between qubits

                Error Mitigation Techniques:
                1. Measurement error mitigation
                2. Zero-noise extrapolation
                3. Probabilistic error cancellation
                4. Twirled readout error extinction (TREX)

                Always compare hardware results to simulation to understand noise impact!
                """,
                codeExample: """
                // Analyze IBM Quantum results
                func analyzeResults(
                    simulated: [String: Int],
                    hardware: [String: Int]
                ) -> AnalysisReport {

                    let shots = hardware.values.reduce(0, +)

                    // Calculate fidelity
                    var fidelity = 0.0
                    for (state, simCount) in simulated {
                        let simProb = Double(simCount) / Double(shots)
                        let hwProb = Double(hardware[state] ?? 0) / Double(shots)
                        fidelity += sqrt(simProb * hwProb)
                    }

                    // Identify dominant errors
                    let unexpectedStates = hardware.keys.filter {
                        simulated[$0] == nil
                    }

                    return AnalysisReport(
                        fidelity: fidelity,
                        unexpectedStates: unexpectedStates,
                        recommendation: fidelity < 0.9 ?
                            "Consider error mitigation" :
                            "Results acceptable"
                    )
                }
                """,
                visualizationType: .probabilityChart,
                durationMinutes: 20
            ),
            AdvancedLesson.LessonModule(
                id: "ibm_best_practices",
                title: "Best Practices",
                content: """
                IBM Quantum Best Practices:

                1. Circuit Optimization
                   - Minimize depth (fewer gate layers)
                   - Use native gate set
                   - Avoid unnecessary SWAP gates

                2. Backend Selection
                   - Check calibration data
                   - Choose qubits with lowest error rates
                   - Consider queue times

                3. Result Validation
                   - Always run on simulator first
                   - Use multiple shots (1000+)
                   - Apply error mitigation

                4. Resource Management
                   - Monitor monthly quota
                   - Batch similar circuits
                   - Use runtime programs for repetitive tasks

                Enterprise tip: Reserved queue time guarantees <5 min execution!
                """,
                codeExample: nil,
                visualizationType: nil,
                durationMinutes: 15
            )
        ],
        practiceExercises: [
            AdvancedLesson.PracticeExercise(
                id: "ibm_ex1",
                title: "Bell State on Hardware",
                instruction: "Export Bell state circuit to QASM and analyze expected noise",
                starterCode: """
                let circuit = QuantumCircuit(qubitCount: 2)
                circuit.addGate(.hadamard, target: 0)
                circuit.addGate(.cnot, target: 1, control: 0)

                // TODO: Export to QASM
                // TODO: Calculate expected fidelity with 1% gate error
                """,
                solution: """
                let circuit = QuantumCircuit(qubitCount: 2)
                circuit.addGate(.hadamard, target: 0)
                circuit.addGate(.cnot, target: 1, control: 0)
                circuit.addGate(.measure, target: 0)
                circuit.addGate(.measure, target: 1)

                let qasm = circuit.toQASM()
                print(qasm)

                // Expected fidelity calculation
                let gateError = 0.01
                let numGates = 2  // H + CNOT
                let expectedFidelity = pow(1 - gateError, Double(numGates))
                print("Expected fidelity: \\(expectedFidelity)")  // ~0.98
                """,
                hints: [
                    "Each gate has independent error probability",
                    "Fidelity ≈ (1-error)^(num_gates)"
                ],
                xpReward: 40
            )
        ],
        quiz: AdvancedLesson.LessonQuiz(
            questions: [
                AdvancedLesson.LessonQuiz.QuizQuestion(
                    id: "ibm_q1",
                    question: "What is OpenQASM?",
                    options: [
                        "A quantum programming language",
                        "A quantum assembly language for circuit description",
                        "A quantum simulator",
                        "A quantum error correction code"
                    ],
                    correctIndex: 1,
                    explanation: "OpenQASM is a quantum assembly language used to describe quantum circuits"
                ),
                AdvancedLesson.LessonQuiz.QuizQuestion(
                    id: "ibm_q2",
                    question: "Why do real hardware results differ from simulation?",
                    options: [
                        "Hardware is slower",
                        "Simulation has bugs",
                        "Noise, decoherence, and gate errors",
                        "Different programming language"
                    ],
                    correctIndex: 2,
                    explanation: "Real quantum hardware suffers from noise, decoherence, and various error sources"
                )
            ],
            passingScore: 1,
            xpReward: 60
        )
    )

    // MARK: - All Advanced Lessons
    static let allAdvancedLessons: [AdvancedLesson] = [
        level9_BellState,
        level10_Grover,
        level11_Simon,
        level12_ErrorCorrection,
        level13_IBMQuantum
    ]

    // Pro tier lessons (9-11)
    static let proLessons: [AdvancedLesson] = [
        level9_BellState,
        level10_Grover,
        level11_Simon
    ]

    // Enterprise tier lessons (12-13)
    static let enterpriseLessons: [AdvancedLesson] = [
        level12_ErrorCorrection,
        level13_IBMQuantum
    ]
}

// MARK: - Extension for LearningLevel Integration
extension AdvancedLesson {
    func toLearningLevel() -> LearningLevel {
        LearningLevel(
            id: number,
            number: number,
            title: title,
            name: title,
            description: description,
            track: difficulty == .intermediate ? .intermediate : .advanced,
            xpReward: xpReward,
            estimatedTime: estimatedMinutes,
            prerequisites: [],
            lessons: modules.enumerated().map { index, module in
                LearningLevel.Lesson(
                    id: module.id,
                    title: module.title,
                    type: .theory,
                    content: module.content
                )
            }
        )
    }
}
