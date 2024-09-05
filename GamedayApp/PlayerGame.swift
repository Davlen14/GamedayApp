//
//  PlayerGame.swift
//  GamedayApp
//
//  Created by Davlen Swain on 8/27/24.
//

import Foundation

struct PlayerGame: Decodable {
    let id: Int?
    let teams: [TeamStats]?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try? container.decode(Int.self, forKey: .id)
        self.teams = try? container.decode([TeamStats].self, forKey: .teams)
    }

    enum CodingKeys: String, CodingKey {
        case id, teams
    }
}

struct TeamStats: Decodable {
    let school: String?
    let conference: String?
    let homeAway: String?
    let points: Int?
    let categories: [Category]?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.school = try? container.decode(String.self, forKey: .school)
        self.conference = try? container.decode(String.self, forKey: .conference)
        self.homeAway = try? container.decode(String.self, forKey: .homeAway)
        self.points = try? container.decode(Int.self, forKey: .points)
        self.categories = try? container.decode([Category].self, forKey: .categories)
    }

    enum CodingKeys: String, CodingKey {
        case school, conference, homeAway, points, categories
    }
}

struct Category: Decodable {
    let name: String?
    let types: [StatType]?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try? container.decode(String.self, forKey: .name)
        self.types = try? container.decode([StatType].self, forKey: .types)
    }

    enum CodingKeys: String, CodingKey {
        case name, types
    }
}

struct StatType: Decodable {
    let name: String?
    let athletes: [AthleteStat]?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try? container.decode(String.self, forKey: .name)
        self.athletes = try? container.decode([AthleteStat].self, forKey: .athletes)
    }

    enum CodingKeys: String, CodingKey {
        case name, athletes
    }
}

struct AthleteStat: Decodable {
    let id: Int?
    let name: String?
    let stat: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try? container.decode(Int.self, forKey: .id)
        self.name = try? container.decode(String.self, forKey: .name)
        self.stat = try? container.decode(String.self, forKey: .stat)
    }

    enum CodingKeys: String, CodingKey {
        case id, name, stat
    }
}




