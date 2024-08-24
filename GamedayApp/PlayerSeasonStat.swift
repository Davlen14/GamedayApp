//
//  PlayerSeasonStat.swift
//  GamedayApp
//
//  Created by Davlen Swain on 8/5/24.
//

import Foundation

struct PlayerSeasonStat: Codable, Identifiable, Equatable {
    let id: UUID? = UUID()
    let season: Int?
    let playerId: Int?
    let player: String?
    let team: String?
    let conference: String?
    let category: String?
    let statType: String?
    let stat: Double?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.season = try? container.decode(Int.self, forKey: .season)
        self.playerId = try? container.decode(Int.self, forKey: .playerId)
        self.player = try? container.decode(String.self, forKey: .player)
        self.team = try? container.decode(String.self, forKey: .team)
        self.conference = try? container.decode(String.self, forKey: .conference)
        self.category = try? container.decode(String.self, forKey: .category)
        self.statType = try? container.decode(String.self, forKey: .statType)
        if let statString = try? container.decode(String.self, forKey: .stat),
           let statValue = Double(statString) {
            self.stat = statValue
        } else {
            self.stat = try? container.decode(Double.self, forKey: .stat)
        }
    }

    enum CodingKeys: String, CodingKey {
        case season, playerId, player, team, conference, category, statType, stat
    }
    
    // Equatable conformance
    static func == (lhs: PlayerSeasonStat, rhs: PlayerSeasonStat) -> Bool {
        return lhs.playerId == rhs.playerId && lhs.stat == rhs.stat && lhs.category == rhs.category
    }
}








