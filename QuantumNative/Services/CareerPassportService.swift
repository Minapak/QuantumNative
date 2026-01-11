//
//  CareerPassportService.swift
//  QuantumNative
//
//  Quantum Career Passport - O1 Visa Evidence System
//  Created by QuantumNative Team
//  Copyright 2026 QuantumNative. All rights reserved.
//

import Foundation
import Combine

// MARK: - Career Passport Service

class CareerPassportService: ObservableObject {

    // MARK: - Singleton
    static let shared = CareerPassportService()

    // MARK: - Published Properties
    @Published var evidence: O1Evidence?
    @Published var myCircuits: [PublishedCircuit] = []
    @Published var publicCircuits: [PublishedCircuit] = []
    @Published var reviewQueue: [PublishedCircuit] = []
    @Published var leaderboard: [LeaderboardEntry] = []
    @Published var badges: [CareerBadge] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiClient = APIClient.shared

    private init() {}

    // MARK: - O1 Evidence

    /// Fetch O1 Evidence data
    func fetchEvidence() async {
        await MainActor.run { isLoading = true }

        do {
            let result: O1Evidence = try await apiClient.get(endpoint: "/api/v1/passport/evidence")
            await MainActor.run {
                self.evidence = result
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    /// Refresh O1 Evidence calculation
    func refreshEvidence() async {
        await MainActor.run { isLoading = true }

        do {
            let result: O1Evidence = try await apiClient.post(
                endpoint: "/api/v1/passport/evidence/refresh",
                body: EmptyBody()
            )
            await MainActor.run {
                self.evidence = result
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    // MARK: - Circuits

    /// Publish a new circuit
    func publishCircuit(
        title: String,
        description: String,
        circuitJSON: [String: Any],
        tags: [String] = []
    ) async throws -> PublishedCircuit {
        let body = CircuitCreateRequest(
            title: title,
            description: description,
            circuitJson: circuitJSON,
            tags: tags
        )

        return try await apiClient.post(
            endpoint: "/api/v1/passport/circuits",
            body: body
        )
    }

    /// Fetch my published circuits
    func fetchMyCircuits() async {
        do {
            let result: CircuitListResponse = try await apiClient.get(
                endpoint: "/api/v1/passport/circuits/mine"
            )
            await MainActor.run {
                self.myCircuits = result.circuits
            }
        } catch {
            print("Failed to fetch my circuits: \(error)")
        }
    }

    /// Fetch public circuits (QuantumCommons)
    func fetchPublicCircuits(page: Int = 1, limit: Int = 20) async {
        do {
            let result: CircuitListResponse = try await apiClient.get(
                endpoint: "/api/v1/passport/circuits?page=\(page)&limit=\(limit)"
            )
            await MainActor.run {
                self.publicCircuits = result.circuits
            }
        } catch {
            print("Failed to fetch public circuits: \(error)")
        }
    }

    /// Fork a circuit
    func forkCircuit(doi: String) async throws -> PublishedCircuit {
        return try await apiClient.post(
            endpoint: "/api/v1/passport/circuits/\(doi)/fork",
            body: EmptyBody()
        )
    }

    /// Run a circuit (adds citation)
    func runCircuit(doi: String) async throws -> CircuitRunResponse {
        return try await apiClient.post(
            endpoint: "/api/v1/passport/circuits/\(doi)/run",
            body: EmptyBody()
        )
    }

    // MARK: - Reviews

    /// Fetch review queue (for Level 10+ Pro users)
    func fetchReviewQueue() async {
        do {
            let result: CircuitListResponse = try await apiClient.get(
                endpoint: "/api/v1/passport/review-queue"
            )
            await MainActor.run {
                self.reviewQueue = result.circuits
            }
        } catch {
            print("Failed to fetch review queue: \(error)")
        }
    }

    /// Submit a review
    func submitReview(
        circuitId: Int,
        passFail: Bool,
        efficiencyScore: Int,
        feedback: String
    ) async throws -> CircuitReview {
        let body = ReviewSubmitRequest(
            circuitId: circuitId,
            passFail: passFail,
            efficiencyScore: efficiencyScore,
            feedback: feedback
        )

        return try await apiClient.post(
            endpoint: "/api/v1/passport/reviews",
            body: body
        )
    }

    // MARK: - Leaderboard

    /// Fetch global leaderboard
    func fetchLeaderboard(limit: Int = 100) async {
        do {
            let result: LeaderboardResponse = try await apiClient.get(
                endpoint: "/api/v1/passport/leaderboard?limit=\(limit)"
            )
            await MainActor.run {
                self.leaderboard = result.entries
            }
        } catch {
            print("Failed to fetch leaderboard: \(error)")
        }
    }

    // MARK: - Badges

    /// Fetch user badges
    func fetchBadges() async {
        do {
            let result: BadgeListResponse = try await apiClient.get(
                endpoint: "/api/v1/passport/badges"
            )
            await MainActor.run {
                self.badges = result.badges
            }
        } catch {
            print("Failed to fetch badges: \(error)")
        }
    }

    // MARK: - Stats

    /// Fetch contribution timeline
    func fetchContributionTimeline() async throws -> ContributionTimeline {
        return try await apiClient.get(endpoint: "/api/v1/passport/stats/timeline")
    }

    /// Fetch user stats
    func fetchStats() async throws -> PassportStats {
        return try await apiClient.get(endpoint: "/api/v1/passport/stats")
    }
}

// MARK: - Request Models

private struct EmptyBody: Encodable {}

struct CircuitCreateRequest: Encodable {
    let title: String
    let description: String
    let circuitJson: [String: Any]
    let tags: [String]

    enum CodingKeys: String, CodingKey {
        case title, description, tags
        case circuitJson = "circuit_json"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(tags, forKey: .tags)

        // Encode circuit_json as JSON string
        let jsonData = try JSONSerialization.data(withJSONObject: circuitJson)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            try container.encode(jsonString, forKey: .circuitJson)
        }
    }
}

struct ReviewSubmitRequest: Encodable {
    let circuitId: Int
    let passFail: Bool
    let efficiencyScore: Int
    let feedback: String

    enum CodingKeys: String, CodingKey {
        case circuitId = "circuit_id"
        case passFail = "pass_fail"
        case efficiencyScore = "efficiency_score"
        case feedback
    }
}

// MARK: - Response Models

struct O1Evidence: Codable, Identifiable {
    let id: Int
    let userId: Int
    let originalContributionScore: Double
    let judgeScore: Double
    let awardsScore: Double
    let topPercentileScore: Double
    let o1ReadinessScore: Double

    // Radar chart scores
    let logicScore: Double
    let innovationScore: Double
    let contributionScore: Double
    let stabilityScore: Double
    let speedScore: Double

    // Stats
    let globalRank: Int?
    let totalUsers: Int?
    let circuitsPublished: Int
    let totalCitations: Int
    let reviewsCompleted: Int

    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case originalContributionScore = "original_contribution_score"
        case judgeScore = "judge_score"
        case awardsScore = "awards_score"
        case topPercentileScore = "top_percentile_score"
        case o1ReadinessScore = "o1_readiness_score"
        case logicScore = "logic_score"
        case innovationScore = "innovation_score"
        case contributionScore = "contribution_score"
        case stabilityScore = "stability_score"
        case speedScore = "speed_score"
        case globalRank = "global_rank"
        case totalUsers = "total_users"
        case circuitsPublished = "circuits_published"
        case totalCitations = "total_citations"
        case reviewsCompleted = "reviews_completed"
        case updatedAt = "updated_at"
    }

    // Computed properties for UI
    var percentile: Double {
        guard let rank = globalRank, let total = totalUsers, total > 0 else {
            return 0
        }
        return (1.0 - Double(rank) / Double(total)) * 100
    }

    var radarScores: [Double] {
        [logicScore, innovationScore, contributionScore, stabilityScore, speedScore]
    }

    static let radarLabels = ["Logic", "Innovation", "Contribution", "Stability", "Speed"]
}

struct PublishedCircuit: Codable, Identifiable {
    let id: Int
    let userId: Int
    let doi: String
    let title: String
    let description: String?
    let gatesCount: Int
    let depth: Int
    let qubitCount: Int
    let isPublic: Bool
    let isVerified: Bool
    let forkCount: Int
    let citationCount: Int
    let runCount: Int
    let forkedFromId: Int?
    let tags: String?
    let createdAt: String

    // Author info (optional, from joined query)
    let authorName: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case doi, title, description
        case gatesCount = "gates_count"
        case depth
        case qubitCount = "qubit_count"
        case isPublic = "is_public"
        case isVerified = "is_verified"
        case forkCount = "fork_count"
        case citationCount = "citation_count"
        case runCount = "run_count"
        case forkedFromId = "forked_from_id"
        case tags
        case createdAt = "created_at"
        case authorName = "author_name"
    }

    var totalImpact: Int {
        forkCount * 3 + citationCount * 2 + runCount
    }

    var tagList: [String] {
        tags?.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) } ?? []
    }
}

struct CircuitReview: Codable, Identifiable {
    let id: Int
    let circuitId: Int
    let reviewerId: Int
    let passFail: Bool
    let efficiencyScore: Int
    let feedback: String?
    let status: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case circuitId = "circuit_id"
        case reviewerId = "reviewer_id"
        case passFail = "pass_fail"
        case efficiencyScore = "efficiency_score"
        case feedback, status
        case createdAt = "created_at"
    }
}

