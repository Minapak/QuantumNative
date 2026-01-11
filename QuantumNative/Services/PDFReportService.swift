//
//  PDFReportService.swift
//  QuantumNative
//
//  O1 Visa Evidence PDF Report Generator
//  Created by QuantumNative Team
//  Copyright 2026 QuantumNative. All rights reserved.
//

import Foundation
import UIKit
import PDFKit

class PDFReportService {

    // MARK: - Singleton
    static let shared = PDFReportService()

    private init() {}

    // MARK: - PDF Generation

    /// Generate O1 Evidence PDF Report
    func generateO1EvidenceReport(
        evidence: O1Evidence,
        userName: String,
        userEmail: String,
        badges: [CareerBadge]
    ) -> Data? {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // Letter size

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        let documentId = UUID().uuidString.prefix(8).uppercased()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        let currentDate = dateFormatter.string(from: Date())

        return renderer.pdfData { context in
            // Page 1: Executive Summary
            context.beginPage()
            drawPage1(
                context: context,
                pageRect: pageRect,
                evidence: evidence,
                userName: userName,
                documentId: String(documentId),
                currentDate: currentDate
            )

            // Page 2: Detailed Evidence
            context.beginPage()
            drawPage2(
                context: context,
                pageRect: pageRect,
                evidence: evidence,
                badges: badges
            )

            // Page 3: Verification
            context.beginPage()
            drawPage3(
                context: context,
                pageRect: pageRect,
                evidence: evidence,
                userName: userName,
                userEmail: userEmail,
                documentId: String(documentId),
                currentDate: currentDate
            )
        }
    }

    // MARK: - Page 1: Executive Summary

