//
//  InteractiveOdysseyView.swift
//  SwiftQuantumLearning
//
//  Frame 2: Laboratory - Interactive Odyssey View
//  Text-free beginner tutorial with 3D Bloch Sphere visualization
//  Game-like interactions with Glassmorphism effects
//
//  Created by SwiftQuantum Team
//  Copyright © 2026 SwiftQuantum. All rights reserved.
//

import SwiftUI
import SceneKit

// MARK: - Interactive Tutorial Step
struct TutorialStep: Identifiable {
    let id: Int
    let titleKey: String
    let descriptionKey: String
    let interactiveElement: InteractiveElement
    let gateToApply: QuantumGateType?

    enum InteractiveElement {
        case blochSphere
        case gateSelector
        case measurementButton
        case circuitBuilder
    }
}

// MARK: - Bloch Sphere 3D View
struct BlochSphereView3D: UIViewRepresentable {
    @Binding var theta: Double // 0 to PI
    @Binding var phi: Double   // 0 to 2PI
    @Binding var isAnimating: Bool

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = createScene()
        scnView.backgroundColor = .clear
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        scnView.antialiasingMode = .multisampling4X
        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        guard let stateVector = uiView.scene?.rootNode.childNode(withName: "stateVector", recursively: true) else { return }

        // Calculate state vector position from theta/phi
        let x = sin(theta) * cos(phi)
        let y = sin(theta) * sin(phi)
        let z = cos(theta)

