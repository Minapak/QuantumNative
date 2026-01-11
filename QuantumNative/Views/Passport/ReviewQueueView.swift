//
//  ReviewQueueView.swift
//  QuantumNative
//
//  Peer Review Queue for Level 10+ Pro Users
//  Created by QuantumNative Team
//  Copyright 2026 QuantumNative. All rights reserved.
//

import SwiftUI

struct ReviewQueueView: View {
    @StateObject private var passportService = CareerPassportService.shared
    @State private var selectedCircuit: PublishedCircuit?
    @State private var showingReviewSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                if passportService.reviewQueue.isEmpty {
                    emptyQueueView
                } else {
                    reviewList
                }
            }
            .navigationTitle("Review Queue")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await passportService.fetchReviewQueue()
            }
            .sheet(isPresented: $showingReviewSheet) {
                if let circuit = selectedCircuit {
                    ReviewSubmissionView(circuit: circuit)
                }
            }
        }
    }

    private var emptyQueueView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.seal")
                .font(.system(size: 60))
                .foregroundColor(.green.opacity(0.5))

            Text("No Circuits to Review")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("Check back later for new circuits awaiting peer review")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private var reviewList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(passportService.reviewQueue) { circuit in
                    ReviewQueueCard(circuit: circuit) {
                        selectedCircuit = circuit
                        showingReviewSheet = true
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Review Queue Card

struct ReviewQueueCard: View {
    let circuit: PublishedCircuit
    let onReview: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(circuit.title)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(circuit.doi)
                        .font(.caption)
                        .foregroundColor(.cyan)
                }

                Spacer()

                Button(action: onReview) {
                    Text("Review")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.yellow)
                        .cornerRadius(8)
                }
            }

            if let description = circuit.description {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }

            HStack(spacing: 16) {
                Label("\(circuit.qubitCount) qubits", systemImage: "circle.grid.2x2")
                Label("\(circuit.gatesCount) gates", systemImage: "cpu")
                Label("Depth \(circuit.depth)", systemImage: "arrow.right")
            }
            .font(.caption)
            .foregroundColor(.white.opacity(0.6))
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

// MARK: - Review Submission View

struct ReviewSubmissionView: View {
    let circuit: PublishedCircuit
    @Environment(\.dismiss) private var dismiss
    @StateObject private var passportService = CareerPassportService.shared

    @State private var passFail = true
    @State private var efficiencyScore = 3
    @State private var feedback = ""
    @State private var isSubmitting = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Circuit Info
                        VStack(alignment: .leading, spacing: 8) {
                            Text(circuit.title)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text(circuit.doi)
                                .font(.subheadline)
                                .foregroundColor(.cyan)

                            if let description = circuit.description {
                                Text(description)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)

                        // Pass/Fail
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Verification Result")
                                .font(.headline)
                                .foregroundColor(.white)

                            HStack(spacing: 12) {
                                Button {
                                    passFail = true
                                } label: {
                                    HStack {
                                        Image(systemName: passFail ? "checkmark.circle.fill" : "circle")
                                        Text("Pass")
                                    }
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(passFail ? .black : .white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(passFail ? Color.green : Color.white.opacity(0.1))
                                    .cornerRadius(10)
                                }

                                Button {
                                    passFail = false
                                } label: {
                                    HStack {
                                        Image(systemName: !passFail ? "xmark.circle.fill" : "circle")
                                        Text("Fail")
                                    }
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(!passFail ? .white : .white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(!passFail ? Color.red : Color.white.opacity(0.1))
                                    .cornerRadius(10)
                                }
                            }
                        }

                        // Efficiency Score
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Efficiency Score")
                                    .font(.headline)
                                    .foregroundColor(.white)

                                Spacer()

                                Text("\(efficiencyScore)/5")
                                    .font(.subheadline)
                                    .foregroundColor(.cyan)
                            }

                            HStack(spacing: 8) {
                                ForEach(1...5, id: \.self) { score in
                                    Button {
                                        efficiencyScore = score
                                    } label: {
                                        Image(systemName: score <= efficiencyScore ? "star.fill" : "star")
                                            .font(.title2)
                                            .foregroundColor(score <= efficiencyScore ? .yellow : .gray)
                                    }
                                }
                            }
                        }

                        // Feedback
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Feedback (Optional)")
                                .font(.headline)
                                .foregroundColor(.white)

                            TextEditor(text: $feedback)
                                .frame(minHeight: 100)
                                .padding(8)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                                .scrollContentBackground(.hidden)
                        }

                        // Submit Button
                        Button {
                            submitReview()
                        } label: {
                            HStack {
                                if isSubmitting {
                                    ProgressView()
                                        .tint(.black)
                                } else {
                                    Image(systemName: "paperplane.fill")
                                    Text("Submit Review")
                                }
                            }
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.yellow, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(14)
                        }
                        .disabled(isSubmitting)

                        // Reviewer Guidelines
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reviewer Guidelines")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.7))

                            Text("""
                            - Verify the circuit produces correct quantum states
                            - Check for optimal gate usage and circuit depth
                            - Ensure the circuit can run on real quantum hardware
                            - Be constructive in your feedback
                            """)
                            .font(.caption2)
                            .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white.opacity(0.03))
                        .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .navigationTitle("Submit Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.gray)
                }
            }
        }
    }

    private func submitReview() {
        isSubmitting = true

        Task {
            do {
                _ = try await passportService.submitReview(
                    circuitId: circuit.id,
                    passFail: passFail,
                    efficiencyScore: efficiencyScore,
                    feedback: feedback
                )

                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("Failed to submit review: \(error)")
                await MainActor.run {
                    isSubmitting = false
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ReviewQueueView()
}
