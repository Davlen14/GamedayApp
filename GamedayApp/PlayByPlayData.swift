//
//  PlayByPlayData.swift
//  GamedayApp
//
//  Created by Davlen Swain on 9/6/24.
//
import Foundation

// Root struct representing the Play-by-Play Data
struct PlayByPlayData: Decodable {
    let id: Int
    let status: String
    let period: Int
    let clock: String? // Optional since clock might be missing
    let possession: String? // Optional since possession might be missing
    let down: Int
    let distance: Int
    let yardsToGoal: Int
    let teams: [TeamPlayByPlay]
    let drives: [Drive]
}

// Team Data in Play-by-Play
struct TeamPlayByPlay: Decodable {
    let teamId: Int
    let team: String
    let homeAway: String
    let lineScores: [Int]? // Optional since line scores might be missing
    let points: Int
    let drives: Int?
    let scoringOpportunities: Int?
    let pointsPerOpportunity: Double?
    let plays: Int?
    let lineYards: Double?
    let lineYardsPerRush: Double?
    let secondLevelYards: Double?
    let secondLevelYardsPerRush: Double?
    let openFieldYards: Double?
    let openFieldYardsPerRush: Double?
    let epaPerPlay: Double?
    let totalEpa: Double?
    let passingEpa: Double?
    let epaPerPass: Double?
    let rushingEpa: Double?
    let epaPerRush: Double?
    let successRate: Double?
    let standardDownSuccessRate: Double?
    let passingDownSuccessRate: Double?
    let explosiveness: Double?
}

// Drive Data in Play-by-Play
struct Drive: Decodable {
    let id: String
    let offenseId: Int
    let offense: String
    let defenseId: Int
    let defense: String
    let playCount: Int
    let yards: Int
    let startPeriod: Int
    let startClock: String? // Optional since clock might be missing
    let startYardsToGoal: Int
    let endPeriod: Int? // Optional since it might be null
    let endClock: String? // Optional since clock might be missing
    let endYardsToGoal: Int?
    let duration: String?
    let scoringOpportunity: Bool
    let result: String?
    let pointsGained: Int
    let plays: [Play]
}

// Individual Play Data in a Drive
struct Play: Decodable {
    let id: String
    let homeScore: Int? // Optional to handle missing scores
    let awayScore: Int? // Optional to handle missing scores
    let period: Int
    let clock: String? // Optional since clock might be missing
    let wallClock: String
    let teamId: Int
    let team: String
    let down: Int
    let distance: Int
    let yardsToGoal: Int
    let yardsGained: Int? // Optional since it might be null
    let playTypeId: Int?
    let playType: String?
    let epa: Double?
    let garbageTime: Bool
    let success: Bool
    let rushPash: String?
    let downType: String?
    let playText: String?
}




