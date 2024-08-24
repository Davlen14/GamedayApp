//
//  Polls.swift
//  GamedayApp
//
//  Created by Davlen Swain on 8/5/24.
//

import Foundation

struct RankingWeek: Identifiable, Codable {
    var id = UUID()
    var season: Int?
    var seasonType: String?
    var week: Int?
    var polls: [Poll]?

    enum CodingKeys: String, CodingKey {
        case season, seasonType, week, polls
    }
}

struct Poll: Identifiable, Codable {
    var id = UUID()
    var poll: String?
    var ranks: [Rank]?

    enum CodingKeys: String, CodingKey {
        case poll, ranks
    }
}

struct Rank: Identifiable, Codable {
    var id = UUID()
    var rank: Int?
    var school: String?
    var conference: String?
    var firstPlaceVotes: Int?
    var points: Int?

    enum CodingKeys: String, CodingKey {
        case rank, school, conference, firstPlaceVotes, points
    }
}