        // Animate to new position
        if isAnimating {
            let moveAction = SCNAction.move(to: SCNVector3(Float(x), Float(z), Float(y)), duration: 0.5)
            moveAction.timingMode = .easeInEaseOut
            stateVector.runAction(moveAction)
        } else {
            stateVector.position = SCNVector3(Float(x), Float(z), Float(y))
        }
    }

    private func createScene() -> SCNScene {
        let scene = SCNScene()

        // Sphere (Bloch sphere surface)
        let sphereGeometry = SCNSphere(radius: 1.0)
        sphereGeometry.segmentCount = 64
        let sphereMaterial = SCNMaterial()
        sphereMaterial.diffuse.contents = UIColor(white: 0.3, alpha: 0.3)
        sphereMaterial.transparency = 0.7
        sphereMaterial.isDoubleSided = true
        sphereGeometry.materials = [sphereMaterial]
        let sphereNode = SCNNode(geometry: sphereGeometry)
        scene.rootNode.addChildNode(sphereNode)

        // Axis lines
        addAxis(to: scene, direction: SCNVector3(1, 0, 0), color: .red, label: "X")
        addAxis(to: scene, direction: SCNVector3(0, 1, 0), color: .blue, label: "Z")
        addAxis(to: scene, direction: SCNVector3(0, 0, 1), color: .green, label: "Y")

        // State vector (arrow)
        let arrowNode = createStateVector()
        arrowNode.name = "stateVector"
        arrowNode.position = SCNVector3(0, 1, 0) // Start at |0⟩
        scene.rootNode.addChildNode(arrowNode)

        // |0⟩ and |1⟩ labels
        addStateLabel(to: scene, text: "|0⟩", position: SCNVector3(0, 1.2, 0), color: .cyan)
        addStateLabel(to: scene, text: "|1⟩", position: SCNVector3(0, -1.2, 0), color: .orange)

        // Camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(3, 2, 3)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(cameraNode)

        // Ambient light
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor.white.withAlphaComponent(0.5)
        scene.rootNode.addChildNode(ambientLight)

        return scene
    }

    private func addAxis(to scene: SCNScene, direction: SCNVector3, color: UIColor, label: String) {
        let cylinder = SCNCylinder(radius: 0.02, height: 2.2)
        let material = SCNMaterial()
        material.diffuse.contents = color.withAlphaComponent(0.6)
        cylinder.materials = [material]

        let node = SCNNode(geometry: cylinder)
        node.position = SCNVector3(direction.x * 0.55, direction.y * 0.55, direction.z * 0.55)

        if direction.x != 0 {
            node.eulerAngles.z = Float.pi / 2
        } else if direction.z != 0 {
            node.eulerAngles.x = Float.pi / 2
        }

        scene.rootNode.addChildNode(node)
    }

    private func createStateVector() -> SCNNode {
        let parentNode = SCNNode()

        // Arrow shaft
        let cylinder = SCNCylinder(radius: 0.03, height: 0.9)
        let shaftMaterial = SCNMaterial()
        shaftMaterial.diffuse.contents = UIColor.cyan
        shaftMaterial.emission.contents = UIColor.cyan.withAlphaComponent(0.3)
        cylinder.materials = [shaftMaterial]

        let shaftNode = SCNNode(geometry: cylinder)
        shaftNode.position = SCNVector3(0, -0.45, 0)
        parentNode.addChildNode(shaftNode)

        // Arrow head (cone)
        let cone = SCNCone(topRadius: 0, bottomRadius: 0.08, height: 0.15)
        let coneMaterial = SCNMaterial()
        coneMaterial.diffuse.contents = UIColor.cyan
        coneMaterial.emission.contents = UIColor.cyan.withAlphaComponent(0.5)
        cone.materials = [coneMaterial]

        let coneNode = SCNNode(geometry: cone)
        coneNode.position = SCNVector3(0, 0.075, 0)
        parentNode.addChildNode(coneNode)

        // Glow sphere at tip
        let glowSphere = SCNSphere(radius: 0.08)
        let glowMaterial = SCNMaterial()
        glowMaterial.diffuse.contents = UIColor.cyan
        glowMaterial.emission.contents = UIColor.cyan
        glowSphere.materials = [glowMaterial]

        let glowNode = SCNNode(geometry: glowSphere)
        glowNode.position = SCNVector3(0, 0, 0)
        parentNode.addChildNode(glowNode)

        return parentNode
    }

    private func addStateLabel(to scene: SCNScene, text: String, position: SCNVector3, color: UIColor) {
        let textGeometry = SCNText(string: text, extrusionDepth: 0.02)
        textGeometry.font = UIFont.systemFont(ofSize: 0.2, weight: .bold)
        let material = SCNMaterial()
        material.diffuse.contents = color
        textGeometry.materials = [material]

        let textNode = SCNNode(geometry: textGeometry)
        textNode.position = position
        textNode.scale = SCNVector3(0.5, 0.5, 0.5)

        // Billboard constraint to always face camera
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = .all
        textNode.constraints = [billboardConstraint]

        scene.rootNode.addChildNode(textNode)
    }
}

// MARK: - Interactive Odyssey View
struct InteractiveOdysseyView: View {
    @ObservedObject var translationManager = QuantumTranslationManager.shared
    @StateObject private var storeKitService = StoreKitService.shared

    // Bloch Sphere State
    @State private var theta: Double = 0 // Start at |0⟩
    @State private var phi: Double = 0
    @State private var isAnimating = false

    // Tutorial State
    @State private var currentStep = 0
    @State private var showSuperpositionFeedback = false
    @State private var selectedGate: QuantumGateType?

    let tutorialSteps: [TutorialStep] = [
        TutorialStep(id: 0, titleKey: "odyssey.step1.title", descriptionKey: "odyssey.step1.desc", interactiveElement: .blochSphere, gateToApply: nil),
        TutorialStep(id: 1, titleKey: "odyssey.step2.title", descriptionKey: "odyssey.step2.desc", interactiveElement: .gateSelector, gateToApply: .hadamard),
        TutorialStep(id: 2, titleKey: "odyssey.step3.title", descriptionKey: "odyssey.step3.desc", interactiveElement: .gateSelector, gateToApply: .pauliX),
        TutorialStep(id: 3, titleKey: "odyssey.step4.title", descriptionKey: "odyssey.step4.desc", interactiveElement: .measurementButton, gateToApply: nil)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.odysseyGradient
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Theory Scroll (Top)
                    theorySection

                    // 3D Bloch Sphere (Middle)
                    blochSphereSection

                    // Interactive Controls (Bottom)
                    controlsSection
                }

