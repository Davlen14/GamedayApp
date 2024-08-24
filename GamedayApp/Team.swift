// Team.swift
// GamedayApp
//
// Created by Davlen Swain on 7/31/24.
//

import Foundation

struct Team: Codable, Identifiable, Hashable {
    var id: Int // Unique identifier for the team
    var school: String
    var mascot: String?
    var conference: String?
    var logos: [String]?
    var color: String? // Primary color
    var alt_color: String? // Alternative color
    var abbreviation: String? // Corrected the spelling

    // Additional computed properties or methods can be added here if needed
}









