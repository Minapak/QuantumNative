//
//  LevelDetailView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//
//  MARK: - Level Detail View
//  Detailed view for a learning level showing sections,
//  theory content, interactive examples, and progress.
//

import SwiftUI

// MARK: - Level Detail View
/// Detailed view showing level content and progress
struct LevelDetailView: View {
    
    // MARK: - Properties
    let level: LearningLevel
    
    // MARK: - Environment
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @EnvironmentObject var learningViewModel: LearningViewModel
    
    // MARK: - State
    @State private var currentSectionIndex = 0
    @State private var showingCompletionAlert = false
    @State private var animateContent = false
    
    // MARK: - Computed Properties
    private var currentSection: LevelSection? {
        guard currentSectionIndex < level.sections.count else { return nil }
        return level.sections[currentSectionIndex]
    }
    
    private var isLastSection: Bool {
        currentSectionIndex >= level.sections.count - 1
    }
    
    private var progressFraction: CGFloat {
        guard !level.sections.isEmpty else { return 0 }
        return CGFloat(currentSectionIndex + 1) / CGFloat(level.sections.count)
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background
            Color.bgDark.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress header
                progressHeader
                
                // Content area
                contentArea
                
                // Navigation footer
                navigationFooter
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text("Level \(level.number)")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    Text(level.name)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.textTertiary)
                }
            }
        }
        .alert("Level Complete! 🎉", isPresented: $showingCompletionAlert) {
            Button("Continue", role: .cancel) {
                completeLevel()
                dismiss()
            }
        } message: {
            Text("You earned \(level.xpReward) XP!")
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animateContent = true
            }
        }
    }
    
    // MARK: - Progress Header
    /// Shows current progress through the level
    private var progressHeader: some View {
        VStack(spacing: 12) {
            // Section counter
            HStack {
                Text("Section \(currentSectionIndex + 1) of \(level.sections.count)")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                // XP badge
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .font(.caption2)
                    Text("+\(level.xpReward) XP")
                        .font(.caption.bold())
                }
                .foregroundColor(.quantumOrange)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 4)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.quantumCyan, .quantumPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * progressFraction,
                            height: 4
                        )
                        .animation(.easeOut(duration: 0.3), value: currentSectionIndex)
                }
            }
            .frame(height: 4)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.bgCard)
    }
    
    // MARK: - Content Area
    /// Main content area showing current section
    private var contentArea: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                if let section = currentSection {
                    // Section content based on type
                    sectionContent(for: section)
                        .offset(y: animateContent ? 0 : 20)
                        .opacity(animateContent ? 1 : 0)
                } else {
                    // Empty state
                    emptyStateView
                }
            }
            .padding(20)
        }
    }
    
    /// Content view based on section type
    @ViewBuilder
    private func sectionContent(for section: LevelSection) -> some View {
        switch section.type {
        case .theory:
            TheorySectionView(section: section)
            
        case .interactive:
            InteractiveSectionView(section: section)
            
        case .quiz:
            QuizSectionView(section: section)
            
        case .practice:
            PracticeSectionView(section: section)
        }
    }
    
    /// Empty state when no sections available
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 48))
                .foregroundColor(.textTertiary)
            
            Text("Content Coming Soon")
                .font(.headline)
                .foregroundColor(.textSecondary)
            
            Text("We're preparing this level's content.")
                .font(.subheadline)
                .foregroundColor(.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    // MARK: - Navigation Footer
    /// Bottom navigation with back/next buttons
    private var navigationFooter: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.white.opacity(0.1))
            
            HStack(spacing: 16) {
                // Back button
                if currentSectionIndex > 0 {
                    Button(action: goToPreviousSection) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.headline)
                        .foregroundColor(.textSecondary)
                    }
                }
                
                Spacer()
                
                // Next/Complete button
                Button(action: goToNextSection) {
                    HStack {
                        Text(isLastSection ? "Complete" : "Continue")
                        if !isLastSection {
                            Image(systemName: "chevron.right")
                        } else {
                            Image(systemName: "checkmark")
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.bgDark)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.quantumCyan, .quantumPurple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
            }
            .padding(20)
            .background(Color.bgCard)
        }
    }
    
    // MARK: - Actions
    
    /// Navigate to previous section
    private func goToPreviousSection() {
        withAnimation(.easeOut(duration: 0.3)) {
            animateContent = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            currentSectionIndex -= 1
            withAnimation(.easeOut(duration: 0.3)) {
                animateContent = true
            }
        }
    }
    
    /// Navigate to next section or complete level
    private func goToNextSection() {
        if isLastSection {
            showingCompletionAlert = true
        } else {
            withAnimation(.easeOut(duration: 0.3)) {
                animateContent = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                currentSectionIndex += 1
                withAnimation(.easeOut(duration: 0.3)) {
                    animateContent = true
                }
            }
        }
    }
    
    /// Complete the level and award XP
    private func completeLevel() {
        progressViewModel.completeLevel(level.id, xp: level.xpReward)
        learningViewModel.markLevelCompleted(level.id)
    }
}

