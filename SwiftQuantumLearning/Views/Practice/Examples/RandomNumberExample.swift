//
//  RandomNumberExample.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

struct RandomNumberExample: View {
    @State private var randomBits: String = ""
    @State private var decimalValue: Int = 0
    @State private var isGenerating = false
    @State private var bitCount = 8
    
    var body: some View {
        ZStack {
            Color.bgDark.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    explanationCard
                    settingsCard
                    generateButton
                    
                    if !randomBits.isEmpty {
                        resultsCard
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Quantum RNG")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    private var explanationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("True Randomness")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            Text("Quantum random number generation uses quantum superposition to create truly random bits. Each qubit is put in superposition and measured, collapsing to 0 or 1 with perfect randomness.")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .lineSpacing(4)
        }
        .padding(20)
        .background(Color.bgCard)
        .cornerRadius(16)
    }
    
    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Number of Bits")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            Picker("Bits", selection: $bitCount) {
                Text("4 bits").tag(4)
                Text("8 bits").tag(8)
                Text("16 bits").tag(16)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            HStack {
                Text("Max value:")
                    .foregroundColor(.textSecondary)
                Text("\(Int(pow(2.0, Double(bitCount))) - 1)")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.quantumCyan)
            }
            .font(.caption)
        }
        .padding(20)
        .background(Color.bgCard)
        .cornerRadius(16)
    }
    
    private var generateButton: some View {
        Button(action: generateRandomNumber) {
            HStack {
                if isGenerating {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .bgDark))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "dice.fill")
                }
                Text(isGenerating ? "Generating..." : "Generate Random Number")
            }
            .font(.headline)
            .foregroundColor(.bgDark)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.quantumCyan)
            .cornerRadius(12)
        }
        .disabled(isGenerating)
    }
    
    private var resultsCard: some View {
        VStack(spacing: 20) {
            // Binary display
            VStack(spacing: 8) {
                Text("Binary")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                Text(randomBits)
                    .font(.system(.title2, design: .monospaced))
                    .foregroundColor(.quantumPurple)
            }
            
            Divider()
                .background(Color.textTertiary.opacity(0.3))
            
            // Decimal display
            VStack(spacing: 8) {
                Text("Decimal")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                Text("\(decimalValue)")
                    .font(.system(.largeTitle, design: .rounded).bold())
                    .foregroundColor(.quantumCyan)
            }
            
            // Visualization
            HStack(spacing: 4) {
                ForEach(0..<randomBits.count, id: \.self) { index in
                    let bit = String(randomBits[randomBits.index(randomBits.startIndex, offsetBy: index)])
                    Circle()
                        .fill(bit == "1" ? Color.quantumCyan : Color.textTertiary.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding(20)
        .background(Color.bgCard)
        .cornerRadius(16)
    }
    
    private func generateRandomNumber() {
        isGenerating = true
        randomBits = ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.animateGeneration()
        }
    }
    
    private func animateGeneration() {
        var bits = ""
        
        for i in 0..<bitCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                let bit = Bool.random() ? "1" : "0"
                bits.append(bit)
                
                withAnimation {
                    self.randomBits = bits.padding(toLength: self.bitCount, withPad: " ", startingAt: 0)
                }
                
                if i == bitCount - 1 {
                    self.randomBits = bits
                    self.decimalValue = Int(bits, radix: 2) ?? 0
                    self.isGenerating = false
                }
            }
        }
    }
}
