//
//  ApplicationsExample.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

// MARK: - Quantum Applications Example
struct ApplicationsExample: View {
    @State private var selectedApplication: Application?
    
    let applications = [
        Application(
            id: "cryptography",
            title: "Quantum Cryptography",
            icon: "lock.shield.fill",
            description: "Secure communication using quantum key distribution",
            details: "Quantum cryptography uses quantum mechanics principles to create unbreakable encryption.",
            examples: ["BB84 Protocol", "Quantum Key Distribution", "Post-Quantum Cryptography"]
        ),
        Application(
            id: "optimization",
            title: "Optimization",
            icon: "chart.line.uptrend.xyaxis",
            description: "Solving complex optimization problems",
            details: "Quantum computers can find optimal solutions to complex problems exponentially faster.",
            examples: ["Portfolio Optimization", "Traffic Flow", "Supply Chain"]
        ),
        Application(
            id: "simulation",
            title: "Quantum Simulation",
            icon: "atom",
            description: "Simulating quantum systems and molecules",
            details: "Simulate molecular behavior for drug discovery and material science.",
            examples: ["Drug Discovery", "Material Science", "Chemical Reactions"]
        ),
        Application(
            id: "ml",
            title: "Machine Learning",
            icon: "brain",
            description: "Quantum-enhanced machine learning",
            details: "Quantum algorithms can accelerate machine learning tasks and pattern recognition.",
            examples: ["Quantum Neural Networks", "Feature Mapping", "Classification"]
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                headerCard
                
                // Applications grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(applications) { app in
                        ApplicationCard(application: app) {
                            selectedApplication = app
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Applications")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(item: $selectedApplication) { app in
            ApplicationDetailView(application: app)
        }
    }
    
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Real-World Applications")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            Text("Explore how quantum computing is revolutionizing various fields")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.bgCard)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Application Model
struct Application: Identifiable {
    let id: String
    let title: String
    let icon: String
    let description: String
    let details: String
    let examples: [String]
}

// MARK: - Application Card
struct ApplicationCard: View {
    let application: Application
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: application.icon)
                    .font(.largeTitle)
                    .foregroundColor(.quantumCyan)
                
                Text(application.title)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(application.description)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.bgCard)
            .cornerRadius(12)
        }
    }
}

// MARK: - Application Detail View
struct ApplicationDetailView: View {
    let application: Application
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Icon and title
                        VStack(spacing: 16) {
                            Image(systemName: application.icon)
                                .font(.system(size: 64))
                                .foregroundColor(.quantumCyan)
                            
                            Text(application.title)
                                .font(.title2.bold())
                                .foregroundColor(.textPrimary)
                        }
                        .padding()
                        
                        // Details
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Overview")
                                .font(.headline)
                                .foregroundColor(.textPrimary)
                            
                            Text(application.details)
                                .font(.body)
                                .foregroundColor(.textSecondary)
                                .lineSpacing(4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.bgCard)
                        .cornerRadius(12)
                        
                        // Examples
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Examples")
                                .font(.headline)
                                .foregroundColor(.textPrimary)
                            
                            ForEach(application.examples, id: \.self) { example in
                                HStack {
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.quantumCyan)
                                    
                                    Text(example)
                                        .font(.subheadline)
                                        .foregroundColor(.textSecondary)
                                    
                                    Spacer()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.bgCard)
                        .cornerRadius(12)
                    }
                    .padding()
                }
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.quantumCyan)
                }
                #else
                ToolbarItem(placement: .automatic) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.quantumCyan)
                }
                #endif
            }
        }
    }
}
