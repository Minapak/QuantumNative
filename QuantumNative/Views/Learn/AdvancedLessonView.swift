//
//  AdvancedLessonView.swift
//  SwiftQuantumLearning
//
//  고급 레슨 뷰 (Level 9-13)
//  프리미엄 콘텐츠 UI/UX
//
//  Created by SwiftQuantum Team
//  Copyright © 2026 SwiftQuantum. All rights reserved.
//

import SwiftUI

// MARK: - Advanced Lessons List View
struct AdvancedLessonsListView: View {
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @State private var selectedLesson: AdvancedLesson?
    @State private var showPremiumUpgrade = false
    @State private var userTier: SubscriptionTier? = nil

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    // Harvard-MIT Badge
                    harvardMITBadge

                    // Pro Tier Lessons (9-11)
                    tierSection(
                        title: "Pro Tier",
                        subtitle: "Harvard-MIT Algorithms",
                        lessons: AdvancedLessonsContent.proLessons,
                        tier: .pro
                    )

                    // Enterprise Tier Lessons (12-13)
                    tierSection(
                        title: "Enterprise Tier",
                        subtitle: "Fault-Tolerant & IBM Quantum",
                        lessons: AdvancedLessonsContent.enterpriseLessons,
                        tier: .premium
                    )
                }
                .padding()
            }
            .background(Color.bgDark.ignoresSafeArea())
            .navigationTitle("Advanced Courses")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(item: $selectedLesson) { lesson in
            AdvancedLessonDetailView(lesson: lesson, userTier: userTier)
                .environmentObject(progressViewModel)
        }
        .sheet(isPresented: $showPremiumUpgrade) {
            PremiumUpgradeView()
                .environmentObject(progressViewModel)
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("Premium Learning Path")
                    .font(.headline)
                    .foregroundColor(.yellow)
            }

            Text("Master advanced quantum algorithms and real hardware integration")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.yellow.opacity(0.1))
        )
    }

    // MARK: - Harvard-MIT Badge
    private var harvardMITBadge: some View {
        HStack(spacing: 12) {
            Image(systemName: "graduationcap.fill")
                .font(.title2)
                .foregroundColor(.quantumPurple)

            VStack(alignment: .leading, spacing: 4) {
                Text("Based on Harvard-MIT 2026 Research")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Text("3,000 qubit continuous operation architecture")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .font(.title2)
                .foregroundColor(.quantumCyan)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.quantumPurple.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.quantumPurple.opacity(0.3), lineWidth: 1)
                )
        )
    }

    // MARK: - Tier Section
    @ViewBuilder
    private func tierSection(title: String, subtitle: String, lessons: [AdvancedLesson], tier: SubscriptionTier) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Tier Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text(tier == .pro ? "$9.99/mo" : "$29.99/mo")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(tier == .pro ? Color.quantumCyan : Color.quantumOrange)
                            )
                    }

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                if userTier == nil || (tier == .premium && userTier == .pro) {
                    Button {
                        showPremiumUpgrade = true
                    } label: {
                        Text("Unlock")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: tier == .pro ?
                                                [.quantumCyan, .quantumPurple] :
                                                [Color(hex: "FFD700"), Color(hex: "FF8C00")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                    }
                }
            }

            // Lesson Cards
            ForEach(lessons) { lesson in
                AdvancedLessonCard(
                    lesson: lesson,
                    isLocked: !canAccessLesson(lesson),
                    onTap: {
                        if canAccessLesson(lesson) {
                            selectedLesson = lesson
                        } else {
                            showPremiumUpgrade = true
                        }
                    }
                )
            }
        }
    }

    private func canAccessLesson(_ lesson: AdvancedLesson) -> Bool {
        switch lesson.tier {
        case .free: return true
        case .pro: return userTier == .pro || userTier == .premium
        case .enterprise: return userTier == .premium
        }
    }
}

// MARK: - Advanced Lesson Card
struct AdvancedLessonCard: View {
    let lesson: AdvancedLesson
    let isLocked: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Level Number
                ZStack {
                    Circle()
                        .fill(isLocked ? Color.locked : lesson.difficulty.color)
                        .frame(width: 50, height: 50)

                    if isLocked {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.white)
                    } else {
                        Text("\(lesson.number)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }

                // Content
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(lesson.title)
                            .font(.headline)
                            .foregroundColor(isLocked ? .textSecondary : .white)
                            .lineLimit(1)

                        Spacer()

                        // Difficulty Badge
                        Text(lesson.difficulty.rawValue)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(lesson.difficulty.color.opacity(0.8))
                            )
                    }

