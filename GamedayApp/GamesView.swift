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
    let home_line_scores: [Int]? // Updated to be an array of Ints for quarter scores
    let away_line_scores: [Int]? // Updated to be an array of Ints for quarter scores
    let venue: String?
    let week: Int
    var weather: GameWeather? // Weather data
    let status: String? // Status of the game
    let period: Int? // Period (quarter in football)
    let clock: String? // Game clock (time remaining)
    let possession: String? // Team in possession of the ball
    let betting: Betting? // Betting details

    // CodingKeys map the JSON keys to the Swift properties
    enum CodingKeys: String, CodingKey {
        case id
        case homeTeamID = "home_id"
        case awayTeamID = "away_id"
        case homeTeam = "home_team"
        case awayTeam = "away_team"
        case homePoints = "home_points"
        case awayPoints = "away_points"
        case home_line_scores
        case away_line_scores
        case venue
        case week
        case weather // Add weather here
        case status
        case period
        case clock
        case possession
        case betting
    }
}



// Struct to handle the betting information
struct Betting: Decodable {
    let spread: Double? // Point spread
    let overUnder: Double? // Over/Under total points
    let homeMoneyline: Int? // Moneyline for the home team
    let awayMoneyline: Int? // Moneyline for the away team
}

// Struct to handle the weather information
struct GameWeather: Decodable {
    let id: Int
    let temperature: Double?
    let weatherCondition: String?
    let windSpeed: Double?
    let windDirection: Double?
    let humidity: Int?
    let precipitation: Double?
}



struct GamesView: View {
    @State private var games: [Game] = []
    @State private var gameMediaList: [GameMedia] = []
    @State private var gameLines: [GameLine] = []
    @State private var errorMessage: String?
    @State private var currentWeek: Int = 2
    @State private var currentYear: Int = Calendar.current.component(.year, from: Date())
    @State private var currentConference: Int = 0
    @State private var teams: [Team] = []
    @State private var apTop25Ranks: [Rank] = []

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
                                let gameLine = gameLines.first { $0.id == game.id }

                                NavigationLink(destination: destinationView(for: game, gameMedia: gameMedia)) {
                                    GameCardView(game: game, teams: teams, gameMedia: gameMedia, gameLine: gameLine, apTop25Ranks: apTop25Ranks)
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
                    await fetchGameLines()
                    await fetchAPTop25Rankings() // Fetch the rankings
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
        guard let startTime = gameMedia?.startTime else {
            return false
        }
        
        let currentDate = Date()
        
        // Set up the ISO8601DateFormatter with proper time zone handling
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let gameDate = isoFormatter.date(from: startTime) {
            print("Game Date: \(gameDate), Current Date: \(currentDate)")
            return gameDate > currentDate
        } else {
            print("Failed to parse game start time: \(startTime)")
            return false
        }
    }

