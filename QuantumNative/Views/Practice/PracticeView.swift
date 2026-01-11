//
//  PracticeView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI
import Combine

// MARK: - Practice View
struct PracticeView: View {
    @EnvironmentObject var progressViewModel: ProgressViewModel
    @State private var selectedDifficulty: PracticeItem.Difficulty?
    @State private var animateItems = false
    
    // Sample data using the PracticeItem from Models folder
    private let practiceItems: [PracticeItem] = PracticeItem.sampleItems
    
    private var filteredItems: [PracticeItem] {
        if let difficulty = selectedDifficulty {
            return practiceItems.filter { $0.difficulty == difficulty }
        }
        return practiceItems
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgDark.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    filterChips
                    practiceGrid
                }
            }
            .navigationTitle("Practice")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                animateItems = true
            }
        }
    }
    
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    title: "All",
                    isSelected: selectedDifficulty == nil,
                    color: .quantumCyan
                ) {
                    withAnimation(.easeOut(duration: 0.2)) {
                        selectedDifficulty = nil
                    }
                }
                
                ForEach(PracticeItem.Difficulty.allCases, id: \.self) { difficulty in
                    FilterChip(
                        title: difficulty.rawValue,
                        isSelected: selectedDifficulty == difficulty,
                        color: difficulty.color
                    ) {
                        withAnimation(.easeOut(duration: 0.2)) {
                            selectedDifficulty = difficulty
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    private var practiceGrid: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ],
                spacing: 16
            ) {
                ForEach(Array(filteredItems.enumerated()), id: \.element.id) { index, item in
                    PracticeCardView(item: item)
                        .offset(y: animateItems ? 0 : 30)
                        .opacity(animateItems ? 1 : 0)
                        .animation(
                            .easeOut(duration: 0.4).delay(Double(index) * 0.1),
                            value: animateItems
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
}

// MARK: - Practice Card View
struct PracticeCardView: View {
    let item: PracticeItem
    
    var body: some View {
        NavigationLink(destination: practiceDestination) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: item.iconName)
                        .font(.title)
                        .foregroundColor(item.isUnlocked ? item.difficulty.color : .textTertiary)
                    
                    Spacer()
                    
                    Text(item.difficulty.rawValue)
                        .font(.caption2.weight(.medium))
                        .foregroundColor(item.difficulty.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(item.difficulty.color.opacity(0.1))
                        .cornerRadius(6)
                }
                
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(item.isUnlocked ? .textPrimary : .textTertiary)
                    .lineLimit(1)
                
                Text(item.subtitle)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
                    .frame(height: 32, alignment: .top)
                
                if item.isUnlocked {
                    progressIndicator
                } else {
                    lockIndicator
                }
            }
            .padding(16)
            .background(Color.bgCard)
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
        .disabled(!item.isUnlocked)
    }
    
    private var progressIndicator: some View {
        VStack(spacing: 6) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(item.difficulty.color)
                        .frame(
                            width: geometry.size.width * CGFloat(item.progressPercentage) / 100,
                            height: 6
                        )
                }
            }
            .frame(height: 6)
            
            HStack {
                Text("\(item.completedCount)/\(item.totalCount)")
                    .font(.caption2)
                    .foregroundColor(.textTertiary)
                
                Spacer()
                
                if item.completedCount == item.totalCount {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.completed)
                }
            }
        }
    }
    
    private var lockIndicator: some View {
        HStack {
            Image(systemName: "lock.fill")
                .font(.caption)
            Text("Complete previous levels")
                .font(.caption2)
        }
        .foregroundColor(.textTertiary)
    }
    
    @ViewBuilder
    private var practiceDestination: some View {
        switch item.id {
        case "superposition":
            SuperpositionLabView()
        case "gates":
            QuantumGatesExample()
        default:
            Text("Practice: \(item.title)")
                .navigationTitle(item.title)
        }
    }
}

// MARK: - Superposition Lab View
struct SuperpositionLabView: View {
    @Environment(\.dismiss) var dismiss
    @State private var alpha: Double = 1.0
    @State private var beta: Double = 0.0
    @State private var measurementResults: [Int] = []
    @State private var isMeasuring = false
    