                    Text(lesson.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                        .lineLimit(1)

                    HStack(spacing: 16) {
                        Label("\(lesson.estimatedMinutes) min", systemImage: "clock")
                        Label("\(lesson.xpReward) XP", systemImage: "star.fill")

                        if lesson.modules.count > 0 {
                            Label("\(lesson.modules.count) modules", systemImage: "book.closed")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.textTertiary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.bgCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isLocked ? Color.clear : lesson.difficulty.color.opacity(0.3), lineWidth: 1)
                    )
            )
            .opacity(isLocked ? 0.7 : 1)
        }
    }
}

// MARK: - Advanced Lesson Detail View
struct AdvancedLessonDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var progressViewModel: ProgressViewModel
    let lesson: AdvancedLesson
    let userTier: SubscriptionTier?

    @State private var currentModuleIndex = 0
    @State private var showQuiz = false
    @State private var showPractice = false
    @State private var completedModules: Set<String> = []

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Lesson Header
                    lessonHeader

                    // Progress Bar
                    progressBar

                    // Current Module
                    if currentModuleIndex < lesson.modules.count {
                        moduleContent(lesson.modules[currentModuleIndex])
                    }

                    // Navigation Buttons
                    navigationButtons

                    // Objectives
                    objectivesSection

                    // Practice Exercises
                    if !lesson.practiceExercises.isEmpty {
                        practiceSection
                    }
                }
                .padding()
            }
            .background(Color.bgDark.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.textSecondary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showQuiz = true
                    } label: {
                        Text("Take Quiz")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.quantumCyan)
                    }
                    .disabled(lesson.quiz == nil)
                }
            }
        }
        .sheet(isPresented: $showQuiz) {
            if let quiz = lesson.quiz {
                LessonQuizView(quiz: quiz, lessonTitle: lesson.title)
                    .environmentObject(progressViewModel)
            }
        }
    }

    // MARK: - Lesson Header
    private var lessonHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Level \(lesson.number)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.quantumCyan)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.quantumCyan.opacity(0.2)))

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(lesson.xpReward) XP")
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .foregroundColor(.yellow)
            }

            Text(lesson.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text(lesson.description)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Progress Bar
    private var progressBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Module \(currentModuleIndex + 1) of \(lesson.modules.count)")
                    .font(.caption)
                    .foregroundColor(.textSecondary)

                Spacer()

                Text("\(Int(moduleProgress * 100))% Complete")
                    .font(.caption)
                    .foregroundColor(.quantumCyan)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.bgCard)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.quantumCyan, .quantumPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * moduleProgress, height: 8)
                }
            }
            .frame(height: 8)
        }
    }

    private var moduleProgress: Double {
        Double(currentModuleIndex + 1) / Double(lesson.modules.count)
    }

    // MARK: - Module Content
    @ViewBuilder
    private func moduleContent(_ module: AdvancedLesson.LessonModule) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(module.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Spacer()

                Label("\(module.durationMinutes) min", systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }

            Text(module.content)
                .font(.body)
                .foregroundColor(.textSecondary)
                .lineSpacing(6)

            if let code = module.codeExample {
                codeBlock(code)
            }

            if let vizType = module.visualizationType {
                visualizationPlaceholder(vizType)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.bgCard)
        )
    }

    private func codeBlock(_ code: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Swift")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.quantumCyan)

                Spacer()

                Button {
                    #if os(iOS)
                    UIPasteboard.general.string = code
                    #elseif os(macOS)
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(code, forType: .string)
                    #endif
                } label: {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.textSecondary)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                Text(code)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.5))
        )
    }

    private func visualizationPlaceholder(_ type: AdvancedLesson.LessonModule.VisualizationType) -> some View {
        HStack {
            Image(systemName: "waveform.path.ecg.rectangle")
                .font(.title)
                .foregroundColor(.quantumPurple)

            VStack(alignment: .leading) {
                Text(type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text("Interactive visualization")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            Button {
                // Show interactive visualization
            } label: {
                Text("View")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.quantumCyan)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().stroke(Color.quantumCyan, lineWidth: 1))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.quantumPurple.opacity(0.1))
        )
    }

    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            Button {
                withAnimation {
                    currentModuleIndex = max(0, currentModuleIndex - 1)
                }
            } label: {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Previous")
                }
            }
            .buttonStyle(.quantumSecondary)
            .disabled(currentModuleIndex == 0)

            Button {
                withAnimation {
                    if currentModuleIndex < lesson.modules.count - 1 {
                        currentModuleIndex += 1
                    }
                }
            } label: {
                HStack {
                    Text(currentModuleIndex < lesson.modules.count - 1 ? "Next" : "Complete")
                    Image(systemName: currentModuleIndex < lesson.modules.count - 1 ? "chevron.right" : "checkmark")
                }
            }
            .buttonStyle(.quantumPrimary)
        }
    }

    // MARK: - Objectives Section
    private var objectivesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Learning Objectives")
                .font(.headline)
                .foregroundColor(.white)

            ForEach(lesson.objectives, id: \.self) { objective in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.quantumCyan)
                    Text(objective)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.bgCard)
        )
    }

    // MARK: - Practice Section
    private var practiceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Practice Exercises")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Text("\(lesson.practiceExercises.count) exercises")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }

            ForEach(lesson.practiceExercises) { exercise in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)

                        HStack {
                            Label("\(exercise.xpReward) XP", systemImage: "star.fill")
                                .foregroundColor(.yellow)
                            Text("\(exercise.hints.count) hints")
                                .foregroundColor(.textSecondary)
                        }
                        .font(.caption)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.textSecondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.bgElevated)
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.bgCard)
        )
    }
}

