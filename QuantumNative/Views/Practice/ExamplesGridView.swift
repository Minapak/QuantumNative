//
//  ExamplesGridView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

// MARK: - Examples Grid View
struct ExamplesGridView: View {
    let examples = [
        ExampleItem(title: "Basic Operations", icon: "plus.forwardslash.minus", destination: AnyView(BasicOperationsExample())),
        ExampleItem(title: "Quantum Gates", icon: "square.grid.3x3", destination: AnyView(QuantumGatesExample())),
        ExampleItem(title: "Random Numbers", icon: "dice", destination: AnyView(RandomNumberExample())),
        ExampleItem(title: "Deutsch-Jozsa", icon: "function", destination: AnyView(DeutschJozsaExample())),
        ExampleItem(title: "Applications", icon: "sparkles", destination: AnyView(ApplicationsExample()))
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(examples) { example in
                        NavigationLink(destination: example.destination) {
                            ExampleCard(example: example)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .background(Color.bgDark)
            .navigationTitle("Code Examples")
        }
    }
}

struct ExampleItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let destination: AnyView
}

struct ExampleCard: View {
    let example: ExampleItem
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: example.icon)
                .font(.largeTitle)
                .foregroundColor(.quantumCyan)
            
            Text(example.title)
                .font(.headline)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
    }
}

// Basic Operations Example (placeholder)
struct BasicOperationsExample: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Basic Quantum Operations")
                    .font(.title2.bold())
                    .foregroundColor(.textPrimary)
                
                Text("Learn the fundamental operations in quantum computing")
                    .foregroundColor(.textSecondary)
            }
            .padding()
        }
        .background(Color.bgDark)
        .navigationTitle("Basic Operations")
#if os(iOS)
       .navigationBarTitleDisplayMode(.inline)
       #endif
    }
}
