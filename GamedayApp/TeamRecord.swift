import Foundation

struct TeamRecord: Identifiable, Decodable {
    var id = UUID()
    var year: Int?
    var teamId: Int?
    var team: String?
    var conference: String?
    var division: String?
    var expectedWins: Double?
    var total: GameStats?
    var conferenceGames: GameStats?
    var homeGames: GameStats?
    var awayGames: GameStats?
    
    enum CodingKeys: String, CodingKey {
        case year
        case teamId
        case team
        case conference
        case division
        case expectedWins
        case total
        case conferenceGames
        case homeGames
        case awayGames
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        year = try container.decodeIfPresent(Int.self, forKey: .year)
        teamId = try container.decodeIfPresent(Int.self, forKey: .teamId)
        team = try container.decodeIfPresent(String.self, forKey: .team)
        conference = try container.decodeIfPresent(String.self, forKey: .conference)
        division = try container.decodeIfPresent(String.self, forKey: .division)
        expectedWins = try container.decodeIfPresent(Double.self, forKey: .expectedWins)
        total = try container.decodeIfPresent(GameStats.self, forKey: .total)
        conferenceGames = try container.decodeIfPresent(GameStats.self, forKey: .conferenceGames)
        homeGames = try container.decodeIfPresent(GameStats.self, forKey: .homeGames)
        awayGames = try container.decodeIfPresent(GameStats.self, forKey: .awayGames)
    }
}

struct GameStats: Decodable {
    var games: Int?
    var wins: Int?
    var losses: Int?
    var ties: Int?
}