// MARK: - Lesson Quiz View
struct LessonQuizView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var progressViewModel: ProgressViewModel
    let quiz: AdvancedLesson.LessonQuiz
    let lessonTitle: String

    @State private var currentQuestionIndex = 0
    @State private var selectedAnswers: [Int] = []
    @State private var showResults = false
    @State private var score = 0

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                if showResults {
                    resultsView
                } else {
                    questionView
                }
            }
            .padding()
            .background(Color.bgDark.ignoresSafeArea())
            .navigationTitle("Quiz: \(lessonTitle)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.textSecondary)
                }
            }
        }
    }

    private var questionView: some View {
        VStack(spacing: 24) {
            // Progress
            HStack {
                Text("Question \(currentQuestionIndex + 1) of \(quiz.questions.count)")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)

                Spacer()

                Text("\(quiz.xpReward) XP")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.yellow)
            }

            let question = quiz.questions[currentQuestionIndex]

            // Question
            Text(question.question)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            // Options
            VStack(spacing: 12) {
                ForEach(question.options.indices, id: \.self) { index in
                    Button {
                        selectAnswer(index)
                    } label: {
                        HStack {
                            Text(question.options[index])
                                .font(.body)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)

                            Spacer()

                            if selectedAnswers.count > currentQuestionIndex &&
                               selectedAnswers[currentQuestionIndex] == index {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.quantumCyan)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.bgCard)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            selectedAnswers.count > currentQuestionIndex &&
                                            selectedAnswers[currentQuestionIndex] == index ?
                                            Color.quantumCyan : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                        )
                    }
                }
            }

            Spacer()

            // Next Button
            Button {
                if currentQuestionIndex < quiz.questions.count - 1 {
                    currentQuestionIndex += 1
                } else {
                    calculateScore()
                    showResults = true
                }
            } label: {
                Text(currentQuestionIndex < quiz.questions.count - 1 ? "Next Question" : "Submit")
            }
            .buttonStyle(.quantumPrimary)
            .disabled(selectedAnswers.count <= currentQuestionIndex)
        }
    }

    private var resultsView: some View {
        VStack(spacing: 24) {
            let passed = score >= quiz.passingScore

            Image(systemName: passed ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(passed ? .green : .red)

            Text(passed ? "Congratulations!" : "Keep Learning!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("Score: \(score) / \(quiz.questions.count)")
                .font(.title2)
                .foregroundColor(.textSecondary)

            if passed {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("+\(quiz.xpReward) XP earned!")
                        .fontWeight(.semibold)
                }
                .font(.headline)
                .foregroundColor(.yellow)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Continue")
            }
            .buttonStyle(.quantumPrimary)
        }
    }

    private func selectAnswer(_ index: Int) {
        if selectedAnswers.count <= currentQuestionIndex {
            selectedAnswers.append(index)
        } else {
            selectedAnswers[currentQuestionIndex] = index
        }
    }

    private func calculateScore() {
        score = 0
        for (index, answer) in selectedAnswers.enumerated() {
            if index < quiz.questions.count &&
               answer == quiz.questions[index].correctIndex {
                score += 1
            }
        }
    }
}

// MARK: - Extension for Identifiable
extension AdvancedLesson: Equatable {
    static func == (lhs: AdvancedLesson, rhs: AdvancedLesson) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Preview
#Preview {
    AdvancedLessonsListView()
        .environmentObject(ProgressViewModel())
}