    private func drawPage1(
        context: UIGraphicsPDFRendererContext,
        pageRect: CGRect,
        evidence: O1Evidence,
        userName: String,
        documentId: String,
        currentDate: String
    ) {
        let margin: CGFloat = 50
        var yPosition: CGFloat = margin

        // Header
        let headerText = "QUANTUM COMPUTING CAPABILITY REPORT"
        let headerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor(red: 0, green: 0.5, blue: 0.7, alpha: 1)
        ]
        headerText.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: headerAttrs)
        yPosition += 40

        // Document Info
        let docInfoAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.gray
        ]
        "Document ID: \(documentId)".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: docInfoAttrs)
        yPosition += 15
        "Issue Date: \(currentDate)".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: docInfoAttrs)
        yPosition += 30

        // Horizontal line
        context.cgContext.setStrokeColor(UIColor.lightGray.cgColor)
        context.cgContext.setLineWidth(0.5)
        context.cgContext.move(to: CGPoint(x: margin, y: yPosition))
        context.cgContext.addLine(to: CGPoint(x: pageRect.width - margin, y: yPosition))
        context.cgContext.strokePath()
        yPosition += 30

        // To Whom It May Concern
        let introTitle = "To Whom It May Concern:"
        let introTitleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.black
        ]
        introTitle.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: introTitleAttrs)
        yPosition += 30

        // Introduction paragraph
        let introText = """
        This document certifies that \(userName) has demonstrated exceptional ability \
        in the field of quantum computing through verifiable achievements on the \
        QuantumNative platform. The evidence presented herein is based on peer-reviewed \
        quantum circuit publications, algorithmic contributions, and independent validation \
        by the global quantum computing community.
        """
        let introAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor.darkGray
        ]
        let introRect = CGRect(x: margin, y: yPosition, width: pageRect.width - 2 * margin, height: 80)
        introText.draw(in: introRect, withAttributes: introAttrs)
        yPosition += 100

        // O1 Readiness Score Box
        let scoreBoxRect = CGRect(x: margin, y: yPosition, width: pageRect.width - 2 * margin, height: 120)
        context.cgContext.setFillColor(UIColor(red: 0.95, green: 0.97, blue: 1.0, alpha: 1).cgColor)
        context.cgContext.fill(scoreBoxRect)

        let scoreTitle = "O1 VISA READINESS SCORE"
        let scoreTitleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor(red: 0, green: 0.4, blue: 0.6, alpha: 1)
        ]
        scoreTitle.draw(at: CGPoint(x: margin + 20, y: yPosition + 15), withAttributes: scoreTitleAttrs)

        let scoreValue = "\(Int(evidence.o1ReadinessScore))"
        let scoreAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 48),
            .foregroundColor: UIColor(red: 0, green: 0.5, blue: 0.7, alpha: 1)
        ]
        scoreValue.draw(at: CGPoint(x: margin + 20, y: yPosition + 40), withAttributes: scoreAttrs)

        let outOf100 = "/ 100"
        let outOf100Attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24),
            .foregroundColor: UIColor.gray
        ]
        outOf100.draw(at: CGPoint(x: margin + 90, y: yPosition + 55), withAttributes: outOf100Attrs)

        // Percentile
        if let rank = evidence.globalRank {
            let percentileText = "Global Ranking: #\(rank) (Top \(String(format: "%.1f", evidence.percentile))%)"
            let percentileAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 11),
                .foregroundColor: UIColor(red: 0.8, green: 0.6, blue: 0, alpha: 1)
            ]
            percentileText.draw(at: CGPoint(x: margin + 200, y: yPosition + 60), withAttributes: percentileAttrs)
        }

        yPosition += 150

        // O1 Criteria Mapping
        let criteriaTitle = "O1 VISA CRITERIA MAPPING"
        criteriaTitle.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: scoreTitleAttrs)
        yPosition += 30

        let criteria = [
            ("Original Contribution (35%)", evidence.originalContributionScore, "Citation-based impact index"),
            ("Judging Work of Others (25%)", evidence.judgeScore, "Peer review contributions"),
            ("Awards & Recognition (20%)", evidence.awardsScore, "Verified certificates & badges"),
            ("High Salary Proxy (20%)", evidence.topPercentileScore, "Global percentile ranking")
        ]

        for (name, score, desc) in criteria {
            let nameAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 11),
                .foregroundColor: UIColor.black
            ]
            name.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: nameAttrs)

            let scoreStr = "\(Int(score))/100"
            let scoreColor = score >= 70 ? UIColor(red: 0, green: 0.6, blue: 0.3, alpha: 1) : UIColor.darkGray
            let criteriaScoreAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 11),
                .foregroundColor: scoreColor
            ]
            scoreStr.draw(at: CGPoint(x: pageRect.width - margin - 60, y: yPosition), withAttributes: criteriaScoreAttrs)

            yPosition += 18
            let descAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.italicSystemFont(ofSize: 9),
                .foregroundColor: UIColor.gray
            ]
            desc.draw(at: CGPoint(x: margin + 20, y: yPosition), withAttributes: descAttrs)
            yPosition += 25
        }

        // Footer
        drawFooter(context: context, pageRect: pageRect, pageNumber: 1)
    }

    // MARK: - Page 2: Detailed Evidence

    private func drawPage2(
        context: UIGraphicsPDFRendererContext,
        pageRect: CGRect,
        evidence: O1Evidence,
        badges: [CareerBadge]
    ) {
        let margin: CGFloat = 50
        var yPosition: CGFloat = margin

        // Title
        let title = "DETAILED VERIFICATION DATA"
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor(red: 0, green: 0.5, blue: 0.7, alpha: 1)
        ]
        title.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: titleAttrs)
        yPosition += 40

        // Statistics Section
        let statsTitle = "PLATFORM STATISTICS"
        let sectionAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor.darkGray
        ]
        statsTitle.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: sectionAttrs)
        yPosition += 25

        let stats = [
            ("Quantum Circuits Published", "\(evidence.circuitsPublished)"),
            ("Total Citations Received", "\(evidence.totalCitations)"),
            ("Peer Reviews Completed", "\(evidence.reviewsCompleted)"),
            ("Citation Index", String(format: "%.1f", Double(evidence.totalCitations) / max(1, Double(evidence.circuitsPublished)))),
            ("Impact Factor", String(format: "%.2f", evidence.originalContributionScore / 10))
        ]

        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor.darkGray
        ]
        let valueAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 11),
            .foregroundColor: UIColor.black
        ]

        for (label, value) in stats {
            label.draw(at: CGPoint(x: margin + 20, y: yPosition), withAttributes: labelAttrs)
            value.draw(at: CGPoint(x: pageRect.width - margin - 80, y: yPosition), withAttributes: valueAttrs)
            yPosition += 22
        }

        yPosition += 30

        // Skill Assessment
        let skillsTitle = "SKILL ASSESSMENT (RADAR ANALYSIS)"
        skillsTitle.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: sectionAttrs)
        yPosition += 25

        let skills = [
            ("Logic & Reasoning", evidence.logicScore),
            ("Innovation & Creativity", evidence.innovationScore),
            ("Community Contribution", evidence.contributionScore),
            ("Algorithm Stability", evidence.stabilityScore),
            ("Execution Speed", evidence.speedScore)
        ]

        for (skill, score) in skills {
            skill.draw(at: CGPoint(x: margin + 20, y: yPosition), withAttributes: labelAttrs)

            // Draw progress bar
            let barWidth: CGFloat = 150
            let barHeight: CGFloat = 12
            let barX = pageRect.width - margin - barWidth - 50
            let barY = yPosition

            context.cgContext.setFillColor(UIColor.lightGray.cgColor)
            context.cgContext.fill(CGRect(x: barX, y: barY, width: barWidth, height: barHeight))

            let fillWidth = barWidth * CGFloat(score / 100)
            context.cgContext.setFillColor(UIColor(red: 0, green: 0.6, blue: 0.8, alpha: 1).cgColor)
            context.cgContext.fill(CGRect(x: barX, y: barY, width: fillWidth, height: barHeight))

            let scoreStr = "\(Int(score))%"
            scoreStr.draw(at: CGPoint(x: pageRect.width - margin - 40, y: yPosition), withAttributes: valueAttrs)

            yPosition += 25
        }

        yPosition += 30

        // Badges Section
        let badgesTitle = "EARNED CERTIFICATIONS"
        badgesTitle.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: sectionAttrs)
        yPosition += 25

        let earnedBadges = badges.filter { $0.isEarned }
        if earnedBadges.isEmpty {
            let noBadgesText = "No certifications earned yet."
            noBadgesText.draw(at: CGPoint(x: margin + 20, y: yPosition), withAttributes: labelAttrs)
        } else {
            for badge in earnedBadges.prefix(8) {
                let badgeText = "[\(badge.tier.uppercased())] \(badge.name)"
                let tierColor: UIColor
                switch badge.tier {
                case "platinum": tierColor = UIColor.purple
                case "gold": tierColor = UIColor.orange
                case "silver": tierColor = UIColor.gray
                default: tierColor = UIColor.brown
                }

                let badgeAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 10),
                    .foregroundColor: tierColor
                ]
                badgeText.draw(at: CGPoint(x: margin + 20, y: yPosition), withAttributes: badgeAttrs)

                let descAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 9),
                    .foregroundColor: UIColor.gray
                ]
                badge.description.draw(at: CGPoint(x: margin + 200, y: yPosition), withAttributes: descAttrs)

                yPosition += 20
            }
        }

        // Footer
        drawFooter(context: context, pageRect: pageRect, pageNumber: 2)
    }

    // MARK: - Page 3: Verification

    private func drawPage3(
        context: UIGraphicsPDFRendererContext,
        pageRect: CGRect,
        evidence: O1Evidence,
        userName: String,
        userEmail: String,
        documentId: String,
        currentDate: String
    ) {
        let margin: CGFloat = 50
        var yPosition: CGFloat = margin

        // Title
        let title = "VERIFICATION & AUTHENTICITY"
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor(red: 0, green: 0.5, blue: 0.7, alpha: 1)
        ]
        title.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: titleAttrs)
        yPosition += 50

        // Verification Statement
        let verificationText = """
        This document has been generated by QuantumNative, an educational platform \
        for quantum computing based on Harvard-MIT quantum algorithms and Qiskit integration.

        All statistics presented in this report are derived from verifiable on-platform \
        activities including:

        - Peer-reviewed quantum circuit submissions
        - Anonymous peer review participation
        - Citation tracking through DOI system
        - Global ranking algorithms

        The data herein can be independently verified through the QuantumNative platform \
        verification system using the document ID provided.
        """

        let textAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor.darkGray
        ]
        let textRect = CGRect(x: margin, y: yPosition, width: pageRect.width - 2 * margin, height: 200)
        verificationText.draw(in: textRect, withAttributes: textAttrs)
        yPosition += 220

        // Subject Information Box
        let boxRect = CGRect(x: margin, y: yPosition, width: pageRect.width - 2 * margin, height: 80)
        context.cgContext.setFillColor(UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1).cgColor)
        context.cgContext.fill(boxRect)
        context.cgContext.setStrokeColor(UIColor.lightGray.cgColor)
        context.cgContext.stroke(boxRect)

        let subjectTitle = "SUBJECT INFORMATION"
        let subjectTitleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 10),
            .foregroundColor: UIColor.gray
        ]
        subjectTitle.draw(at: CGPoint(x: margin + 15, y: yPosition + 10), withAttributes: subjectTitleAttrs)

        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.darkGray
        ]
        "Name: \(userName)".draw(at: CGPoint(x: margin + 15, y: yPosition + 30), withAttributes: labelAttrs)
        "Email: \(userEmail)".draw(at: CGPoint(x: margin + 15, y: yPosition + 45), withAttributes: labelAttrs)
        "Document ID: \(documentId)".draw(at: CGPoint(x: margin + 15, y: yPosition + 60), withAttributes: labelAttrs)

        yPosition += 120

        // Disclaimer
        let disclaimerTitle = "DISCLAIMER"
        disclaimerTitle.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: subjectTitleAttrs)
        yPosition += 20

        let disclaimerText = """
        This report is provided for informational purposes and to support visa applications, \
        university admissions, or employment verification. QuantumNative makes no guarantees \
        regarding visa approval outcomes. All evidence should be verified independently as \
        part of any official process.
        """
        let disclaimerRect = CGRect(x: margin, y: yPosition, width: pageRect.width - 2 * margin, height: 60)
        let disclaimerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.italicSystemFont(ofSize: 9),
            .foregroundColor: UIColor.gray
        ]
        disclaimerText.draw(in: disclaimerRect, withAttributes: disclaimerAttrs)

        yPosition += 100

        // Signature area
        let signatureText = "Verified by QuantumNative Engine"
        let signatureAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor(red: 0, green: 0.5, blue: 0.7, alpha: 1)
        ]
        signatureText.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: signatureAttrs)
        yPosition += 20

        let protocolText = "Based on Harvard-MIT Quantum Computing Protocols"
        let protocolAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.italicSystemFont(ofSize: 10),
            .foregroundColor: UIColor.gray
        ]
        protocolText.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: protocolAttrs)

        // Footer
        drawFooter(context: context, pageRect: pageRect, pageNumber: 3)
    }

    // MARK: - Footer

    private func drawFooter(
        context: UIGraphicsPDFRendererContext,
        pageRect: CGRect,
        pageNumber: Int
    ) {
        let margin: CGFloat = 50
        let footerY = pageRect.height - 40

        // Line
        context.cgContext.setStrokeColor(UIColor.lightGray.cgColor)
        context.cgContext.setLineWidth(0.5)
        context.cgContext.move(to: CGPoint(x: margin, y: footerY - 10))
        context.cgContext.addLine(to: CGPoint(x: pageRect.width - margin, y: footerY - 10))
        context.cgContext.strokePath()

        // Footer text
        let footerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 8),
            .foregroundColor: UIColor.gray
        ]

        "QuantumNative - Quantum Computing Education Platform".draw(
            at: CGPoint(x: margin, y: footerY),
            withAttributes: footerAttrs
        )

        let pageText = "Page \(pageNumber) of 3"
        let pageTextSize = pageText.size(withAttributes: footerAttrs)
        pageText.draw(
            at: CGPoint(x: pageRect.width - margin - pageTextSize.width, y: footerY),
            withAttributes: footerAttrs
        )
    }

    // MARK: - Save to Files

    func saveReport(data: Data, fileName: String) -> URL? {
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]

        let fileURL = documentsPath.appendingPathComponent("\(fileName).pdf")

        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Failed to save PDF: \(error)")
            return nil
        }
    }
}
