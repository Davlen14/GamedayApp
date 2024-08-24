//
//  GameMedia.swift
//  GamedayApp
//
//  Created by Davlen Swain on 8/3/24.
//

import Foundation

struct GameMedia: Identifiable, Decodable {
    let id: Int
    let season: Int
    let week: Int
    let seasonType: String
    let startTime: String
    let isStartTimeTBD: Bool
    let homeTeam: String
    let homeConference: String
    let awayTeam: String
    let awayConference: String
    let mediaType: String
    let outlet: String
}
