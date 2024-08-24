//
//  LeaderStatsView.swift
//  GamedayApp
//
//  Created by Davlen Swain on 8/21/24.
//

import SwiftUI

struct LeaderStatsView: View {
    let homeTeamLeaders: [PlayerSeasonStat]
    let awayTeamLeaders: [PlayerSeasonStat]
    let homeTeamName: String
    let awayTeamName: String

    var body: some View {
        VStack {
            // Home Team Leaders
            Text("\(homeTeamName) Leaders")
                .font(.custom("Exo2-Italic", size: 22))
                .fontWeight(.bold)
                .padding(.vertical, 8)
            
            teamStatsSection(for: homeTeamLeaders)

            Divider()
                .padding(.vertical)
            
            // Away Team Leaders
            Text("\(awayTeamName) Leaders")
                .font(.custom("Exo2-Italic", size: 22))
                .fontWeight(.bold)
                .padding(.vertical, 8)
            
            teamStatsSection(for: awayTeamLeaders)
        }
        .padding()
    }
    
    // Helper function to generate stats section for a given team
    private func teamStatsSection(for teamLeaders: [PlayerSeasonStat]) -> some View {
        VStack(alignment: .leading) {
            ForEach(groupedStats(for: teamLeaders).sorted(by: { $0.key < $1.key }), id: \.key) { category, stats in
                Text(category.capitalized)
                    .font(.custom("Exo2-Italic", size: 20))
                    .padding(.vertical, 4)
                
                HStack {
                    ForEach(stats, id: \.player) { stat in
                        VStack {
                            Text(stat.player ?? "Unknown Player")
                                .font(.custom("Exo2-Italic", size: 16))
                                .fontWeight(.bold)
                            
                            Text("\(Int(stat.stat ?? 0))")
                                .font(.custom("Exo2-Italic", size: 16))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                    }
                }
                Divider()
            }
        }
    }
    
    // Group stats by category
    private func groupedStats(for teamLeaders: [PlayerSeasonStat]) -> [String: [PlayerSeasonStat]] {
        let categories = ["passing", "rushing", "receiving"]
        var grouped: [String: [PlayerSeasonStat]] = [:]
        
        for category in categories {
            grouped[category] = teamLeaders.filter { $0.category == category }
        }
        
        return grouped
    }
}

struct LeaderStatsView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderStatsView(
            homeTeamLeaders: [],
            awayTeamLeaders: [],
            homeTeamName: "Home Team",
            awayTeamName: "Away Team"
        )
    }
}