struct CircuitListResponse: Codable {
    let circuits: [PublishedCircuit]
    let total: Int
    let page: Int
    let limit: Int
}

struct CircuitRunResponse: Codable {
    let success: Bool
    let message: String
    let runCount: Int

    enum CodingKeys: String, CodingKey {
        case success, message
        case runCount = "run_count"
    }
}

struct LeaderboardEntry: Codable, Identifiable {
    let id: Int  // user_id
    let rank: Int
    let username: String
    let o1Score: Double
    let circuitsPublished: Int
    let totalCitations: Int
    let topBadge: String?

    enum CodingKeys: String, CodingKey {
        case id, rank, username
        case o1Score = "o1_score"
        case circuitsPublished = "circuits_published"
        case totalCitations = "total_citations"
        case topBadge = "top_badge"
    }
}

struct LeaderboardResponse: Codable {
    let entries: [LeaderboardEntry]
    let totalUsers: Int
    let userRank: Int?

    enum CodingKeys: String, CodingKey {
        case entries
        case totalUsers = "total_users"
        case userRank = "user_rank"
    }
}

struct CareerBadge: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let tier: String
    let earnedAt: String?
    let isEarned: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, description, icon, tier
        case earnedAt = "earned_at"
        case isEarned = "is_earned"
    }

    var tierColor: String {
        switch tier {
        case "platinum": return "platinum"
        case "gold": return "gold"
        case "silver": return "silver"
        default: return "bronze"
        }
    }
}

