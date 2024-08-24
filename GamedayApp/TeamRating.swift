// TeamRating.swift
// GamedayApp
//
// Created by Davlen Swain on 8/2/24.
//

import Foundation

struct TeamRating: Decodable {
    let team: String // Corresponds to the team name
    let overallRanking: Int?
    let offenseRanking: Int?
    let defenseRanking: Int?

    // Custom CodingKeys to map nested JSON structure
    enum CodingKeys: String, CodingKey {
        case team
        case overallRanking = "ranking"
        case offense
        case defense
    }

    enum OffenseKeys: String, CodingKey {
        case ranking
    }

    enum DefenseKeys: String, CodingKey {
        case ranking
    }

    // Custom initializer to decode nested structures
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        team = try container.decode(String.self, forKey: .team)
        overallRanking = try container.decodeIfPresent(Int.self, forKey: .overallRanking)
        
        // Decode offense ranking
        if let offenseContainer = try? container.nestedContainer(keyedBy: OffenseKeys.self, forKey: .offense) {
            offenseRanking = try offenseContainer.decodeIfPresent(Int.self, forKey: .ranking)
        } else {
            offenseRanking = nil
        }

        // Decode defense ranking
        if let defenseContainer = try? container.nestedContainer(keyedBy: DefenseKeys.self, forKey: .defense) {
            defenseRanking = try defenseContainer.decodeIfPresent(Int.self, forKey: .ranking)
        } else {
            defenseRanking = nil
        }
    }
}



