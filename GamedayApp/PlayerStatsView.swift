//
//  PlayerStatsView.swift
//  GamedayApp
//
//  Created by Davlen Swain on 8/27/24.
//

import SwiftUI

struct PlayerStatsView: View {
    let playerGameStats: [PlayerGame]

    var body: some View {
        VStack(spacing: 16) {
            // Passing Section
            GroupedCategoryView(
                title: "Passing",
                teams: playerGameStats.flatMap { $0.teams ?? [] },
                filterCategory: "passing",
                statLabels: ["YDS",  "C/ATT",  "TD",  "INT",  "QBR"]
            )

            // Rushing Section
            GroupedCategoryView(
                title: "Rushing",
                teams: playerGameStats.flatMap { $0.teams ?? [] },
                filterCategory: "rushing",
                statLabels: ["YDS", "CAR", "AVG", "TD", "LONG"]
            )

            // Receiving Section
            GroupedCategoryView(
                title: "Receiving",
                teams: playerGameStats.flatMap { $0.teams ?? [] },
                filterCategory: "receiving",
                statLabels: ["YDS", "REC", "AVG", "TD", "LONG"]
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

struct GroupedCategoryView: View {
    let title: String
    let teams: [TeamStats]
    let filterCategory: String
    let statLabels: [String]

    var body: some View {
        VStack(spacing: 8) {
            headerView
            
            ForEach(teams, id: \.school) { team in
                if let category = filteredCategory(for: team, filterCategory: filterCategory) {
                    ForEach(groupedAthleteStats(for: category), id: \.id) { athleteStats in
                        PlayerStatCardView(athleteStats: athleteStats, statLabels: statLabels)
                    }
                }
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .shadow(radius: 2)
    }

    private var headerView: some View {
        Text(title)
            .font(.custom("Exo2-Italic", size: 20))
            .fontWeight(.bold)
            .padding(.vertical, 4)
            .foregroundColor(.gamedayRed)
    }

    private func filteredCategory(for team: TeamStats, filterCategory: String) -> Category? {
        return team.categories?.first(where: { $0.name == filterCategory })
    }

    private func groupedAthleteStats(for category: Category) -> [AthleteStatsGrouped] {
        var groupedStats = [String: AthleteStatsGrouped]()
        
        for type in category.types ?? [] {
            for athlete in type.athletes ?? [] {
                let athleteIdString = athlete.id.map(String.init) ?? "UnknownID"
                
                if groupedStats[athleteIdString] == nil {
                    groupedStats[athleteIdString] = AthleteStatsGrouped(id: athleteIdString, name: athlete.name)
                }
                groupedStats[athleteIdString]?.stats[type.name ?? ""] = athlete.stat
            }
        }
        
        return Array(groupedStats.values)
    }
}

// Struct to hold grouped stats for a player
struct AthleteStatsGrouped: Identifiable {
    let id: String
    let name: String?
    var stats = [String: String]()
}

// View to display the player stats in a single card
struct PlayerStatCardView: View {
    let athleteStats: AthleteStatsGrouped
    let statLabels: [String]
    
    let columns = [
        GridItem(.flexible(minimum: 47, maximum: 60)),
        GridItem(.flexible(minimum: 47, maximum: 60)),
        GridItem(.flexible(minimum: 47, maximum: 60)),
        GridItem(.flexible(minimum: 47, maximum: 60)),
        GridItem(.flexible(minimum: 47, maximum: 60)),
        GridItem(.flexible(minimum: 47, maximum: 60))
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(athleteStats.name ?? "Unknown Player")
                .font(.custom("Exo2-Italic", size: 16))
                .fontWeight(.bold)
                .foregroundColor(.gamedayRed)
            
            LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
                ForEach(statLabels, id: \.self) { label in
                    VStack {
                        Text(label)
                            .font(.custom("Exo2-Italic", size: 14))
                            .foregroundColor(.gray)
                        Text(athleteStats.stats[label] ?? "-")
                            .font(.custom("Exo2-Italic", size: 14))
                            .fontWeight(.semibold)
                            .foregroundColor(.gamedayRed)
                            .frame(minWidth: 35, maxWidth: .infinity) // Ensuring dynamic width
                            .padding(8) // Padding inside the box
                            .background(Color.white) // Box background color
                            .cornerRadius(8) // Rounding corners
                            .shadow(radius: 2) // Adding shadow for depth
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray5)) // Background color of the stat card
        .cornerRadius(12) // Rounding the card
        .shadow(radius: 3) // Adding shadow for card
    }
}


