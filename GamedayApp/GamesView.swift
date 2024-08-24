import SwiftUI
import Foundation

struct Game: Identifiable, Decodable {
    let id: Int
    let homeTeamID: Int
    let awayTeamID: Int
    let homeTeam: String
    let awayTeam: String
    let homePoints: Int?
    let awayPoints: Int?
    let venue: String?
    let week: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case homeTeamID = "home_id"
        case awayTeamID = "away_id"
        case homeTeam = "home_team"
        case awayTeam = "away_team"
        case homePoints = "home_points"
        case awayPoints = "away_points"
        case venue
        case week
    }
}

struct GamesView: View {
    @State private var games: [Game] = []
    @State private var gameMediaList: [GameMedia] = []
    @State private var gameLines: [GameLine] = []
    @State private var errorMessage: String?
    @State private var currentWeek: Int = 1
    @State private var currentYear: Int = Calendar.current.component(.year, from: Date())
    @State private var currentConference: Int = 0
    @State private var teams: [Team] = []

    private let maxWeek = 15
    private let conferences = ["All", "ACC", "American Athletic", "Big 12", "Big Ten", "Conference USA", "Mid-American", "Mountain West", "Pac-12", "SEC", "Sun Belt", "FBS Independents"]
    private let years = Array(2015...Calendar.current.component(.year, from: Date())).reversed()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top bar with systemGray6 background and red text/icons
                ZStack {
                    Color(.systemGray5)
                        .edgesIgnoringSafeArea(.top)
                        .frame(height: 130)

                    VStack {
                        Text("CFB ScoreBoard")
                            .font(.custom("Exo2-Italic", size: 34))
                            .foregroundColor(Color.gamedayRed)
                            .padding(.top, 10)

                        HStack {
                            // Actions buttons
                            ForEach([("chart.bar.fill", "Ranks"), ("dollarsign.circle.fill", "Lines"), ("newspaper.fill", "News"), ("bubble.right.fill", "Chat")], id: \.1) { icon, title in
                                Button(action: {
                                    // Action for each button
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: icon)
                                            .font(.system(size: 14))
                                            .foregroundColor(Color.gamedayRed)
                                        Text(title)
                                            .font(.custom("Exo2-Italic", size: 12))
                                            .foregroundColor(Color.gamedayRed)
                                    }
                                    .padding(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gamedayRed.opacity(0.8), lineWidth: 1)
                                    )
                                }
                            }

                            Spacer()
                            Text("View All")
                                .font(.custom("Exo2-Italic", size: 12))
                                .foregroundColor(Color.gamedayRed)
                                .padding(.trailing)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                }
                // Select Year and Week Section
                VStack(spacing: 0) {
                    HStack {
                        Picker("Select Year", selection: $currentYear) {
                            ForEach(years, id: \.self) { year in
                                Text(String(year)).tag(year)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 2)

                        Picker("Select Week", selection: $currentWeek) {
                            ForEach(1...maxWeek, id: \.self) { week in
                                Text("Week \(week)").tag(week)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 2)

                        Picker("Select Conference", selection: $currentConference) {
                            ForEach(0..<conferences.count, id: \.self) { index in
                                HStack {
                                    Text(conferences[index])
                                        .font(.custom("Exo2-Italic", size: 14))
                                }
                                .tag(index)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .background(Color(.systemGray5))
                }
                .padding(.vertical, 1)

                // Display error message or game list
                if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .font(.custom("Exo2-Italic", size: 14))
                        .foregroundColor(.red)
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(games) { game in
                                let gameMedia = gameMediaList.first { $0.id == game.id }

                                NavigationLink(destination: destinationView(for: game, gameMedia: gameMedia)) {
                                    GameCardView(game: game, teams: teams, gameMedia: gameMedia)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                        .shadow(color: .gray.opacity(0.1), radius: 3, x: 0, y: 2)
                                        .padding(.vertical, 5)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }

                Spacer()
            }
            .background(Color(.systemGray5))
            .onAppear {
                Task {
                    await fetchGames()
                    await fetchTeams()
                    await fetchGameMedia()
                }
            }
            .onChange(of: currentWeek) { _, _ in Task { await fetchGames() } }
            .onChange(of: currentYear) { _, _ in Task { await fetchGames() } }
        }
    }

    @ViewBuilder
    private func destinationView(for game: Game, gameMedia: GameMedia?) -> some View {
        if isUpcomingGame(game, gameMedia: gameMedia) {
            LeaderStatsView(
                homeTeamLeaders: [], // Pass necessary data
                awayTeamLeaders: [], // Pass necessary data
                homeTeamName: game.homeTeam,
                awayTeamName: game.awayTeam
            )
        } else {
            GameDetailView(
                game: game,
                gameMedia: gameMedia,
                teams: teams
            )
        }
    }

    private func isUpcomingGame(_ game: Game, gameMedia: GameMedia?) -> Bool {
        if let startTime = gameMedia?.startTime {
            let currentDate = Date()
            let gameDate = ISO8601DateFormatter().date(from: startTime) ?? currentDate
            return gameDate > currentDate
        }
        return false
    }

    func fetchGames() async {
        do {
            let games = try await TeamService.shared.fetchGames(year: currentYear)
            DispatchQueue.main.async {
                self.games = games.filter { $0.week == self.currentWeek }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func fetchGameMedia() async {
        do {
            let mediaList = try await TeamService.shared.fetchGameMedia()
            DispatchQueue.main.async {
                self.gameMediaList = mediaList
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func fetchTeams() async {
        do {
            let teams = try await TeamService.shared.fetchTeams()
            DispatchQueue.main.async {
                self.teams = teams
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func logo(for teamID: Int) -> String? {
        guard let team = teams.first(where: { $0.id == teamID }) else {
            return nil
        }
        guard let logo = team.logos?.first else {
            return nil
        }
        return logo.replacingOccurrences(of: "http://", with: "https://")
    }
}

struct GameCardView: View {
    var game: Game
    var teams: [Team]
    var gameMedia: GameMedia?
    var gameLine: GameLine?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Home Team Logo and Name
                if let homeLogo = logo(for: game.homeTeamID) {
                    AsyncImage(url: URL(string: homeLogo)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 25, height: 25)
                        case .success(let image):
                            image.resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .cornerRadius(5)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }

                VStack(alignment: .leading) {
                    HStack {
                        Text(game.homeTeam)
                            .font(.custom("Exo2-Italic", size: 14))
                            .foregroundColor(Color(.label))
                        
                        // Home Team Points
                        Text("(\(game.homePoints ?? 0))")
                            .font(.custom("Exo2-Italic", size: 14))
                            .fontWeight(.bold)
                            .foregroundColor(game.homePoints ?? 0 > game.awayPoints ?? 0 ? .green : .black)
                    }
                    Text(gameMedia?.homeConference ?? "")
                        .font(.custom("Exo2-Italic", size: 12))
                        .foregroundColor(.gray)
                }

                Spacer()

                Text("vs")
                    .font(.custom("Exo2-Italic", size: 14))
                    .foregroundColor(.gray)

                Spacer()

                VStack(alignment: .trailing) {
                    HStack {
                        // Away Team Points
                        Text("(\(game.awayPoints ?? 0))")
                            .font(.custom("Exo2-Italic", size: 14))
                            .fontWeight(.bold)
                            .foregroundColor(game.awayPoints ?? 0 > game.homePoints ?? 0 ? .green : .black)
                        
                        Text(game.awayTeam)
                            .font(.custom("Exo2-Italic", size: 14))
                            .foregroundColor(Color(.label))
                    }
                    Text(gameMedia?.awayConference ?? "")
                        .font(.custom("Exo2-Italic", size: 12))
                        .foregroundColor(.gray)
                }

                if let awayLogo = logo(for: game.awayTeamID) {
                    AsyncImage(url: URL(string: awayLogo)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 25, height: 25)
                        case .success(let image):
                            image.resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .cornerRadius(5)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
            }

            Spacer()

            HStack {
                VStack(alignment: .leading) {
                    // Location and Network
                    Text("Location: \(game.venue ?? "Unknown Location")")
                        .font(.custom("Exo2-Italic", size: 12))
                        .foregroundColor(.gray)
                    if let gameMedia = gameMedia {
                        HStack {
                            Image(systemName: "tv")
                            Text("Network: \(gameMedia.outlet)")
                        }
                        .font(.custom("Exo2-Italic", size: 12))
                        .foregroundColor(.gray)
                    }
                }

                Spacer()

                VStack(alignment: .trailing) {
                    // Time
                    if let gameMedia = gameMedia {
                        Text(formatTime(gameMedia.startTime))
                            .font(.custom("Exo2-Italic", size: 12))
                            .foregroundColor(.gray)
                    }
                }
            }

            Spacer()

            // All lines display side by side
            if let lines = gameLine?.lines, !lines.isEmpty {
                HStack {
                    ForEach(lines, id: \.provider) { line in
                        HStack(spacing: 10) {
                            Image(providerImageName(for: line.provider ?? "default"))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .cornerRadius(4)

                            Text("\(line.provider ?? "Unknown"): Spread \(String(format: "%.1f", line.spread ?? 0.0)), O/U \(String(format: "%.1f", line.overUnder ?? 0.0))")
                                .font(.system(size: 10))
                                .foregroundColor(.black)
                        }
                    }
                }
            } else {
                // Generate default lines for each known provider
                HStack {
                    ForEach(defaultProviders, id: \.self) { provider in
                        HStack(spacing: 10) {
                            Image(providerImageName(for: provider))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .cornerRadius(4)

                            Text("\(provider): N/A")
                                .font(.system(size: 10))
                                .foregroundColor(.black)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(color: Color.gray.opacity(0.1), radius: 3, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        )
    }

    func logo(for teamID: Int) -> String? {
        guard let team = teams.first(where: { $0.id == teamID }) else {
            return nil
        }
        guard let logo = team.logos?.first else {
            return nil
        }
        return logo.replacingOccurrences(of: "http://", with: "https://")
    }

    private func formatTime(_ dateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        guard let date = isoFormatter.date(from: dateString) else {
            return "TBD"
        }
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        timeFormatter.timeZone = TimeZone.current
        return timeFormatter.string(from: date)
    }

    private func providerImageName(for provider: String) -> String {
        switch provider {
        case "Bovada":
            return "bovada"
        case "DraftKings":
            return "draftkings"
        case "ESPN Bet":
            return "espnbet"
        default:
            return "default" // Default symbol or icon for missing logos
        }
    }

    private var defaultProviders: [String] {
        return ["Bovada", "DraftKings", "ESPN Bet"]
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct GamesView_Previews: PreviewProvider {
    static var previews: some View {
        GamesView()
    }
}