                // Superposition Feedback Overlay
                if showSuperpositionFeedback {
                    superpositionFeedback
                }

                // Solar Agent
                VStack {
                    Spacer()
                    SolarAgentBubble()
                        .padding()
                }
            }
            .navigationTitle(NSLocalizedString("odyssey.title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Theory Section
    private var theorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            let step = tutorialSteps[currentStep]

            // Step indicator
            HStack {
                ForEach(0..<tutorialSteps.count, id: \.self) { index in
                    Circle()
                        .fill(index <= currentStep ? Color.quantumCyan : Color.white.opacity(0.2))
                        .frame(width: 8, height: 8)
                }
                Spacer()
                Text("\(currentStep + 1)/\(tutorialSteps.count)")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }

            // Title
            Text(NSLocalizedString(step.titleKey, comment: ""))
                .font(.title3.bold())
                .foregroundColor(.white)

            // Description with interactive keywords
            InteractiveTextView(
                text: NSLocalizedString(step.descriptionKey, comment: ""),
                onKeywordTap: handleKeywordTap
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.bgCard)
                .glassMorphism()
        )
        .padding(.horizontal)
    }

    // MARK: - Bloch Sphere Section
    private var blochSphereSection: some View {
        ZStack {
            BlochSphereView3D(theta: $theta, phi: $phi, isAnimating: $isAnimating)
                .frame(height: 300)

            // State label
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    stateLabel
                        .padding()
                }
            }
        }
    }

    private var stateLabel: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(NSLocalizedString("odyssey.currentState", comment: ""))
                .font(.caption2)
                .foregroundColor(.textSecondary)

            Text(stateDescription)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.quantumCyan)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.bgCard.opacity(0.9))
                .glassMorphism()
        )
    }

    private var stateDescription: String {
        if theta < 0.01 {
            return "|0⟩"
        } else if abs(theta - .pi) < 0.01 {
            return "|1⟩"
        } else if abs(theta - .pi/2) < 0.1 {
            return "(|0⟩ + |1⟩)/√2"
        } else {
            let alpha = cos(theta/2)
            let beta = sin(theta/2)
            return String(format: "%.2f|0⟩ + %.2f|1⟩", alpha, beta)
        }
    }

    // MARK: - Controls Section
    private var controlsSection: some View {
        VStack(spacing: 16) {
            // Gate Buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach([QuantumGateType.hadamard, .pauliX, .pauliY, .pauliZ], id: \.rawValue) { gate in
                        OdysseyGateButton(
                            gate: gate,
                            isSelected: selectedGate == gate,
                            onTap: { applyGate(gate) }
                        )
                    }

                    // Measure Button
                    Button {
                        performMeasurement()
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "scope")
                                .font(.title2)
                            Text(NSLocalizedString("odyssey.measure", comment: ""))
                                .font(.caption2)
                        }
                        .foregroundColor(.white)
                        .frame(width: 70, height: 70)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.solarGold)
                        )
                    }
                }
                .padding(.horizontal)
            }

            // Navigation Buttons
            HStack(spacing: 16) {
                if currentStep > 0 {
                    Button {
                        withAnimation { currentStep -= 1 }
                    } label: {
                        Label(NSLocalizedString("common.back", comment: ""), systemImage: "chevron.left")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                    }
                }

                Spacer()

                if currentStep < tutorialSteps.count - 1 {
                    Button {
                        withAnimation { currentStep += 1 }
                        translationManager.boostFireEnergy(by: 0.03)
                    } label: {
                        Label(NSLocalizedString("common.next", comment: ""), systemImage: "chevron.right")
                            .font(.subheadline.bold())
                            .foregroundColor(.quantumCyan)
                    }
                } else {
                    Button {
                        translationManager.onLessonCompleted()
                    } label: {
                        Label(NSLocalizedString("common.done", comment: ""), systemImage: "checkmark.circle.fill")
                            .font(.subheadline.bold())
                            .foregroundColor(.completed)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(
            Rectangle()
                .fill(Color.bgCard)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    // MARK: - Superposition Feedback
    private var superpositionFeedback: some View {
        VStack(spacing: 16) {
            Text("✨")
                .font(.system(size: 60))

            Text(NSLocalizedString("odyssey.superposition.achieved", comment: ""))
                .font(.title2.bold())
                .foregroundColor(.white)

            Text(NSLocalizedString("odyssey.superposition.explanation", comment: ""))
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.quantumCyan.opacity(0.5), lineWidth: 2)
                )
        )
        .glassMorphism()
        .transition(.scale.combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    showSuperpositionFeedback = false
                }
            }
        }
    }

    // MARK: - Actions
    private func applyGate(_ gate: QuantumGateType) {
        selectedGate = gate
        isAnimating = true

        withAnimation(.spring()) {
            switch gate {
            case .hadamard:
                // H gate: |0⟩ -> (|0⟩+|1⟩)/√2
                if theta < 0.01 {
                    theta = .pi / 2
                    phi = 0
                    showSuperpositionFeedback = true
                } else {
                    theta = 0
                }
            case .pauliX:
                // X gate: |0⟩ <-> |1⟩
                theta = .pi - theta
            case .pauliY:
                // Y gate
                theta = .pi - theta
                phi = phi + .pi
            case .pauliZ:
                // Z gate: phase flip
                phi = phi + .pi
            default:
                break
            }
        }

        translationManager.boostFireEnergy(by: 0.02)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isAnimating = false
            selectedGate = nil
        }
    }

    private func performMeasurement() {
        let prob0 = cos(theta / 2) * cos(theta / 2)
        let result = Double.random(in: 0...1) < prob0 ? 0 : 1

        withAnimation(.spring()) {
            theta = result == 0 ? 0 : .pi
            phi = 0
        }

        translationManager.showSolarMessage(type: .tip)
    }

    private func handleKeywordTap(_ keyword: String) {
        // When user taps "Hadamard" in text
        if keyword.lowercased().contains("hadamard") {
            applyGate(.hadamard)
        } else if keyword.lowercased().contains("superposition") {
            // Show explanation
            translationManager.showSolarMessage(type: .tip)
        }
    }
}

