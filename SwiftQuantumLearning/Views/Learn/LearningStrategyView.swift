//
//  LearningStrategyView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

// MARK: - Learning Strategy View
struct LearningStrategyView: View {
    let level: LearningLevel
    @EnvironmentObject var learnViewModel: LearnViewModel
    @State private var selectedStrategy: LearnViewModel.LearningStrategy = .memory
    @State private var expandedCard: String?
    @State private var animateContent = false
    
    var body: some View {
        ZStack {
            Color.bgDark.ignoresSafeArea()
            
            VStack(spacing: 0) {
                strategySelector
                ScrollView(.vertical, showsIndicators: false) {
                    strategyContent
                        .padding(20)
                }
            }
        }
        .navigationTitle("Learning Strategies")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear {
            learnViewModel.loadLearningStrategies(for: level)
            withAnimation(.easeOut(duration: 0.5)) {
                animateContent = true
            }
        }
    }
    
    // MARK: - Strategy Selector
    private var strategySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(LearnViewModel.LearningStrategy.allCases, id: \.self) { strategy in
                    StrategyButton(
                        strategy: strategy,
                        isSelected: selectedStrategy == strategy,
                        action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedStrategy = strategy
                            }
                        }
                    )
                }
            }
            .padding(16)
        }
        .background(Color.bgCard)
    }
    
    // MARK: - Strategy Content
    @ViewBuilder
    private var strategyContent: some View {
        switch selectedStrategy {
        case .memory:
            memoryTriggersView
        case .conceptMap:
            conceptMapsView
        case .feynman:
            feynmanView
        }
    }
    
    // MARK: - Memory Triggers View
    private var memoryTriggersView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Memory Triggers & Mnemonics")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                ForEach(Array(learnViewModel.memoryTriggers.enumerated()), id: \.element.id) { index, trigger in
                    MemoryTriggerCard(
                        trigger: trigger,
                        isExpanded: expandedCard == trigger.id,
                        onTap: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                expandedCard = expandedCard == trigger.id ? nil : trigger.id
                            }
                        }
                    )
                    .offset(y: animateContent ? 0 : 20)
                    .opacity(animateContent ? 1 : 0)
                    .animation(
                        .easeOut(duration: 0.4).delay(Double(index) * 0.1),
                        value: animateContent
                    )
                }
            }
            
            StrategyTipCard(
                icon: "lightbulb.fill",
                title: "Memory Tip",
                description: "Use these mnemonics to create mental anchors. Repeat them while studying to strengthen memory recall.",
                color: .quantumYellow
            )
        }
    }
    
    // MARK: - Concept Maps View
    private var conceptMapsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Concept Maps")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                ForEach(learnViewModel.conceptMaps, id: \.id) { map in
                    ConceptMapCard(
                        conceptMap: map,
                        isExpanded: expandedCard == map.id,
                        onTap: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                expandedCard = expandedCard == map.id ? nil : map.id
                            }
                        }
                    )
                }
            }
            
            StrategyTipCard(
                icon: "networkprobe",
                title: "Concept Map Tip",
                description: "Understand how concepts relate to each other. This visual representation helps build comprehensive understanding.",
                color: .quantumCyan
            )
        }
    }
    
    // MARK: - Feynman Explanation View
    private var feynmanView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Feynman Technique Explanations")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                ForEach(Array(learnViewModel.feynmanExplanations.enumerated()), id: \.element.id) { index, explanation in
                    FeynmanExplanationCard(
                        explanation: explanation,
                        isExpanded: expandedCard == explanation.id,
                        onTap: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                expandedCard = expandedCard == explanation.id ? nil : explanation.id
                            }
                        }
                    )
                    .offset(y: animateContent ? 0 : 20)
                    .opacity(animateContent ? 1 : 0)
                    .animation(
                        .easeOut(duration: 0.4).delay(Double(index) * 0.1),
                        value: animateContent
                    )
                }
            }
            
            StrategyTipCard(
                icon: "sparkles",
                title: "Feynman Tip",
                description: "Explain each concept in simple terms. If you can explain it simply, you truly understand it!",
                color: .quantumPurple
            )
        }
    }
}

