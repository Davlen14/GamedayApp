//
//  HomeGameDetailView.swift
//  GamedayApp
//
//  Created by Davlen Swain on 9/4/24.
//

import SwiftUI

struct HomeGameDetailView: View {
    var game: Game
    var teams: [Team]
    
    @State private var playByPlayData: PlayByPlayData? = nil
    @State private var timer: Timer?
    @State private var isFetchingData: Bool = false // To avoid multiple requests
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            // Gamecast Navigation Links
            HStack {
                Spacer()
                Text("Gamecast")
                    .font(.custom("Exo2-Italic", size: 16))
                    .foregroundColor(Color.gamedayRed)
                Spacer()
                Text("Box Score")
                    .font(.custom("Exo2-Italic", size: 16))
                    .foregroundColor(Color.gamedayRed)
                Spacer()
                
                // Add NavigationLink for Play-by-Play
                NavigationLink(destination: PlayByPlayView(game: game, teams: teams)) {
                    Text("Play-by-Play")
                        .font(.custom("Exo2-Italic", size: 16))
                        .foregroundColor(Color.gamedayRed)
                }
                
                Spacer()
                Text("Team Stats")
                    .font(.custom("Exo2-Italic", size: 16))
                    .foregroundColor(Color.gamedayRed)
                Spacer()
            }
            .font(.headline)
            .padding(.vertical, 10)
            
            // Scoreboard Section
            ZStack {
                RoundedRectangle(cornerRadius: 0)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(.systemGray6).opacity(0.8),
                                Color(.systemGray4).opacity(0.5)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 180)
                    .padding(.horizontal)
                
