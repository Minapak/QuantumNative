//
//  RandomNumberExample.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

// MARK: - Quantum Random Number Example
struct RandomNumberExample: View {
    @State private var randomNumbers: [Int] = []
    @State private var isGenerating = false
    @State private var numberOfBits = 8
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Explanation
                explanationCard
                
                // Configuration
                configurationSection
                
                // Generate button
                generateButton
                
                // Results
                if !randomNumbers.isEmpty {
                    resultsSection
                }
            }
            .padding()
        }
        .navigationTitle("Quantum RNG")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var explanationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("How It Works", systemImage: "info.circle")
                .font(.headline)
                .foregroundColor(.quantumCyan)
            
            Text("""
            Quantum random number generation uses the inherent randomness of quantum mechanics. \
            By preparing qubits in superposition and measuring them, we get truly random bits.
            """)
            .font(.subheadline)
            .foregroundColor(.textSecondary)
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
    
    private var configurationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Number of Bits")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            HStack {
                Text("\(numberOfBits)")
                    .font(.title2.bold())
                    .foregroundColor(.quantumCyan)
                    .frame(width: 50)
                
                Slider(value: Binding(
                    get: { Double(numberOfBits) },
                    set: { numberOfBits = Int($0) }
                ), in: 1...16, step: 1)
                .tint(.quantumCyan)
            }
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
    
    private var generateButton: some View {
        Button(action: generateRandomNumber) {
            HStack {
                if isGenerating {
                    ProgressView()
                        .tint(.bgDark)
                } else {
                    Image(systemName: "dice")
                    Text("Generate Quantum Random Number")
                }
            }
            .font(.headline)
            .foregroundColor(.bgDark)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.quantumCyan)
            .cornerRadius(12)
        }
        .disabled(isGenerating)
    }
    
    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Generated Numbers")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            ForEach(Array(randomNumbers.suffix(5).enumerated()), id: \.offset) { _, number in
                RandomNumberCard(
                    decimal: number,
                    binary: String(number, radix: 2).padLeft(toLength: numberOfBits),
                    hex: String(format: "0x%02X", number)
                )
            }
        }
    }
    
    private func generateRandomNumber() {
        isGenerating = true
        
        // Simulate quantum random generation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let maxValue = Int(pow(2.0, Double(numberOfBits))) - 1
            let randomValue = Int.random(in: 0...maxValue)
            
            withAnimation {
                randomNumbers.append(randomValue)
                isGenerating = false
            }
            
            QuantumTheme.Haptics.success()
        }
    }
}

// MARK: - Random Number Card
struct RandomNumberCard: View {
    let decimal: Int
    let binary: String
    let hex: String
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Decimal")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
                Text("\(decimal)")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Binary")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
                Text(binary)
                    .font(.caption.monospaced())
                    .foregroundColor(.quantumCyan)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Hex")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
                Text(hex)
                    .font(.caption.monospaced())
                    .foregroundColor(.quantumPurple)
            }
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(8)
    }
}

// String extension for padding
extension String {
    func padLeft(toLength length: Int, withPad pad: String = "0") -> String {
        let currentLength = self.count
        if currentLength >= length {
            return self
        }
        return String(repeating: pad, count: length - currentLength) + self
    }
}