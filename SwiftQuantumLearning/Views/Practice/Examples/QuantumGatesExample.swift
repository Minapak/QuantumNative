//
//  QuantumGatesExample.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

// MARK: - Quantum Gates Example
struct QuantumGatesExample: View {
    @State private var selectedGate = "H"
    @State private var qubitState = QubitState()
    @State private var gateHistory: [String] = []
    
    let availableGates = [
        ("H", "Hadamard"),
        ("X", "Pauli-X"),
        ("Y", "Pauli-Y"),
        ("Z", "Pauli-Z"),
        ("S", "Phase"),
        ("T", "T Gate")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // State display
                stateDisplay
                
                // Gate selector
                gateSelector
                
                // Apply button
                applyButton
                
                // History
                if !gateHistory.isEmpty {
                    historyView
                }
                
                // Reset button
                resetButton
            }
            .padding()
        }
        .navigationTitle("Quantum Gates")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var stateDisplay: some View {
        VStack(spacing: 16) {
            Text("Current State")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            HStack(spacing: 16) {
                Text("|ψ⟩ =")
                    .font(.title2)
                
                Text(String(format: "%.2f|0⟩ + %.2f|1⟩", 
                           qubitState.alpha.real, 
                           qubitState.beta.real))
                    .font(.title3.monospaced())
                    .foregroundColor(.quantumCyan)
            }
            
            // Probabilities
            HStack(spacing: 32) {
                VStack {
                    Text("|0⟩")
                        .font(.headline)
                    Text("\(Int(qubitState.prob0 * 100))%")
                        .font(.title2.bold())
                        .foregroundColor(.quantumCyan)
                }
                
                VStack {
                    Text("|1⟩")
                        .font(.headline)
                    Text("\(Int(qubitState.prob1 * 100))%")
                        .font(.title2.bold())
                        .foregroundColor(.quantumPurple)
                }
            }
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
    
    private var gateSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Gate")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                ForEach(availableGates, id: \.0) { gate in
                    GateButton(
                        symbol: gate.0,
                        name: gate.1,
                        isSelected: selectedGate == gate.0
                    ) {
                        selectedGate = gate.0
                    }
                }
            }
        }
    }
    
    private var applyButton: some View {
        Button(action: applyGate) {
            Label("Apply Gate", systemImage: "play.fill")
                .font(.headline)
                .foregroundColor(.bgDark)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.quantumCyan)
                .cornerRadius(12)
        }
    }
    
    private var historyView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Gate History")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            HStack {
                ForEach(gateHistory.suffix(10), id: \.self) { gate in
                    Text(gate)
                        .font(.caption.monospaced())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.quantumCyan.opacity(0.2))
                        .cornerRadius(4)
                }
            }
        }
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
    
    private var resetButton: some View {
        Button(action: reset) {
            Text("Reset to |0⟩")
                .foregroundColor(.textSecondary)
        }
    }
    
    private func applyGate() {
        withAnimation(.easeOut(duration: 0.3)) {
            switch selectedGate {
            case "H": qubitState.applyHadamard()
            case "X": qubitState.applyPauliX()
            case "Y": qubitState.applyPauliY()
            case "Z": qubitState.applyPauliZ()
            case "S": qubitState.applyPhaseS()
            case "T": qubitState.applyTGate()
            default: break
            }
            
            gateHistory.append(selectedGate)
            QuantumTheme.Haptics.light()
        }
    }
    
    private func reset() {
        withAnimation {
            qubitState.reset()
            gateHistory.removeAll()
        }
    }
}

// MARK: - Gate Button
struct GateButton: View {
    let symbol: String
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(symbol)
                    .font(.title2.bold().monospaced())
                    .foregroundColor(isSelected ? .bgDark : .quantumCyan)
                
                Text(name)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .bgDark : .textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.quantumCyan : Color.bgCard)
            .cornerRadius(8)
        }
    }
}