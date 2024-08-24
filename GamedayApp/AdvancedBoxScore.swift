import Foundation

// Main Struct
struct AdvancedBoxScore: Decodable {
    let gameInfo: GameInfo?
    let teams: Teams?
    let players: Players?
}

// Game Info Struct
struct GameInfo: Decodable {
    let homeTeam: String?
    let homePoints: Int?
    let homeWinProb: String?
    let awayTeam: String?
    let awayPoints: Int?
    let awayWinProb: String?
    let homeWinner: Bool?
    let excitement: String?
}

// Define the missing struct if it's not already defined
struct TeamScoringOpportunities: Decodable {
    let team: String?
    let opportunities: Int?
    let points: Int?
    let pointsPerOpportunity: Double?
}

// Define the Teams struct
struct Teams: Decodable {
    let ppa: [TeamPPA]?
    let cumulativePpa: [TeamCumulativePPA]?
    let successRates: [TeamSuccessRates]?
    let explosiveness: [TeamExplosiveness]?
    let rushing: [TeamRushing]?
    let havoc: [TeamHavoc]?
    let scoringOpportunities: [TeamScoringOpportunities]?
    let fieldPosition: [TeamFieldPosition]?
}
// Unified PerformanceByQuarter Struct for consistent structure across stats
struct PerformanceByQuarter: Decodable {
    let total: Double?
    let quarter1: Double?
    let quarter2: Double?
    let quarter3: Double?
    let quarter4: Double?
}

// TeamPPA Struct
struct TeamPPA: Decodable {
    let team: String?
    let plays: Int?
    let overall, passing, rushing: PerformanceByQuarter?
}

// TeamCumulativePPA Struct
struct TeamCumulativePPA: Decodable {
    let team: String?
    let plays: Int?
    let overall, passing, rushing: PerformanceByQuarter?
}

// TeamSuccessRates Struct
struct TeamSuccessRates: Decodable {
    let team: String?
    let overall, standardDowns, passingDowns: PerformanceByQuarter?
}

// TeamExplosiveness Struct
struct TeamExplosiveness: Decodable {
    let team: String?
    let overall: PerformanceByQuarter?
}

// TeamRushing Struct with Custom Initializer
struct TeamRushing: Decodable {
    let team: String?
    let powerSuccess: Double?
    let stuffRate: Double?
    let lineYards: Double?
    let lineYardsAverage: Double?
    let secondLevelYards: Double?
    let secondLevelYardsAverage: Double?
    let openFieldYards: Double?
    let openFieldYardsAverage: Double?

    enum CodingKeys: String, CodingKey {
        case team
        case powerSuccess
        case stuffRate
        case lineYards
        case lineYardsAverage
        case secondLevelYards
        case secondLevelYardsAverage
        case openFieldYards
        case openFieldYardsAverage
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        team = try container.decodeIfPresent(String.self, forKey: .team)
        
        // Decode potential String or Double values for all relevant fields
        powerSuccess = try? container.decodeStringOrDouble(forKey: .powerSuccess)
        stuffRate = try? container.decodeStringOrDouble(forKey: .stuffRate)
        lineYards = try? container.decodeStringOrDouble(forKey: .lineYards)
        lineYardsAverage = try? container.decodeStringOrDouble(forKey: .lineYardsAverage)
        secondLevelYards = try? container.decodeStringOrDouble(forKey: .secondLevelYards)
        secondLevelYardsAverage = try? container.decodeStringOrDouble(forKey: .secondLevelYardsAverage)
        openFieldYards = try? container.decodeStringOrDouble(forKey: .openFieldYards)
        openFieldYardsAverage = try? container.decodeStringOrDouble(forKey: .openFieldYardsAverage)
    }
}

// TeamHavoc Struct with Custom Initializer
struct TeamHavoc: Decodable {
    let team: String?
    let total: Double?
    let frontSeven: Double?
    let db: Double?

    enum CodingKeys: String, CodingKey {
        case team
        case total
        case frontSeven
        case db
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        team = try container.decodeIfPresent(String.self, forKey: .team)
        
        total = try? container.decodeStringOrDouble(forKey: .total)
        frontSeven = try? container.decodeStringOrDouble(forKey: .frontSeven)
        db = try? container.decodeStringOrDouble(forKey: .db)
    }
}

// TeamFieldPosition Struct with Custom Initializer
struct TeamFieldPosition: Decodable {
    let team: String?
    let averageStart: Double?
    let averageStartingPredictedPoints: Double?

    enum CodingKeys: String, CodingKey {
        case team
        case averageStart
        case averageStartingPredictedPoints
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        team = try container.decodeIfPresent(String.self, forKey: .team)
        averageStart = try? container.decodeStringOrDouble(forKey: .averageStart)
        averageStartingPredictedPoints = try? container.decodeStringOrDouble(forKey: .averageStartingPredictedPoints)
    }
}

// Players Struct
struct Players: Decodable {
    let usage: [PlayerUsage]?
    let ppa: [PlayerPPA]?
}

// PlayerUsage Struct
struct PlayerUsage: Decodable {
    let player: String?
    let team: String?
    let position: String?
    let total: Double?
    let quarter1: Double?
    let quarter2: Double?
    let quarter3: Double?
    let quarter4: Double?
    let rushing: Double?
    let passing: Double?
}

// PlayerPPA Struct
struct PlayerPPA: Decodable {
    let player: String?
    let team: String?
    let position: String?
    let average: PerformanceByQuarter?
    let cumulative: PerformanceByQuarter?
}

// MARK: - Helper for Decoding String or Double

extension KeyedDecodingContainer {
    func decodeStringOrDouble(forKey key: K) throws -> Double {
        if let stringValue = try? self.decode(String.self, forKey: key) {
            return Double(stringValue) ?? 0.0
        } else if let doubleValue = try? self.decode(Double.self, forKey: key) {
            return doubleValue
        } else {
            return 0.0
        }
    }
}
