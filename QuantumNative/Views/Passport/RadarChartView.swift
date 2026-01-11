//
//  RadarChartView.swift
//  QuantumNative
//
//  5-axis Radar Chart for O1 Evidence visualization
//  Created by QuantumNative Team
//  Copyright 2026 QuantumNative. All rights reserved.
//

import SwiftUI

struct RadarChartView: View {
    let scores: [Double]  // 5 scores (0-100)
    let labels: [String]
    let globalAverage: [Double]?

    private let numberOfAxes = 5
    private let maxValue: Double = 100

    // Miami Sunset gradient
    private let userGradient = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.4, blue: 0.6),   // Pink
            Color(red: 1.0, green: 0.6, blue: 0.2),   // Orange
            Color(red: 0.0, green: 0.8, blue: 1.0)    // Cyan
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    init(scores: [Double], labels: [String] = O1Evidence.radarLabels, globalAverage: [Double]? = nil) {
        self.scores = scores
        self.labels = labels
        self.globalAverage = globalAverage
    }

    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2 - 40

            ZStack {
                // Background grid
                gridLayers(center: center, radius: radius)

                // Axis lines
                axisLines(center: center, radius: radius)

                // Global average polygon (if available)
                if let average = globalAverage {
                    radarPolygon(
                        scores: average,
                        center: center,
                        radius: radius,
                        fillColor: Color.gray.opacity(0.2),
                        strokeColor: Color.gray.opacity(0.5)
                    )
                }

                // User scores polygon
                radarPolygon(
                    scores: scores,
                    center: center,
                    radius: radius,
                    fill: userGradient,
                    strokeColor: Color.cyan
                )

                // Data points
                dataPoints(center: center, radius: radius)

                // Labels
                axisLabels(center: center, radius: radius)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    // MARK: - Grid Layers

    private func gridLayers(center: CGPoint, radius: CGFloat) -> some View {
        ForEach(1...5, id: \.self) { level in
            let levelRadius = radius * CGFloat(level) / 5

            Path { path in
                for i in 0..<numberOfAxes {
                    let angle = angleForAxis(i)
                    let point = pointOnCircle(center: center, radius: levelRadius, angle: angle)

                    if i == 0 {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                }
                path.closeSubpath()
            }
            .stroke(Color.white.opacity(0.1), lineWidth: 1)
        }
    }

    // MARK: - Axis Lines

    private func axisLines(center: CGPoint, radius: CGFloat) -> some View {
        ForEach(0..<numberOfAxes, id: \.self) { i in
            let angle = angleForAxis(i)
            let endPoint = pointOnCircle(center: center, radius: radius, angle: angle)

            Path { path in
                path.move(to: center)
                path.addLine(to: endPoint)
            }
            .stroke(Color.white.opacity(0.2), lineWidth: 1)
        }
    }

    // MARK: - Radar Polygon (with gradient)

    private func radarPolygon(
        scores: [Double],
        center: CGPoint,
        radius: CGFloat,
        fill: LinearGradient,
        strokeColor: Color
    ) -> some View {
        let path = radarPath(scores: scores, center: center, radius: radius)

        return ZStack {
            path.fill(fill.opacity(0.3))
            path.stroke(strokeColor, lineWidth: 2)
        }
    }

    // MARK: - Radar Polygon (with solid color)

    private func radarPolygon(
        scores: [Double],
        center: CGPoint,
        radius: CGFloat,
        fillColor: Color,
        strokeColor: Color
    ) -> some View {
        let path = radarPath(scores: scores, center: center, radius: radius)

        return ZStack {
            path.fill(fillColor)
            path.stroke(strokeColor, lineWidth: 1)
        }
    }

    private func radarPath(scores: [Double], center: CGPoint, radius: CGFloat) -> Path {
        Path { path in
            for i in 0..<numberOfAxes {
                let normalizedScore = min(scores[i], maxValue) / maxValue
                let distance = radius * CGFloat(normalizedScore)
                let angle = angleForAxis(i)
                let point = pointOnCircle(center: center, radius: distance, angle: angle)

                if i == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
            path.closeSubpath()
        }
    }

    // MARK: - Data Points

    private func dataPoints(center: CGPoint, radius: CGFloat) -> some View {
        ForEach(0..<numberOfAxes, id: \.self) { i in
            let normalizedScore = min(scores[i], maxValue) / maxValue
            let distance = radius * CGFloat(normalizedScore)
            let angle = angleForAxis(i)
            let point = pointOnCircle(center: center, radius: distance, angle: angle)

            Circle()
                .fill(Color.cyan)
                .frame(width: 8, height: 8)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
                .position(point)
                .shadow(color: .cyan.opacity(0.5), radius: 4)
        }
    }

    // MARK: - Axis Labels

    private func axisLabels(center: CGPoint, radius: CGFloat) -> some View {
        ForEach(0..<numberOfAxes, id: \.self) { i in
            let angle = angleForAxis(i)
            let labelRadius = radius + 25
            let point = pointOnCircle(center: center, radius: labelRadius, angle: angle)

            VStack(spacing: 2) {
                Text(labels[i])
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))

                Text("\(Int(scores[i]))")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.cyan)
            }
            .position(point)
        }
    }

    // MARK: - Helper Functions

    private func angleForAxis(_ index: Int) -> Double {
        let startAngle = -Double.pi / 2  // Start from top
        return startAngle + (2 * Double.pi / Double(numberOfAxes)) * Double(index)
    }

    private func pointOnCircle(center: CGPoint, radius: CGFloat, angle: Double) -> CGPoint {
        CGPoint(
            x: center.x + radius * CGFloat(cos(angle)),
            y: center.y + radius * CGFloat(sin(angle))
        )
    }
}

// MARK: - Mini Radar Chart (for cards)

struct MiniRadarChartView: View {
    let scores: [Double]

    var body: some View {
        RadarChartView(scores: scores, labels: ["", "", "", "", ""])
            .frame(width: 80, height: 80)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack(spacing: 30) {
            Text("O1 Evidence Radar")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            RadarChartView(
                scores: [85, 72, 90, 65, 78],
                globalAverage: [50, 50, 50, 50, 50]
            )
            .frame(width: 300, height: 300)

            HStack(spacing: 20) {
                LegendItem(color: .cyan, label: "Your Score")
                LegendItem(color: .gray, label: "Global Average")
            }
        }
        .padding()
    }
}

struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
    }
}