// MARK: - Theory Section View
/// View for theory/explanation content
struct TheorySectionView: View {
    let section: LevelSection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section title
            HStack {
                Image(systemName: "book.fill")
                    .foregroundColor(.quantumCyan)
                Text(section.title)
                    .font(.title2.bold())
                    .foregroundColor(.textPrimary)
            }
            
            // Content text
            Text(section.content)
                .font(.body)
                .foregroundColor(.textSecondary)
                .lineSpacing(6)
            
            // Key points card
            if !section.keyPoints.isEmpty {
                keyPointsCard
            }
            
            // Visual/diagram placeholder
            if section.hasVisual {
                visualPlaceholder
            }
        }
    }
    
    /// Card showing key points
    private var keyPointsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Key Points")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            ForEach(Array(section.keyPoints.enumerated()), id: \.offset) { index, point in
                HStack(alignment: .top, spacing: 12) {
                    // Bullet
                    Circle()
                        .fill(Color.quantumCyan)
                        .frame(width: 8, height: 8)
                        .padding(.top, 6)
                    
                    Text(point)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding(16)
        .background(Color.bgCard)
        .cornerRadius(12)
    }
    
    /// Placeholder for visual content
    private var visualPlaceholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.bgCard)
            .frame(height: 200)
            .overlay(
                VStack(spacing: 8) {
                    Image(systemName: "photo")
                        .font(.title)
                    Text("Interactive Visual")
                        .font(.caption)
                }
                .foregroundColor(.textTertiary)
            )
    }
}

// MARK: - Interactive Section View
/// View for interactive demonstrations
struct InteractiveSectionView: View {
    let section: LevelSection
    
    @State private var interactionState: Int = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section title
            HStack {
                Image(systemName: "hand.tap.fill")
                    .foregroundColor(.quantumPurple)
                Text(section.title)
                    .font(.title2.bold())
                    .foregroundColor(.textPrimary)
            }
            
            // Instructions
            Text(section.content)
                .font(.body)
                .foregroundColor(.textSecondary)
            
            // Interactive area
            interactiveArea
        }
    }
    
    /// Interactive demo area
    private var interactiveArea: some View {
        VStack(spacing: 16) {
            // Bloch sphere placeholder (would be replaced with actual 3D view)
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.bgCard)
                .frame(height: 250)
                .overlay(
                    VStack(spacing: 12) {
                        // Simple state visualization
                        Circle()
                            .stroke(Color.quantumCyan, lineWidth: 2)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Circle()
                                    .fill(Color.quantumCyan)
                                    .frame(width: 12, height: 12)
                                    .offset(
                                        x: cos(Double(interactionState) * 0.5) * 40,
                                        y: sin(Double(interactionState) * 0.5) * 40
                                    )
                            )
                        
                        Text("State: |ψ⟩")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.quantumCyan)
                    }
                )
            
            // Control buttons
            HStack(spacing: 12) {
                ForEach(["H", "X", "Z", "Y"], id: \.self) { gate in
                    Button(action: { applyGate(gate) }) {
                        Text(gate)
                            .font(.headline.monospaced())
                            .frame(width: 50, height: 50)
                            .background(Color.bgCard)
                            .foregroundColor(.quantumCyan)
                            .cornerRadius(12)
                    }
                }
            }
            
            // State display
            Text("Apply quantum gates to see state changes")
                .font(.caption)
                .foregroundColor(.textTertiary)
        }
    }
    
    private func applyGate(_ gate: String) {
        withAnimation(.easeOut(duration: 0.3)) {
            interactionState += 1
        }
    }
}

