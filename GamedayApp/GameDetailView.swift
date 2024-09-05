import SwiftUI

struct GameDetailView: View {
    let game: Game
    let gameMedia: GameMedia?
    var teams: [Team]

    @State private var advancedBoxScore: AdvancedBoxScore?
    @State private var homeLogoURL: String?
    @State private var awayLogoURL: String?
    @State private var playerGameStats: [PlayerGame] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Team Logos and Info
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

                // Game Info
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

                // Advanced Box Score Info
                if let advancedBoxScore = advancedBoxScore {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Game Details")
                            .font(.headline)
                            .padding(.bottom, 4)

                        Text("Winner: \(advancedBoxScore.gameInfo?.homeWinner == true ? game.homeTeam : game.awayTeam)")
                        Text("Home Points: \(advancedBoxScore.gameInfo?.homePoints ?? 0)")
                        Text("Away Points: \(advancedBoxScore.gameInfo?.awayPoints ?? 0)")
                        Text("Home Win Probability: \(advancedBoxScore.gameInfo?.homeWinProb ?? "N/A")")
                        Text("Away Win Probability: \(advancedBoxScore.gameInfo?.awayWinProb ?? "N/A")")
                        Text("Excitement Index: \(advancedBoxScore.gameInfo?.excitement ?? "N/A")")
                    }
                    .font(.custom("Exo2-Italic", size: 14))
                    .padding(.horizontal)
                } else {
                    Text("No advanced stats available for this game.")
                        .foregroundColor(.gray)
                        .padding()
                }

                // Win Probability View
                if let advancedBoxScore = advancedBoxScore {
                    WinProbabilityView(
                        homeTeam: game.homeTeam,
                        awayTeam: game.awayTeam,
                        homeWinProb: Double(advancedBoxScore.gameInfo?.homeWinProb ?? "0.0") ?? 0.0,
                        awayWinProb: Double(advancedBoxScore.gameInfo?.awayWinProb ?? "0.0") ?? 0.0,
                        homeLogoURL: homeLogoURL,
                        awayLogoURL: awayLogoURL
                    )
                }

                // Player Stats View
                PlayerStatsView(playerGameStats: playerGameStats)

                Spacer()
            }
            .navigationBarTitle("Game Details", displayMode: .inline)
            .padding()
            .onAppear {
                loadTeamLogos()
                Task {
                    await fetchAdvancedBoxScore()
                    await fetchPlayerStats()
                }
            }
        }
    }

    // Helper Methods
    private func loadTeamLogos() {
        homeLogoURL = logo(for: game.homeTeamID)
        awayLogoURL = logo(for: game.awayTeamID)
    }

    private func fetchPlayerStats() async {
        do {
            // Example values for year, week, seasonType, and team
            let year = 2024
            let week = game.week
            let seasonType = "regular"
            let team = game.homeTeam // Or use game.awayTeam depending on the context

            // Call the function with the necessary parameters
            let stats = try await TeamService.shared.fetchPlayerGameStats(
                gameId: game.id,
                year: year,
                week: week,
                seasonType: seasonType,
                team: team,
                category: "passing" // You can change the category as needed
            )
            
            DispatchQueue.main.async {
                self.playerGameStats = stats
            }
        } catch {
            print("Failed to fetch player stats: \(error.localizedDescription)")
        }
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

    private func logo(for teamID: Int) -> String? {
        if let team = teams.first(where: { $0.id == teamID }), let logo = team.logos?.first {
            return logo.replacingOccurrences(of: "http://", with: "https://")
        }
        return nil
    }

    private func formatDate(_ dateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = isoFormatter.date(from: dateString) else {
            return "Date format error"
        }

        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeZone = TimeZone.current // Ensuring the date is in the current timezone

        return displayFormatter.string(from: date)
    }

    private func formatTime(_ dateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = isoFormatter.date(from: dateString) else {
            return "Time format error"
        }

        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        timeFormatter.timeZone = TimeZone.current // Ensuring the time is in the current timezone

        return timeFormatter.string(from: date)
    }
}