// MARK: - Strategy Button
struct StrategyButton: View {
    let strategy: LearnViewModel.LearningStrategy
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: strategy.icon)
                    .font(.title3)
                
                Text(strategy.rawValue)
                    .font(.caption2.weight(.medium))
            }
            .frame(width: 90)
            .padding(.vertical, 12)
            .foregroundColor(isSelected ? .bgDark : .textSecondary)
            .background(
                isSelected ? Color.quantumCyan : Color.white.opacity(0.05)
            )
            .cornerRadius(12)
        }
    }
}

// MARK: - Memory Trigger Card
struct MemoryTriggerCard: View {
    let trigger: MemoryTrigger
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(trigger.title)
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        Text(trigger.mnemonic)
                            .font(.caption)
                            .foregroundColor(.quantumYellow)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.textTertiary)
                }
                .padding(16)
                .background(Color.bgCard)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .background(Color.textTertiary.opacity(0.3))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.textSecondary)
                        
                        Text(trigger.description)
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                            .lineSpacing(2)
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.quantumYellow)
                        
                        Text(trigger.difficulty)
                            .font(.caption2.weight(.medium))
                            .foregroundColor(.textTertiary)
                    }
                }
                .padding(16)
                .background(Color.bgCard)
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Concept Map Card
struct ConceptMapCard: View {
    let conceptMap: ConceptMap
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(conceptMap.title)
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        Text("Central: \(conceptMap.centralConcept)")
                            .font(.caption)
                            .foregroundColor(.quantumCyan)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.textTertiary)
                }
                .padding(16)
                .background(Color.bgCard)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .background(Color.textTertiary.opacity(0.3))
                    
                    Text(conceptMap.description)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .lineSpacing(2)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Related Concepts")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.textSecondary)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(conceptMap.relatedConcepts, id: \.self) { concept in
                                Text(concept)
                                    .font(.caption2)
                                    .foregroundColor(.quantumCyan)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.quantumCyan.opacity(0.1))
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
                .padding(16)
                .background(Color.bgCard)
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Feynman Explanation Card
struct FeynmanExplanationCard: View {
    let explanation: FeynmanExplanation
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(explanation.conceptName)
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        Text(explanation.simpleExplanation)
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.textTertiary)
                }
                .padding(16)
                .background(Color.bgCard)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .background(Color.textTertiary.opacity(0.3))
                    
                    // Simple Explanation
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Simple Explanation")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.textSecondary)
                        
                        Text(explanation.simpleExplanation)
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                    
                    // Details
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Details")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.textSecondary)
                        
                        Text(explanation.details)
                            .font(.caption2)
                            .foregroundColor(.textTertiary)
                            .lineSpacing(2)
                    }
                    
                    // Analogies
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Helpful Analogies")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.textSecondary)
                        
                        ForEach(explanation.analogies, id: \.self) { analogy in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "lightbulb.fill")
                                    .font(.caption2)
                                    .foregroundColor(.quantumYellow)
                                    .padding(.top, 2)
                                
                                Text(analogy)
                                    .font(.caption2)
                                    .foregroundColor(.textTertiary)
                            }
                        }
                    }
                    
                    // Common Misconceptions
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Common Misconceptions")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.textSecondary)
                        
                        ForEach(explanation.commonMisconceptions, id: \.self) { misconception in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption2)
                                    .foregroundColor(.quantumRed)
                                    .padding(.top, 2)
                                
                                Text(misconception)
                                    .font(.caption2)
                                    .foregroundColor(.textTertiary)
                            }
                        }
                    }
                }
                .padding(16)
                .background(Color.bgCard)
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Strategy Tip Card
struct StrategyTipCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .lineSpacing(2)
            }
        }
        .padding(12)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Flow Layout Helper
struct FlowLayout<Content: View>: View {
    let spacing: CGFloat
    let content: Content
    
    init(
        spacing: CGFloat = 8,
        @ViewBuilder content: () -> Content
    ) {
        self.spacing = spacing
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            content
        }
    }
}

// MARK: - Preview
#Preview("Memory Triggers") {
    NavigationStack {
        LearningStrategyView(level: LearningLevel.sampleLevels[0])
            .environmentObject(LearnViewModel.sample)
    }
}