// MARK: - Quiz Section View
/// View for quiz/assessment content
struct QuizSectionView: View {
    let section: LevelSection
    
    @State private var selectedAnswer: Int?
    @State private var showResult = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section title
            HStack {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundColor(.quantumOrange)
                Text(section.title)
                    .font(.title2.bold())
                    .foregroundColor(.textPrimary)
            }
            
            // Question
            Text(section.content)
                .font(.headline)
                .foregroundColor(.textPrimary)
                .padding(.vertical, 8)
            
            // Answer options
            VStack(spacing: 12) {
                ForEach(Array(section.quizOptions.enumerated()), id: \.offset) { index, option in
                    answerButton(option: option, index: index)
                }
            }
            
            // Result feedback
            if showResult {
                resultFeedback
            }
        }
    }
    
    /// Answer button for quiz option
    private func answerButton(option: String, index: Int) -> some View {
        Button(action: { selectAnswer(index) }) {
            HStack {
                // Option letter
                Text(String(Character(UnicodeScalar(65 + index)!)))
                    .font(.headline.monospaced())
                    .frame(width: 32, height: 32)
                    .background(optionBackgroundColor(for: index))
                    .foregroundColor(optionForegroundColor(for: index))
                    .cornerRadius(8)
                
                // Option text
                Text(option)
                    .font(.subheadline)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Check/X indicator
                if showResult && index == selectedAnswer {
                    Image(systemName: isCorrect(index) ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(isCorrect(index) ? .completed : .red)
                }
            }
            .padding(16)
            .background(Color.bgCard)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedAnswer == index ? Color.quantumCyan : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .disabled(showResult)
    }
    
    private func optionBackgroundColor(for index: Int) -> Color {
        if showResult {
            if isCorrect(index) {
                return .completed
            } else if index == selectedAnswer {
                return .red
            }
        }
        return selectedAnswer == index ? Color.quantumCyan : Color.white.opacity(0.1)
    }
    
    private func optionForegroundColor(for index: Int) -> Color {
        if showResult {
            if isCorrect(index) || index == selectedAnswer {
                return .white
            }
        }
        return selectedAnswer == index ? .bgDark : .textSecondary
    }
    
    /// Check if answer is correct
    private func isCorrect(_ index: Int) -> Bool {
        index == section.correctAnswerIndex
    }
    
    /// Select an answer
    private func selectAnswer(_ index: Int) {
        selectedAnswer = index
        withAnimation(.easeOut(duration: 0.3)) {
            showResult = true
        }
    }
    
    /// Result feedback view
    private var resultFeedback: some View {
        HStack(spacing: 12) {
            Image(systemName: selectedAnswer == section.correctAnswerIndex ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(selectedAnswer == section.correctAnswerIndex ? "Correct!" : "Not quite")
                    .font(.headline)
                
                Text(section.explanation)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
        .foregroundColor(selectedAnswer == section.correctAnswerIndex ? .completed : .red)
        .padding(16)
        .background(
            (selectedAnswer == section.correctAnswerIndex ? Color.completed : Color.red)
                .opacity(0.1)
        )
        .cornerRadius(12)
    }
}

// MARK: - Practice Section View
/// View for hands-on practice
struct PracticeSectionView: View {
    let section: LevelSection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section title
            HStack {
                Image(systemName: "flask.fill")
                    .foregroundColor(.completed)
                Text(section.title)
                    .font(.title2.bold())
                    .foregroundColor(.textPrimary)
            }
            
            // Instructions
            Text(section.content)
                .font(.body)
                .foregroundColor(.textSecondary)
            
            // Practice area placeholder
            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.bgCard)
                    .frame(height: 300)
                    .overlay(
                        VStack(spacing: 16) {
                            Image(systemName: "atom")
                                .font(.system(size: 48))
                                .foregroundColor(.quantumCyan)
                            
                            Text("Practice Area")
                                .font(.headline)
                                .foregroundColor(.textPrimary)
                            
                            Text("Interactive quantum simulation")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                    )
            }
        }
    }
}