// MARK: - Odyssey Gate Button
struct OdysseyGateButton: View {
    let gate: QuantumGateType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Text(gate.rawValue)
                    .font(.system(.title2, design: .monospaced).bold())
                Text(gate.displayName)
                    .font(.caption2)
            }
            .foregroundColor(isSelected ? .black : .white)
            .frame(width: 70, height: 70)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.quantumCyan : gate.color.opacity(0.8))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.quantumCyan : Color.clear, lineWidth: 2)
            )
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(), value: isSelected)
    }
}

// MARK: - Interactive Text View
struct InteractiveTextView: View {
    let text: String
    let onKeywordTap: (String) -> Void

    // Keywords to highlight
    private let keywords = ["Hadamard", "Superposition", "CNOT", "Entanglement", "Measurement", "중첩", "얽힘", "하다마드"]

    var body: some View {
        // Simple implementation - highlight keywords
        Text(attributedText)
            .font(.subheadline)
            .foregroundColor(.textSecondary)
    }

    private var attributedText: AttributedString {
        var result = AttributedString(text)

        for keyword in keywords {
            if let range = result.range(of: keyword, options: .caseInsensitive) {
                result[range].foregroundColor = .quantumCyan
                result[range].font = .subheadline.bold()
            }
        }

        return result
    }
}

// MARK: - Preview
#Preview {
    InteractiveOdysseyView()
}