                HStack {
                    teamInfoView(teamID: game.homeTeamID, score: latestHomeScore())
                    Spacer()
                    gameStatusView()
                    Spacer()
                    teamInfoView(teamID: game.awayTeamID, score: latestAwayScore())
                }
                .padding(.horizontal)
            }
            .padding(.top, 16)
            
            // Field Progress Section
            fieldProgressSection()
                .padding(.horizontal)
                .padding(.bottom, 16)
            
            // Quarter by Quarter Score Section
            quarterScoreView()
            
            Spacer()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(UIColor.systemGray6), Color(UIColor.systemGray5)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
        )
        .navigationBarTitle("Game Details", displayMode: .inline)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    // Timer to fetch play-by-play data every 0.9 seconds
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.9, repeats: true) { _ in
            Task {
                await loadPlayByPlayData()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // Load play-by-play data asynchronously
    private func loadPlayByPlayData() async {
        guard !isFetchingData else { return } // Prevent multiple API requests
        isFetchingData = true
        do {
            let fetchedData = try await TeamService.shared.fetchPlayByPlay(gameId: game.id)
            playByPlayData = fetchedData
        } catch {
            print("Error fetching play-by-play data: \(error)")
        }
        isFetchingData = false
    }

    // Team Info Section
    private func teamInfoView(teamID: Int, score: Int) -> some View {
        VStack {
            if let teamLogo = logo(for: teamID) {
                AsyncImage(url: URL(string: teamLogo)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 50, height: 50)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .cornerRadius(6)
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
            
            Text(teamAbbreviation(for: teamID))
                .font(.custom("Exo2-Italic", size: 18))
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            Text("\(score)")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .white : .black)
        }
    }
    
    // Game Status Section
    private func gameStatusView() -> some View {
        VStack(spacing: 10) {
            Text(playByPlayData?.clock ?? game.clock ?? "Time N/A")
                .font(.custom("Exo2-Italic", size: 14))
                .foregroundColor(.gray)
            
            Text("Quarter \(playByPlayData?.period ?? game.period ?? 1)")
                .font(.custom("Exo2-Italic", size: 18))
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            HStack {
                Text("\(playByPlayData?.down ?? 1) & \(playByPlayData?.distance ?? 10)")
                    .font(.custom("Exo2-Italic", size: 14))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Text("at \(playByPlayData?.possession ?? game.possession ?? "N/A")")
                    .font(.custom("Exo2-Italic", size: 14))
                    .foregroundColor(.blue)
            }
        }
    }
    
    // Field Progress Section with live ball and first-down markers
    private func fieldProgressSection() -> some View {
        VStack {
            ZStack {
                Rectangle()
                    .stroke(Color.gray, lineWidth: 2)
                    .background(Color.green.opacity(0.2))
                    .frame(height: 120)
                
                // Calculate ball and first down position based on live data
                let ballPosition = calculateBallPosition()
                let firstDownPosition = calculateFirstDownPosition()
                
                // Determine the possession team based on the playByPlayData possession info
                let possessionTeamID = determinePossessionTeamID()
                
                FieldProgressView(
                    ballPosition: ballPosition,
                    firstDownPosition: firstDownPosition,
                    homeTeamColor: teamColor(for: game.homeTeamID),
                    awayTeamColor: teamColor(for: game.awayTeamID),
                    possessionTeamID: possessionTeamID, // Now dynamically set based on possession data
                    teams: teams
                )
                .frame(height: 100)
            }
            
            // Last Play Description
            if let lastPlay = playByPlayData?.drives.last?.plays.last?.playText {
                Text("Last Play: \(lastPlay)")
                    .font(.system(size: 14))
                    .padding(.top, 8)
            }
        }
    }

    // Helper function to determine which team has possession based on playByPlayData
    private func determinePossessionTeamID() -> Int {
        guard let possession = playByPlayData?.possession else {
            return game.homeTeamID // Default to home team if possession not available
        }

        // Map possession data to team IDs
        if let team = teams.first(where: { $0.abbreviation == possession || $0.school == possession }) {
            return team.id
        }
        
        return game.homeTeamID // Default to home team if possession cannot be mapped
    }


    private func calculateBallPosition() -> Double {
        guard let yardsToGoal = playByPlayData?.yardsToGoal else { return 0.5 }
        return 1.0 - (Double(yardsToGoal) / 100.0) // Convert to a percentage of the field
    }

    private func calculateFirstDownPosition() -> Double {
        guard let yardsToGoal = playByPlayData?.yardsToGoal, let distance = playByPlayData?.distance else { return 0.5 }
        return 1.0 - (Double(yardsToGoal - distance) / 100.0)
    }
    
    private func quarterScoreView() -> some View {
        VStack(spacing: 10) {
            VStack(spacing: 10) {
                // Header with quarters
                HStack {
                    Text("") // Placeholder for team names on the left
                        .frame(width: 50, alignment: .leading) // Adjust the frame to align properly
                    Spacer()
                    Text("Q1")
                    Spacer()
                    Text("Q2")
                    Spacer()
                    Text("Q3")
                    Spacer()
                    Text("Q4")
                    Spacer()
                    Text("T") // Total column
                }
                .font(.custom("Exo2-Italic", size: 16))
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .padding(.horizontal)

                // Home Team Row
                HStack {
                    Text(teamAbbreviation(for: game.homeTeamID)) // Home team abbreviation
                        .frame(width: 50, alignment: .leading) // Ensure the width matches the header
                    Spacer()

                    ForEach(0..<4) { quarter in
                        Text("\(quarterScore(for: game.homeTeamID, quarter: quarter))") // Display quarter score or 0 if unavailable
                        Spacer()
                    }

                    Text("\(latestHomeScore())") // Total score for the home team
                }
                .font(.custom("Exo2-Italic", size: 16))
                .foregroundColor(colorScheme == .dark ? .white : .red)
                .padding(.horizontal)

                // Away Team Row
                HStack {
                    Text(teamAbbreviation(for: game.awayTeamID)) // Away team abbreviation
                        .frame(width: 50, alignment: .leading) // Ensure the width matches the header
                    Spacer()

                    ForEach(0..<4) { quarter in
                        Text("\(quarterScore(for: game.awayTeamID, quarter: quarter))") // Display quarter score or 0 if unavailable
                        Spacer()
                    }

                    Text("\(latestAwayScore())") // Total score for the away team
                }
                .font(.custom("Exo2-Italic", size: 16))
                .foregroundColor(colorScheme == .dark ? .white : .blue)
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
        }
    }

    // Helper functions for team logo and abbreviation
    private func logo(for teamID: Int) -> String? {
        guard let team = teams.first(where: { $0.id == teamID }) else { return nil }
        return team.logos?.first?.replacingOccurrences(of: "http://", with: "https://")
    }
    
    private func teamAbbreviation(for teamID: Int) -> String {
        if let team = teams.first(where: { $0.id == teamID }) {
            return team.abbreviation ?? team.school
        }
        return "Team"
    }
    
    // Helper function to get quarter score
    private func quarterScore(for teamID: Int, quarter: Int) -> Int {
        if let playByPlayData = playByPlayData,
           let team = playByPlayData.teams.first(where: { $0.teamId == teamID }),
           let lineScores = team.lineScores, quarter < lineScores.count {
            return lineScores[quarter]
        }
        return 0 // Return 0 if no data available for the quarter
    }

    // Get latest home score
    private func latestHomeScore() -> Int {
        if let playByPlayData = playByPlayData,
           let homeTeam = playByPlayData.teams.first(where: { $0.teamId == game.homeTeamID }) {
            return homeTeam.points
        }
        return game.homePoints ?? 0
    }

    // Get latest away score
    private func latestAwayScore() -> Int {
        if let playByPlayData = playByPlayData,
           let awayTeam = playByPlayData.teams.first(where: { $0.teamId == game.awayTeamID }) {
            return awayTeam.points
        }
        return game.awayPoints ?? 0
    }

    // Helper function to get team color
    private func teamColor(for teamID: Int) -> Color {
        if let team = teams.first(where: { $0.id == teamID }) {
            return Color(team.color ?? "gray")
        }
        return Color.gray
    }
}

struct FieldProgressView: View {
    var ballPosition: Double
    var firstDownPosition: Double
    var homeTeamColor: Color
    var awayTeamColor: Color
    var possessionTeamID: Int
    var teams: [Team] // Add teams to retrieve logos

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background with alternating zones
                HStack(spacing: 0) {
                    // Left Endzone (light gray)
                    Rectangle()
                        .fill(Color.gray.opacity(0.3)) // Light gray for endzone
                        .frame(width: geometry.size.width / 12, height: geometry.size.height)
                    
                    // Yard Lines with alternating colors
                    ForEach(1..<10) { i in
                        Rectangle()
                            .fill(i % 2 == 0 ? Color.green.opacity(0.1) : Color.clear) // Alternating pattern after endzones
                            .frame(width: geometry.size.width / 12)
                    }
                    
                    // Right Endzone (light gray)
                    Rectangle()
                        .fill(Color.gray.opacity(0.3)) // Light gray for endzone
                        .frame(width: geometry.size.width / 12, height: geometry.size.height)
                }
                
                // Yard lines and team-colored endzones
                HStack(spacing: 0) {
                    // Left Endzone (Home Team Color)
                    Rectangle()
                        .fill(homeTeamColor)
                        .frame(width: geometry.size.width / 12, height: geometry.size.height)
                    
                    // Yard Lines
                    ForEach(1..<10) { i in
                        VStack {
                            Spacer()
                            Text(yardLineText(for: i))
                                .font(.system(size: 10))
                                .foregroundColor(Color.gray.opacity(0.8))
                                .padding(.bottom, 4)
                        }
                        .frame(width: geometry.size.width / 12)
                    }
                    
                    // Right Endzone (Away Team Color)
                    Rectangle()
                        .fill(awayTeamColor)
                        .frame(width: geometry.size.width / 12, height: geometry.size.height)
                }
                .frame(maxHeight: .infinity, alignment: .bottom)

                // Team Logo at Ball Position
                if let possessionLogo = logo(for: possessionTeamID) {
                    AsyncImage(url: URL(string: possessionLogo)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 30, height: 30)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .position(x: geometry.size.width * ballPosition, y: geometry.size.height / 2)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .position(x: geometry.size.width * ballPosition, y: geometry.size.height / 2)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                // First Down Marker (yellow)
                Capsule()
                    .fill(Color.yellow)
                    .frame(width: 1, height: 100)  // Slimmer first down marker
                    .position(x: geometry.size.width * firstDownPosition, y: geometry.size.height / 2)
                
                // Ball Progress Marker (slimmer red)
                Capsule()
                    .fill(Color.red)
                    .frame(width: 2, height: 10) // Slimmer ball progress line
                    .position(x: geometry.size.width * ballPosition, y: geometry.size.height / 2)
            }
            .padding(.horizontal, 5)
        }
    }

    private func yardLineText(for index: Int) -> String {
        switch index {
        case 1: return "10"
        case 2: return "20"
        case 3: return "30"
        case 4: return "40"
        case 5: return "50"
        case 6: return "40"
        case 7: return "30"
        case 8: return "20"
        case 9: return "10"
        default: return ""
        }
    }

    private func logo(for teamID: Int) -> String? {
        guard let team = teams.first(where: { $0.id == teamID }) else { return nil }
        return team.logos?.first?.replacingOccurrences(of: "http://", with: "https://")
    }
}















