//
//  DeutschJozsaExample.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

// MARK: - Deutsch-Jozsa Algorithm Example
struct DeutschJozsaExample: View {
    @State private var functionType: FunctionType = .constant
    @State private var isRunning = false
    @State private var result: String = ""
    
    enum FunctionType: String, CaseIterable {
        case constant = "Constant"
        case balanced = "Balanced"
        
        var description: String {
            switch self {
            case .constant:
                return "Function returns the same value for all inputs"
            case .balanced:
                return "Function returns 0 for half of inputs, 1 for the other half"
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Algorithm explanation
                explanationCard
                
                // Function selector
                functionSelector
                
                // Run algorithm
                runButton
                
                // Result
                if !result.isEmpty {
                    resultCard
                }
            }
            .padding()
        }
        .navigationTitle("Deutsch-Jozsa")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var explanationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("About the Algorithm", systemImage: "function")
                .font(.headline)
                .foregroundColor(.quantumCyan)
            
            Text("""
            The Deutsch-Jozsa algorithm demonstrates quantum advantage by determining \
            whether a function is constant or balanced with just one query, while \
            classical algorithms need up to 2^(n-1) + 1 queries.
            """)
            .font(.subheadline)
            .foregroundColor(.textSecondary)
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
    
    private var functionSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Function Type")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            ForEach(FunctionType.allCases, id: \.self) { type in
                FunctionTypeCard(
                    type: type,
                    isSelected: functionType == type
                ) {
                    functionType = type
                    result = ""
                }
            }
        }
    }
    
    private var runButton: some View {
        Button(action: runAlgorithm) {
            HStack {
                if isRunning {
                    ProgressView()
                        .tint(.bgDark)
                } else {
                    Image(systemName: "play.fill")
                    Text("Run Quantum Algorithm")
                }
            }
            .font(.headline)
            .foregroundColor(.bgDark)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.quantumCyan)
            .cornerRadius(12)
        }
        .disabled(isRunning)
    }
    
    private var resultCard: some View {
        VStack(spacing: 16) {
            Image(systemName: result == "Constant" ? "equal.circle.fill" : "divide.circle.fill")
                .font(.largeTitle)
                .foregroundColor(result == "Constant" ? .quantumGreen : .quantumPurple)
            
            Text("Result: \(result) Function")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            Text("Algorithm completed with 1 quantum query")
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
    
    private func runAlgorithm() {
        isRunning = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                result = functionType.rawValue
                isRunning = false
            }
            QuantumTheme.Haptics.success()
        }
    }
}

// MARK: - Function Type Card
struct FunctionTypeCard: View {
    let type: DeutschJozsaExample.FunctionType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(type.rawValue)
                    .font(.headline)
                    .foregroundColor(isSelected ? .bgDark : .textPrimary)
                
                Text(type.description)
                    .font(.caption)
                    .foregroundColor(isSelected ? .bgDark.opacity(0.8) : .textSecondary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(isSelected ? Color.quantumCyan : Color.bgCard)
            .cornerRadius(8)
        }
    }
}