struct BadgeListResponse: Codable {
    let badges: [CareerBadge]
    let earnedCount: Int
    let totalCount: Int

    enum CodingKeys: String, CodingKey {
        case badges
        case earnedCount = "earned_count"
        case totalCount = "total_count"
    }
}

struct ContributionDay: Codable {
    let date: String
    let count: Int
    let intensity: Double  // 0.0 - 1.0
}

struct ContributionTimeline: Codable {
    let days: [ContributionDay]
    let totalContributions: Int
    let longestStreak: Int
    let currentStreak: Int

    enum CodingKeys: String, CodingKey {
        case days
        case totalContributions = "total_contributions"
        case longestStreak = "longest_streak"
        case currentStreak = "current_streak"
    }
}

struct PassportStats: Codable {
    let circuitsPublished: Int
    let totalCitations: Int
    let reviewsCompleted: Int
    let forksMade: Int
    let circuitsRun: Int
    let averageEfficiencyScore: Double
    let monthlyGrowth: Double

    enum CodingKeys: String, CodingKey {
        case circuitsPublished = "circuits_published"
        case totalCitations = "total_citations"
        case reviewsCompleted = "reviews_completed"
        case forksMade = "forks_made"
        case circuitsRun = "circuits_run"
        case averageEfficiencyScore = "average_efficiency_score"
        case monthlyGrowth = "monthly_growth"
    }
}
