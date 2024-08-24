import SwiftUI

struct GameDetailView: View {
    let game: Game
    let gameMedia: GameMedia?
    var teams: [Team]

    @State private var advancedBoxScore: AdvancedBoxScore?
    @State private var homeLogoURL: String?
    @State private var awayLogoURL: String?
    @State private var homeTeamStats: [PlayerSeasonStat] = []
    @State private var awayTeamStats: [PlayerSeasonStat] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack(spacing: 10) {
                    // Home Team Logo
                    if let homeLogoURL = homeLogoURL {
                        AsyncImage(url: URL(string: homeLogoURL)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 50, height: 50)
                            case .success(let image):
                                image.resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                    Text(game.homeTeam)
                        .font(.custom("Exo2-Italic", size: 20))
                        .fontWeight(.bold)

                    Spacer()

                    Text("vs")
                        .font(.custom("Exo2-Italic", size: 20))
                        .fontWeight(.bold)

                    Spacer()

                    // Away Team Logo
                    if let awayLogoURL = awayLogoURL {
                        AsyncImage(url: URL(string: awayLogoURL)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 50, height: 50)
                            case .success(let image):
                                image.resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                    Text(game.awayTeam)
                        .font(.custom("Exo2-Italic", size: 20))
                        .fontWeight(.bold)
                }
                .padding(.horizontal)

                Text("Venue: \(game.venue ?? "Unknown Location")")
                    .font(.custom("Exo2-Italic", size: 18))
                    .foregroundColor(.gray)

                VStack(alignment: .leading, spacing: 8) {
                    if let gameMedia = gameMedia {
                        Text("Date: \(formatDate(gameMedia.startTime))")
                            .font(.custom("Exo2-Italic", size: 16))
                        Text("Time: \(formatTime(gameMedia.startTime))")
                            .font(.custom("Exo2-Italic", size: 16))
                        Text("Network: \(gameMedia.outlet)")
                            .font(.custom("Exo2-Italic", size: 16))
                    } else {
                        Text("Date: TBD")
                            .font(.custom("Exo2-Italic", size: 16))
                        Text("Time: TBD")
                            .font(.custom("Exo2-Italic", size: 16))
                        Text("Network: TBD")
                            .font(.custom("Exo2-Italic", size: 16))
                    }
                }
                .padding(.horizontal)

                // Check if the game is upcoming by comparing the startTime
                if isUpcomingGame(game) {
                    LeaderStatsView(
                        homeTeamLeaders: homeTeamStats,
                        awayTeamLeaders: awayTeamStats,
                        homeTeamName: game.homeTeam,
                        awayTeamName: game.awayTeam
                    )
                } else {
                    // Only show advanced box score if the game is completed
                    if let advancedBoxScore = advancedBoxScore {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Advanced Box Score")
                                .font(.headline)
                                .padding(.bottom, 4)
                            
                            // Game Info
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Winner: \(advancedBoxScore.gameInfo?.homeWinner == true ? game.homeTeam : game.awayTeam)")
                                    Text("Home Points: \(advancedBoxScore.gameInfo?.homePoints ?? 0)")
                                    Text("Away Points: \(advancedBoxScore.gameInfo?.awayPoints ?? 0)")
                                    Text("Home Win Probability: \(advancedBoxScore.gameInfo?.homeWinProb ?? "N/A")")
                                    Text("Away Win Probability: \(advancedBoxScore.gameInfo?.awayWinProb ?? "N/A")")
                                    Text("Excitement Index: \(advancedBoxScore.gameInfo?.excitement ?? "N/A")")
                                }
                                .font(.custom("Exo2-Italic", size: 14))
                            }
                            .padding(.horizontal)
                            
                            Divider()
                            
                            // Quarter-by-Quarter Scores
                            Text("Quarter-by-Quarter Scores")
                                .font(.headline)
                                .padding(.bottom, 4)
                            
                            HStack {
                                Text("Quarter")
                                    .font(.custom("Exo2-Italic", size: 14))
                                    .fontWeight(.bold)
                                Spacer()
                                Text("Q1")
                                    .font(.custom("Exo2-Italic", size: 14))
                                    .fontWeight(.bold)
                                Text("Q2")
                                    .font(.custom("Exo2-Italic", size: 14))
                                    .fontWeight(.bold)
                                Text("Q3")
                                    .font(.custom("Exo2-Italic", size: 14))
                                    .fontWeight(.bold)
                                Text("Q4")
                                    .font(.custom("Exo2-Italic", size: 14))
                                    .fontWeight(.bold)
                                Text("Total")
                                    .font(.custom("Exo2-Italic", size: 14))
                                    .fontWeight(.bold)
                            }
                            .padding(.horizontal)
                            
                            HStack {
                                Text(game.homeTeam)
                                    .font(.custom("Exo2-Italic", size: 14))
                                Spacer()
                                if let homeStats = advancedBoxScore.teams?.ppa?.first(where: { $0.team == game.homeTeam }) {
                                    Text("\(homeStats.overall?.quarter1 ?? 0, specifier: "%.1f")")
                                    Text("\(homeStats.overall?.quarter2 ?? 0, specifier: "%.1f")")
                                    Text("\(homeStats.overall?.quarter3 ?? 0, specifier: "%.1f")")
                                    Text("\(homeStats.overall?.quarter4 ?? 0, specifier: "%.1f")")
                                    Text("\(homeStats.overall?.total ?? 0, specifier: "%.3f")")
                                }
                            }
                            .padding(.horizontal)
                            
                            HStack {
                                Text(game.awayTeam)
                                    .font(.custom("Exo2-Italic", size: 14))
                                Spacer()
                                if let awayStats = advancedBoxScore.teams?.ppa?.first(where: { $0.team == game.awayTeam }) {
                                    Text("\(awayStats.overall?.quarter1 ?? 0, specifier: "%.1f")")
                                    Text("\(awayStats.overall?.quarter2 ?? 0, specifier: "%.1f")")
                                    Text("\(awayStats.overall?.quarter3 ?? 0, specifier: "%.1f")")
                                    Text("\(awayStats.overall?.quarter4 ?? 0, specifier: "%.1f")")
                                    Text("\(awayStats.overall?.total ?? 0, specifier: "%.3f")")
                                }
                            }
                            .padding(.horizontal)
                            
                            Divider()
                            
                            // Players Stats
                            Text("Player Statistics")
                                .font(.headline)
                                .padding(.vertical, 4)
                            
                            if let playerStats = advancedBoxScore.players?.ppa {
                                ForEach(playerStats, id: \.player) { playerStat in
                                    VStack(alignment: .leading) {
                                        Text("\(playerStat.player ?? "Unknown Player") - \(playerStat.team ?? "Unknown Team")")
                                            .font(.custom("Exo2-Italic", size: 16))
                                            .fontWeight(.bold)
                                        
                                        Grid {
                                            GridRow {
                                                Text("Category")
                                                Text("Q1")
                                                Text("Q2")
                                                Text("Q3")
                                                Text("Q4")
                                                Text("Total")
                                            }
                                            .font(.custom("Exo2-Italic", size: 14))
                                            .fontWeight(.bold)
                                            
                                            if let averageStats = playerStat.average {
                                                GridRow {
                                                    Text("Average")
                                                    Text("\(averageStats.quarter1 ?? 0, specifier: "%.1f")")
                                                    Text("\(averageStats.quarter2 ?? 0, specifier: "%.1f")")
                                                    Text("\(averageStats.quarter3 ?? 0, specifier: "%.1f")")
                                                    Text("\(averageStats.quarter4 ?? 0, specifier: "%.1f")")
                                                    Text("\(averageStats.total ?? 0, specifier: "%.3f")")
                                                }
                                            }
                                            
                                            if let cumulativeStats = playerStat.cumulative {
                                                GridRow {
                                                    Text("Cumulative")
                                                    Text("\(cumulativeStats.quarter1 ?? 0, specifier: "%.1f")")
                                                    Text("\(cumulativeStats.quarter2 ?? 0, specifier: "%.1f")")
                                                    Text("\(cumulativeStats.quarter3 ?? 0, specifier: "%.1f")")
                                                    Text("\(cumulativeStats.quarter4 ?? 0, specifier: "%.1f")")
                                                    Text("\(cumulativeStats.total ?? 0, specifier: "%.3f")")
                                                }
                                            }
                                        }
                                        .padding(.bottom, 4)
                                    }
                                    .padding(.horizontal)
                                }
                            } else {
                                Text("No player stats available.")
                                    .padding(.horizontal)
                            }
                            
                            Divider()
                            
                            // Key for Metrics Explanation
                            Text("Key for Metrics")
                                .font(.headline)
                                .padding(.vertical, 4)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• **PPA (Points Per Attempt):** A measure of how many points a play contributes to the team’s overall success.")
                                Text("• **Success Rate:** The percentage of plays that are successful based on the situation.")
                                Text("• **Explosiveness:** A measure of how big the successful plays are on average.")
                                Text("• **Havoc Rate:** The percentage of plays where the defense disrupts the offense.")
                                Text("• **Line Yards:** The average yards the offensive line is responsible for before the runner is touched by the defense.")
                                Text("• **Power Success Rate:** The percentage of short-yardage runs on third or fourth down that achieve a first down or touchdown.")
                                Text("• **Stuff Rate:** The percentage of runs that are stopped at or before the line of scrimmage.")
                                Text("• **Scoring Opportunities:** The number of times a team moved the ball inside the opponent's 40-yard line.")
                                Text("• **Points Per Opportunity:** The average number of points scored per scoring opportunity.")
                            }
                            .font(.custom("Exo2-Italic", size: 14))
                            .padding(.horizontal)
                            
                        }
                        .padding(.horizontal)
                    } else {
                        Text("No advanced stats available for this game.")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
                
                Spacer()
            }
            .navigationBarTitle("Game Details", displayMode: .inline)
            .padding()
            .onAppear {
                loadTeamLogos()
                if !isUpcomingGame(game) { // Fetch only if the game is completed
                    Task {
                        await fetchAdvancedBoxScore()
                    }
                }
            }
        }
    }

    // Determine if the game is upcoming
    private func isUpcomingGame(_ game: Game) -> Bool {
        if let startTime = gameMedia?.startTime {
            let currentDate = Date()
            let gameDate = ISO8601DateFormatter().date(from: startTime) ?? currentDate
            return gameDate > currentDate
        }
        return false
    }

    private func loadTeamLogos() {
        homeLogoURL = logo(for: game.homeTeamID)
        awayLogoURL = logo(for: game.awayTeamID)
    }

    private func logo(for teamID: Int) -> String? {
        if let team = teams.first(where: { $0.id == teamID }), let logo = team.logos?.first {
            return logo.replacingOccurrences(of: "http://", with: "https://")
        }
        return nil
    }

    private func fetchAdvancedBoxScore() async {
        do {
            if let boxScore = await TeamService.shared.fetchAdvancedBoxScore(
                gameId: game.id,
                week: game.week,
                team: game.homeTeam
            ) {
                DispatchQueue.main.async {
                    self.advancedBoxScore = boxScore
                }
            }
        } catch {
            print("Failed to fetch advanced box score: \(error.localizedDescription)")
        }
    }

    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = ISO8601DateFormatter()
        guard let date = dateFormatter.date(from: dateString) else {
            return "Date format error"
        }
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        return displayFormatter.string(from: date)
    }

    private func formatTime(_ dateString: String) -> String {
        let dateFormatter = ISO8601DateFormatter()
        guard let date = dateFormatter.date(from: dateString) else {
            return "Time format error"
        }
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        return timeFormatter.string(from: date)
    }
}