    var body: some View {
        ZStack {
            Color.bgDark.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    stateVisualization
                    controlsSection
                    measurementSection
                    
                    if !measurementResults.isEmpty {
                        resultsHistogram
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Superposition Lab")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    private var stateVisualization: some View {
        VStack(spacing: 16) {
            Text("Current State")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            HStack(spacing: 8) {
                Text("|ψ⟩ = ")
                    .font(.system(.title2, design: .serif))
                
                Text(String(format: "%.2f", alpha))
                    .font(.system(.title2, design: .monospaced))
                    .foregroundColor(.quantumCyan)
                
                Text("|0⟩ + ")
                    .font(.system(.title2, design: .serif))
                
                Text(String(format: "%.2f", beta))
                    .font(.system(.title2, design: .monospaced))
                    .foregroundColor(.quantumPurple)
                
                Text("|1⟩")
                    .font(.system(.title2, design: .serif))
            }
            .foregroundColor(.textPrimary)
        }
        .padding(20)
        .background(Color.bgCard)
        .cornerRadius(16)
    }
    
    private var controlsSection: some View {
        VStack(spacing: 16) {
            Text("Adjust State")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 8) {
                HStack {
                    Text("|0⟩")
                        .foregroundColor(.quantumCyan)
                    Spacer()
                    Text("|1⟩")
                        .foregroundColor(.quantumPurple)
                }
                .font(.caption)
                
                Slider(value: sliderBinding, in: 0...1)
                    .tint(.quantumCyan)
            }
        }
        .padding(20)
        .background(Color.bgCard)
        .cornerRadius(16)
    }
    
    private var sliderBinding: Binding<Double> {
        Binding(
            get: { beta * beta },
            set: { newValue in
                beta = sqrt(newValue)
                alpha = sqrt(1 - newValue)
            }
        )
    }
    
    private var measurementSection: some View {
        VStack(spacing: 16) {
            Text("Measure")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            HStack(spacing: 16) {
                Button(action: measureOnce) {
                    Label("Measure Once", systemImage: "scope")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.quantumCyan)
                        .foregroundColor(.bgDark)
                        .cornerRadius(12)
                }
                
                Button(action: measureMany) {
                    Label("×100", systemImage: "arrow.clockwise")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.bgCard)
                        .foregroundColor(.quantumCyan)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.quantumCyan, lineWidth: 1)
                        )
                }
                .disabled(isMeasuring)
            }
        }
        .padding(20)
        .background(Color.bgCard)
        .cornerRadius(16)
    }
    
    private var resultsHistogram: some View {
        let zeros = measurementResults.filter { $0 == 0 }.count
        let ones = measurementResults.count - zeros
        
        return VStack(spacing: 16) {
            HStack {
                Text("Results")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text("\(measurementResults.count) measurements")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            HStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("\(zeros)")
                        .font(.title.bold())
                        .foregroundColor(.quantumCyan)
                    Text("|0⟩")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    Text("\(Int(Double(zeros) / Double(measurementResults.count) * 100))%")
                        .font(.caption2)
                        .foregroundColor(.textTertiary)
                }
                .frame(maxWidth: .infinity)
                
                VStack(spacing: 8) {
                    Text("\(ones)")
                        .font(.title.bold())
                        .foregroundColor(.quantumPurple)
                    Text("|1⟩")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    Text("\(Int(Double(ones) / Double(measurementResults.count) * 100))%")
                        .font(.caption2)
                        .foregroundColor(.textTertiary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(20)
        .background(Color.bgCard)
        .cornerRadius(16)
    }
    
    private func measureOnce() {
        let probability = alpha * alpha
        let result = Double.random(in: 0...1) < probability ? 0 : 1
        measurementResults.append(result)
    }
    
    private func measureMany() {
        isMeasuring = true
        let probability = alpha * alpha
        
        for i in 0..<100 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.01) {
                let result = Double.random(in: 0...1) < probability ? 0 : 1
                measurementResults.append(result)
                
                if i == 99 {
                    isMeasuring = false
                }
            }
        }
    }
}