    func fetchGames() async {
        do {
            // Fetch games and weather data concurrently
            async let gamesTask = TeamService.shared.fetchGames(year: currentYear)
            async let weatherTask = TeamService.shared.fetchGameWeather(year: currentYear, week: currentWeek)
            
            let games = try await gamesTask
            let weatherData = try await weatherTask
            
            // Merge weather data with games
            let gamesWithWeather = games.map { game -> Game in
                var game = game
                if let weather = weatherData.first(where: { $0.id == game.id }) {
                    game.weather = weather
                }
                return game
            }
            
            DispatchQueue.main.async {
                self.games = gamesWithWeather.filter { $0.week == self.currentWeek }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }


    func fetchAPTop25Rankings() async {
        do {
            print("Fetching AP Top 25 rankings for year: \(currentYear)")

            let rankings = try await TeamService.shared.fetchPolls(year: currentYear, seasonType: "regular")
            if let apPoll = rankings.first(where: { $0.polls?.contains(where: { $0.poll == "AP Top 25" }) == true }),
               let ranks = apPoll.polls?.first(where: { $0.poll == "AP Top 25" })?.ranks {
                DispatchQueue.main.async {
                    print("Fetched AP Top 25 ranks: \(ranks.count)")
                    self.apTop25Ranks = ranks
                }
            }
        } catch {
            DispatchQueue.main.async {
                print("Error fetching AP Top 25: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func fetchGameMedia() async {
        do {
            let mediaList = try await TeamService.shared.fetchGameMedia(year: currentYear, week: currentWeek) // Pass year and week
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

    func fetchGameLines() async {
        do {
            let lines = try await TeamService.shared.fetchGameLines(year: currentYear)
            DispatchQueue.main.async {
                self.gameLines = lines
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func displayTeamNameWithRank(for teamName: String) -> String {
        if let rank = apTop25Ranks.first(where: { $0.school == teamName })?.rank {
            return "#\(rank) \(teamName)"
        } else {
            return teamName
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
    var apTop25Ranks: [Rank]
    @State private var playByPlayData: PlayByPlayData? = nil
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                if let homeLogo = logo(for: game.homeTeamID) {
                    AsyncImage(url: URL(string: homeLogo)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 50, height: 50)
                        case .success(let image):
                            image.resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .cornerRadius(8)
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

                VStack(alignment: .leading, spacing: 4) {
                    Text(displayTeamNameWithRank(for: game.homeTeam))
                        .font(.custom("Exo2-Italic", size: 14))
                        .foregroundColor(Color(.label))
                    
                    Text(gameMedia?.homeConference ?? "")
                        .font(.custom("Exo2-Italic", size: 14))
                        .foregroundColor(.gray)
                    
                    // Display live or fallback to stored game home points
                    Text("Score: \(liveHomeScore())")
                        .font(.custom("Exo2-Italic", size: 14))
                        .foregroundColor(liveHomeScore() > liveAwayScore() ? .green : .red)
                }
                
                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(displayTeamNameWithRank(for: game.awayTeam))
                        .font(.custom("Exo2-Italic", size: 14))
                        .foregroundColor(Color(.label))
                    
                    Text(gameMedia?.awayConference ?? "")
                        .font(.custom("Exo2-Italic", size: 14))
                        .foregroundColor(.gray)
                    
                    // Display live or fallback to stored game away points
                    Text("Score: \(liveAwayScore())")
                        .font(.custom("Exo2-Italic", size: 14))
                        .foregroundColor(liveAwayScore() > liveHomeScore() ? .green : .red)
                }

                if let awayLogo = logo(for: game.awayTeamID) {
                    AsyncImage(url: URL(string: awayLogo)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 50, height: 50)
                        case .success(let image):
                            image.resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .cornerRadius(8)
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
            }
            .padding(.horizontal)
            
            Divider()

            // Weather and Network Information
            HStack(spacing: 12) {
                if let weather = game.weather, let gameMedia = gameMedia {
                    VStack(alignment: .leading) {
                        Image(weatherIcon(for: weather.weatherCondition, temperature: weather.temperature, gameTime: gameMedia.startTime))
                            .resizable()
                            .frame(width: 24, height: 24)

                        Text("Temp: \(String(format: "%.1f", weather.temperature ?? 0))°")
                            .font(.custom("Exo2-Italic", size: 14))
                            .foregroundColor(.gray)
                    }
                } else if let weather = game.weather {
                    VStack(alignment: .leading) {
                        Image(weatherIcon(for: weather.weatherCondition, temperature: weather.temperature, gameTime: nil))
                            .resizable()
                            .frame(width: 24, height: 24)

                        Text("Temp: \(String(format: "%.1f", weather.temperature ?? 0))°")
                            .font(.custom("Exo2-Italic", size: 14))
                            .foregroundColor(.gray)
                    }
                }
            
                VStack(alignment: .leading, spacing: 4) {
                    if let gameMedia = gameMedia {
                        HStack {
                            Image(systemName: "tv")
                            Text("Network: \(gameMedia.outlet)")
                        }
                        .font(.custom("Exo2-Italic", size: 14))
                        .foregroundColor(.gray)
                        
                        Text("Date: \(formatDate(gameMedia.startTime))")
                            .font(.custom("Exo2-Italic", size: 14))
                            .foregroundColor(.gray)
                        
                        Text("Time: \(formatTime(gameMedia.startTime))")
                            .font(.custom("Exo2-Italic", size: 14))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)

            Divider()
            
            // Lines section
            if let lines = gameLine?.lines, !lines.isEmpty {
                HStack {
                    ForEach(lines, id: \.provider) { line in
                        VStack {
                            Image(providerImageName(for: line.provider ?? "default"))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .cornerRadius(4)
                            
                            Text("\(line.provider ?? "Unknown")")
                                .font(.system(size: 10))
                                .foregroundColor(.black)
                            Text("Spread: \(String(format: "%.1f", line.spread ?? 0.0))")
                                .font(.system(size: 10))
                                .foregroundColor(.black)
                            Text("O/U: \(String(format: "%.1f", line.overUnder ?? 0.0))")
                                .font(.system(size: 10))
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            } else {
                Text("No betting lines available")
                    .font(.custom("Exo2-Italic", size: 12))
                    .foregroundColor(.gray)
                    .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }

    // Timer to fetch live play-by-play data
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 90.0, repeats: true) { _ in
            Task {
                await loadPlayByPlayData()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func loadPlayByPlayData() async {
        // Fetch the latest play-by-play data using game ID
        do {
            let fetchedData = try await TeamService.shared.fetchPlayByPlay(gameId: game.id)
            DispatchQueue.main.async {
                playByPlayData = fetchedData
            }
        } catch {
            print("Error fetching play-by-play data: \(error)")
        }
    }

    // Helper function to get live home score from PlayByPlayData or fallback to game.homePoints
    private func liveHomeScore() -> Int {
        if let data = playByPlayData {
            return data.teams.first(where: { $0.homeAway == "home" })?.points ?? 0
        } else {
            return game.homePoints ?? 0
        }
    }

    // Helper function to get live away score from PlayByPlayData or fallback to game.awayPoints
    private func liveAwayScore() -> Int {
        if let data = playByPlayData {
            return data.teams.first(where: { $0.homeAway == "away" })?.points ?? 0
        } else {
            return game.awayPoints ?? 0
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

    private func displayTeamNameWithRank(for teamName: String) -> String {
        if let rank = apTop25Ranks.first(where: { $0.school == teamName })?.rank {
            return "#\(rank) \(teamName)"
        } else {
            return teamName
        }
    }

    private func weatherIcon(for condition: String?, temperature: Double?, gameTime: String?) -> String {
        // Check if the game is at night (after 6:00 PM)
        if let gameTime = gameTime, isNightGame(gameTime: gameTime) {
            return "moon" // Use your moon image for night games
        }

        // If it's not night, handle based on temperature and weather conditions
        if let temp = temperature, temp > 85 {
            return "sun1" // Use your sun image for high temperatures
        }

        switch condition?.lowercased() {
        case "cloudy":
            return "cloud" // Use your cloud image
        case "light rain":
            return "rain" // Use your rain image
        case "heavy rain":
            return "rain" // Use the same rain image for heavy rain
        case "clear", "fair":
            return "sun1" // Use your sun image for clear and fair conditions
        default:
            return "cloud" // Default to cloud if condition is unknown
        }
    }

    private func isNightGame(gameTime: String) -> Bool {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a" // Adjust based on your game time format

        if let date = timeFormatter.date(from: gameTime) {
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            return hour >= 18 // Consider 6:00 PM or later as night time
        }

        return false
    }

    private func formatDate(_ dateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = isoFormatter.date(from: dateString) else {
            return "TBD"
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeZone = TimeZone.current
        
        return displayFormatter.string(from: date)
    }

    private func formatTime(_ dateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
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
            return "default"
        }
    }
}