// MARK: - Preview Provider
#Preview("Level Detail View") {
    NavigationStack {
        LevelDetailView(
            level: LearningLevel.sampleWithSections
        )
        .environmentObject(ProgressViewModel.sample)
        .environmentObject(LearningViewModel.sample)
    }
    .preferredColorScheme(.dark)
}

#Preview("Theory Section") {
    ZStack {
        Color.bgDark.ignoresSafeArea()
        
        ScrollView {
            TheorySectionView(
                section: LevelSection(
                    id: "theory-1",
                    title: "What is a Qubit?",
                    type: .theory,
                    content: "A qubit (quantum bit) is the basic unit of quantum information. Unlike a classical bit which can be either 0 or 1, a qubit can exist in a superposition of both states simultaneously.",
                    keyPoints: [
                        "Qubits can be 0, 1, or both at the same time",
                        "Superposition allows parallel computation",
                        "Measurement collapses the superposition"
                    ],
                    hasVisual: true
                )
            )
            .padding()
        }
    }
}

#Preview("Quiz Section") {
    ZStack {
        Color.bgDark.ignoresSafeArea()
        
        ScrollView {
            QuizSectionView(
                section: LevelSection(
                    id: "quiz-1",
                    title: "Check Your Understanding",
                    type: .quiz,
                    content: "What happens when you measure a qubit in superposition?",
                    quizOptions: [
                        "It stays in superposition",
                        "It collapses to either 0 or 1",
                        "It becomes entangled",
                        "Nothing happens"
                    ],
                    correctAnswerIndex: 1,
                    explanation: "When measured, a qubit in superposition collapses to one of its basis states (0 or 1) with a probability determined by its quantum state."
                )
            )
            .padding()
        }
    }
}

// MARK: - Sample Data Extensions
extension LearningLevel {
    /// Sample level with sections for previews
    static var sampleWithSections: LearningLevel {
        LearningLevel(
            id: "level-1",
            number: 1,
            name: "Quantum Basics",
            description: "Learn the fundamentals of quantum computing",
            concepts: ["Qubit", "Superposition", "Measurement"],
            status: .inProgress,
            progressPercentage: 30,
            xpReward: 100,
            estimatedMinutes: 15,
            sections: [
                LevelSection(
                    id: "s1",
                    title: "Introduction to Qubits",
                    type: .theory,
                    content: "A qubit is the fundamental unit of quantum information. Unlike classical bits that can only be 0 or 1, qubits can exist in a superposition of both states simultaneously.",
                    keyPoints: [
                        "Qubits are quantum mechanical systems",
                        "They can represent 0, 1, or both",
                        "Superposition enables quantum parallelism"
                    ],
                    hasVisual: true
                ),
                LevelSection(
                    id: "s2",
                    title: "Explore Superposition",
                    type: .interactive,
                    content: "Use the controls below to apply quantum gates and see how they affect the qubit state."
                ),
                LevelSection(
                    id: "s3",
                    title: "Quick Check",
                    type: .quiz,
                    content: "What is the key difference between a classical bit and a qubit?",
                    quizOptions: [
                        "Qubits are faster",
                        "Qubits can be in superposition",
                        "Qubits are smaller",
                        "There is no difference"
                    ],
                    correctAnswerIndex: 1,
                    explanation: "The key difference is that qubits can exist in a superposition of states, while classical bits can only be 0 or 1."
                )
            ]
        )
    }
}
