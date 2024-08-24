//
//  Player.swift
//  GamedayApp
//
//  Created by Davlen Swain on 8/3/24.
//


// Player.swift
import Foundation

struct Player: Identifiable, Codable {
    let id: String
    let firstName: String
    let lastName: String
    let team: String
    let weight: Int?
    let height: Int?
    let jersey: Int?
    let year: Int?
    let position: String?
    let homeCity: String?
    let homeState: String?
    let homeCountry: String?
    let homeLatitude: String?
    let homeLongitude: String?
    let homeCountyFips: String?
    let recruitIds: [Int]?

    var name: String {
        return "\(firstName) \(lastName)"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case team
        case weight
        case height
        case jersey
        case year
        case position
        case homeCity = "home_city"
        case homeState = "home_state"
        case homeCountry = "home_country"
        case homeLatitude = "home_latitude"
        case homeLongitude = "home_longitude"
        case homeCountyFips = "home_county_fips"
        case recruitIds = "recruit_ids"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        team = try container.decode(String.self, forKey: .team)
        weight = try container.decodeIfPresent(Int.self, forKey: .weight)
        height = try container.decodeIfPresent(Int.self, forKey: .height)
        jersey = try container.decodeIfPresent(Int.self, forKey: .jersey)
        year = try container.decode(Int.self, forKey: .year)
        position = try container.decodeIfPresent(String.self, forKey: .position)
        homeCity = try container.decodeIfPresent(String.self, forKey: .homeCity)
        homeState = try container.decodeIfPresent(String.self, forKey: .homeState)
        homeCountry = try container.decodeIfPresent(String.self, forKey: .homeCountry)
        homeLatitude = try container.decodeIfPresent(String.self, forKey: .homeLatitude)
        homeLongitude = try container.decodeIfPresent(String.self, forKey: .homeLongitude)
        homeCountyFips = try container.decodeIfPresent(String.self, forKey: .homeCountyFips)
        recruitIds = try container.decodeIfPresent([Int].self, forKey: .recruitIds)
    }
}

extension Player {
    // Debugging function to log potential issues
    static func debugLog(_ data: Data, error: Error) {
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Failed to decode Player with data: \(jsonString)")
        }
        print("Decoding error: \(error.localizedDescription)")
    }
}

// Usage example when decoding:
func decodePlayer(data: Data) -> Player? {
    do {
        return try JSONDecoder().decode(Player.self, from: data)
    } catch {
        Player.debugLog(data, error: error)
        return nil
    }
}

