//
//  InteractiveDemoView.swift
//  SwiftQuantum Learning App
//
//  Created by SwiftQuantum Team
//  Copyright © 2025 SwiftQuantum. All rights reserved.
//

import SwiftUI

// MARK: - Interactive Demo View
struct InteractiveDemoView: View {
    @State private var selectedDemo: Demo?
    
    let demos = [
        Demo(id: "bloch", title: "Bloch Sphere", icon: "globe"),
        Demo(id: "gates", title: "Gate Playground", icon: "square.grid.3x3"),
        Demo(id: "measurement", title: "Measurement", icon: "gauge"),
        Demo(id: "entanglement", title: "Entanglement", icon: "link")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(demos) { demo in
                        DemoCard(demo: demo) {
                            selectedDemo = demo
                        }
                    }
                }
                .padding()
            }
            .background(Color.bgDark)
            .navigationTitle("Interactive Demos")
            .sheet(item: $selectedDemo) { demo in
                DemoDetailView(demo: demo)
            }
        }
    }
}

struct Demo: Identifiable {
    let id: String
    let title: String
    let icon: String
}

struct DemoCard: View {
    let demo: Demo
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: demo.icon)
                    .font(.largeTitle)
                    .foregroundColor(.quantumCyan)
                
                Text(demo.title)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.bgCard)
            .cornerRadius(12)
        }
    }
}

struct DemoDetailView: View {
    let demo: Demo
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgDark.ignoresSafeArea()
                
                Text("Interactive \(demo.title) Demo")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
            }
            .navigationTitle(demo.title)
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
