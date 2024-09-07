import Foundation

class TeamService {
    static let shared = TeamService()
    
    private let apiKey = "XB5Eui0++wuuyh5uZ2c+UJY4jmLKQ2jxShzJXZaM9ET21a1OgubV4/mFlCxzsBIQ"
    private let baseURL = "https://my-betting-bot-davlen-2bc8e47f62ae.herokuapp.com/api"
    private let linesBaseURL = "https://api.collegefootballdata.com"
    private let V2BaseURL = "https://apinext.collegefootballdata.com"  // New V2 Base URL
    
    private init() {}

    // Generic fetch function using async/await
    private func fetchData<T: Decodable>(from urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
    
    // Function to fetch live play-by-play data with retry logic
    func fetchPlayByPlay(gameId: Int) async throws -> PlayByPlayData {
        let playByPlayPath = "/live/plays"
        let queryItems = [
            URLQueryItem(name: "gameId", value: String(gameId))
        ]
        
        var urlComponents = URLComponents(string: V2BaseURL + playByPlayPath)
        urlComponents?.queryItems = queryItems
        
        guard let finalURL = urlComponents?.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: finalURL)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        var retries = 3
        while retries > 0 {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP Status Code: \(httpResponse.statusCode)")
                    if !(200...299).contains(httpResponse.statusCode) {
                        print("Server Error: \(String(data: data, encoding: .utf8) ?? "No error message")")
                        throw URLError(.badServerResponse)
                    }
                }
                
                print("Response Data: \(String(data: data, encoding: .utf8) ?? "No Data")")
                
                let decoder = JSONDecoder()
                return try decoder.decode(PlayByPlayData.self, from: data)
                
            } catch {
                if retries == 1 {
                    print("Error fetching play-by-play data: \(error.localizedDescription)")
                    throw error
                }
                retries -= 1
                print("Retrying... \(retries) attempts left")
                try await Task.sleep(nanoseconds: 2 * 1_000_000_000) // Wait 2 seconds before retrying
            }
        }
        
        throw URLError(.cannotLoadFromNetwork)
    }




    
    // Add the fetchScoreboard function
        func fetchScoreboard(year: Int, week: Int) async throws -> [Game] {
            let scoreboardPath = "/games"
            let queryItems = [
                URLQueryItem(name: "year", value: String(year)),
                URLQueryItem(name: "week", value: String(week))
            ]
            
            var urlComponents = URLComponents(string: linesBaseURL + scoreboardPath)
            urlComponents?.queryItems = queryItems
            
            guard let finalURL = urlComponents?.url else {
                throw URLError(.badURL)
            }
            
            return try await fetchData(from: finalURL.absoluteString)
        }

    func fetchAdvancedBoxScore(gameId: Int, week: Int, team: String, seasonType: String = "regular") async -> AdvancedBoxScore? {
        let boxScorePath = "/game/box/advanced"
        let queryItems = [
            URLQueryItem(name: "gameId", value: String(gameId)),
            URLQueryItem(name: "week", value: String(week)),
            URLQueryItem(name: "team", value: team),
            URLQueryItem(name: "seasonType", value: seasonType)
        ]
        
        guard var urlComponents = URLComponents(string: linesBaseURL + boxScorePath) else {
            print("Invalid URL")
            return nil
        }
        
        urlComponents.queryItems = queryItems
        
        guard let finalURL = urlComponents.url else {
            print("Invalid URL components")
            return nil
        }
        
        // Debug: Print the constructed URL
        print("Fetching data from: \(finalURL.absoluteString)")
        
        do {
            // Fetch the data and decode it into the AdvancedBoxScore struct
            let advancedBoxScore: AdvancedBoxScore = try await fetchData(from: finalURL.absoluteString)
            
            // Debug: Print the raw data (if necessary for debugging)
            // print("Raw Data: \(String(data: data, encoding: .utf8) ?? "No Data")")
            
            return advancedBoxScore
        } catch {
            // Print the full error for better debugging
            print("Failed to decode AdvancedBoxScore. Error: \(error)")
            return nil
        }
    }
   // Fetch team records using async/await
    func fetchTeamRecords(teamId: Int, year: Int) async throws -> [TeamRecord] {
        let recordsPath = "/college-football/records"
        let queryItems = [
            URLQueryItem(name: "teamId", value: String(teamId)),
            URLQueryItem(name: "year", value: String(year))
        ]
        
        var urlComponents = URLComponents(string: baseURL + recordsPath)
        urlComponents?.queryItems = queryItems
        
        guard let finalURL = urlComponents?.url else {
            throw URLError(.badURL)
        }
        
        return try await fetchData(from: finalURL.absoluteString)
    }
    
    // Fetch team polls using async/await
    func fetchPolls(year: Int, seasonType: String = "regular") async throws -> [RankingWeek] {
        let pollsPath = "/rankings"
        let queryItems = [
            URLQueryItem(name: "year", value: String(year)),
            URLQueryItem(name: "seasonType", value: seasonType)
        ]
        
        var urlComponents = URLComponents(string: linesBaseURL + pollsPath)
        urlComponents?.queryItems = queryItems
        
        guard let finalURL = urlComponents?.url else {
            throw URLError(.badURL)
        }
        
        return try await fetchData(from: finalURL.absoluteString)
    }
    
    // Fetch player season stats using async/await
    func fetchPlayerSeasonStats(year: Int = 2023, team: String? = nil, category: String, seasonType: String = "regular", limit: Int = 200) async throws -> [PlayerSeasonStat] {
        let statsPath = "/stats/player/season"
        var queryItems = [
            URLQueryItem(name: "year", value: String(year)),
            URLQueryItem(name: "category", value: category),
            URLQueryItem(name: "seasonType", value: seasonType),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        if let team = team, !team.isEmpty {
            queryItems.append(URLQueryItem(name: "team", value: team))
        }
        
        var urlComponents = URLComponents(string: linesBaseURL + statsPath)
        urlComponents?.queryItems = queryItems
        
        guard let finalURL = urlComponents?.url else {
            throw URLError(.badURL)
        }
        
        return try await fetchData(from: finalURL.absoluteString)
    }
    
    // Fetch teams using async/await
    func fetchTeams() async throws -> [Team] {
        let teamsURL = "\(baseURL)/college-football/teams-fbs?year=2023"
        return try await fetchData(from: teamsURL)
    }
    


    // Fetch games using async/await with FBS filter
    func fetchGames(year: Int, seasonType: String = "regular", division: String = "fbs") async throws -> [Game] {
        let gamesPath = "/games"
        let queryItems = [
            URLQueryItem(name: "year", value: String(year)),
            URLQueryItem(name: "seasonType", value: seasonType),
            URLQueryItem(name: "division", value: division)
        ]
        
        var urlComponents = URLComponents(string: linesBaseURL + gamesPath)
        urlComponents?.queryItems = queryItems
        
        guard let finalURL = urlComponents?.url else {
            throw URLError(.badURL)
        }
        
        return try await fetchData(from: finalURL.absoluteString)
    }

    
    // Fetch game media using async/await with year and week selection and error handling
    func fetchGameMedia(year: Int, week: Int) async throws -> [GameMedia] {
        let gameMediaPath = "/college-football/games/media"
        let queryItems = [
            URLQueryItem(name: "year", value: String(year)),
            URLQueryItem(name: "week", value: String(week)) // Add week filter
        ]

        var urlComponents = URLComponents(string: baseURL + gameMediaPath)
        urlComponents?.queryItems = queryItems

        guard let finalURL = urlComponents?.url else {
            throw URLError(.badURL)
        }

        do {
            return try await fetchData(from: finalURL.absoluteString)
        } catch {
            print("Error fetching game media: \(error)")
            throw error
        }
    }
    
    // Fetch team ratings and rankings using async/await
    func fetchRatings(year: Int = 2023, team: String? = nil) async throws -> [TeamRating] {
        let ratingsPath = "/ratings/sp"
        var queryItems = [URLQueryItem(name: "year", value: String(year))]
        if let team = team {
            queryItems.append(URLQueryItem(name: "team", value: team))
        }
        
        var urlComponents = URLComponents(string: baseURL + ratingsPath)
        urlComponents?.queryItems = queryItems
        
        guard let finalURL = urlComponents?.url else {
            throw URLError(.badURL)
        }
        
        return try await fetchData(from: finalURL.absoluteString)
    }
    
    // Fetch team roster using async/await
    func fetchRoster(team: String, year: Int = 2024) async throws -> [Player] {
        let rosterPath = "/college-football/roster"
        let queryItems = [
            URLQueryItem(name: "teamId", value: team),
            URLQueryItem(name: "year", value: String(year))
        ]
        
        var urlComponents = URLComponents(string: baseURL + rosterPath)
        urlComponents?.queryItems = queryItems
        
        guard let finalURL = urlComponents?.url else {
            throw URLError(.badURL)
        }
        
        return try await fetchData(from: finalURL.absoluteString)
    }
    
    // Fetch weather for a given week and year using async/await
    func fetchGameWeather(year: Int, week: Int) async throws -> [GameWeather] {
        let weatherPath = "/games/weather"
        let queryItems = [
            URLQueryItem(name: "year", value: String(year)),
            URLQueryItem(name: "week", value: String(week))
        ]
        
        var urlComponents = URLComponents(string: linesBaseURL + weatherPath)
        urlComponents?.queryItems = queryItems
        
        guard let finalURL = urlComponents?.url else {
            throw URLError(.badURL)
        }
        
        return try await fetchData(from: finalURL.absoluteString)
  
    }
   
    // Function to fetch player game stats
    func fetchPlayerGameStats(gameId: Int, year: Int, week: Int, seasonType: String, team: String, category: String? = nil) async throws -> [PlayerGame] {
        let playerGameStatsPath = "/games/players"
        var queryItems = [
            URLQueryItem(name: "gameId", value: String(gameId)),
            URLQueryItem(name: "year", value: String(year)),
            URLQueryItem(name: "week", value: String(week)),
            URLQueryItem(name: "seasonType", value: seasonType),
            URLQueryItem(name: "team", value: team)
        ]
        
        // Add category if provided
        if let category = category {
            queryItems.append(URLQueryItem(name: "category", value: category))
        }
        
        var urlComponents = URLComponents(string: linesBaseURL + playerGameStatsPath)
        urlComponents?.queryItems = queryItems
        
        guard let finalURL = urlComponents?.url else {
            throw URLError(.badURL)
        }
        
        return try await fetchData(from: finalURL.absoluteString)
    }

    
    // Fetch game lines using async/await
    func fetchGameLines(year: Int = 2023, seasonType: String = "regular", team: String? = nil) async throws -> [GameLine] {
        let linesPath = "/lines"
        var queryItems = [
            URLQueryItem(name: "year", value: String(year)),
            URLQueryItem(name: "seasonType", value: seasonType)
        ]
        if let team = team {
            queryItems.append(URLQueryItem(name: "team", value: team))
        }
        
        var urlComponents = URLComponents(string: linesBaseURL + linesPath)
        urlComponents?.queryItems = queryItems
        
        guard let finalURL = urlComponents?.url else {
            throw URLError(.badURL)
        }
        
        return try await fetchData(from: finalURL.absoluteString)
    }
}





