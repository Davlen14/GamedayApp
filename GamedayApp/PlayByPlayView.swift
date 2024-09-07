//
//  PlayByPlayView.swift
//  GamedayApp
//
//  Created by Davlen Swain on 9/6/24.
//

import SwiftUI

import SwiftUI

struct PlayByPlayView: View {
    var game: Game
    var teams: [Team]
    
    // Optional playByPlayData
    @State private var playByPlayData: PlayByPlayData? = nil
    
    @State private var drives: [Drive] = []
    @Environment(\.colorScheme) var colorScheme // Detect system color scheme
    
    var body: some View {
        VStack {
            // Game Title
            Text("Play-by-Play")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 16)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            // Team Scores and Possession
            HStack {
                VStack(alignment: .center, spacing: 8) {
                    teamLogoView(teamID: game.homeTeamID)
                    Text(teamAbbreviation(for: game.homeTeamID))
                        .font(.title2)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    // Fetch home score from playByPlayData or fallback to game data
                    Text("\(latestHomeScore())")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                Spacer()
                VStack {
                    // Safely unwrap playByPlayData and game data
                    Text("Period: \(playByPlayData?.period ?? game.period ?? 1)")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Text("Clock: \(playByPlayData?.clock ?? game.clock ?? "00:00")")
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                    // Display possession if available
                    if let possession = playByPlayData?.possession {
                        Text("Possession: \(possession)")
                            .fontWeight(.semibold)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                }
                Spacer()
                VStack(alignment: .center, spacing: 8) {
                    teamLogoView(teamID: game.awayTeamID)
                    Text(teamAbbreviation(for: game.awayTeamID))
                        .font(.title2)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    // Fetch away score from playByPlayData or fallback to game data
                    Text("\(latestAwayScore())")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            // Drive Summary Section
            ScrollView {
                if drives.isEmpty {
                    Text("No plays available yet. Stay tuned!")
                        .padding(.top, 20)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                } else {
                    VStack(spacing: 16) {
                        ForEach(drives, id: \.id) { drive in
                            DriveView(drive: drive, teams: teams)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(Color(colorScheme == .dark ? .black : .systemGray6).edgesIgnoringSafeArea(.all)) // Background adapts to dark mode
        .onAppear {
            Task {
                await loadPlayByPlayData()
            }
        }
    }
    
    // Load Play-By-Play data
    private func loadPlayByPlayData() async {
        do {
            // Fetch the play-by-play data for the game
            let fetchedData = try await TeamService.shared.fetchPlayByPlay(gameId: game.id)
            playByPlayData = fetchedData
            drives = fetchedData.drives
        } catch {
            print("Error fetching play-by-play data: \(error)")
        }
    }
    
    // Fetch the latest home score from play-by-play data or fallback to game data
    private func latestHomeScore() -> Int {
        if let playByPlayData = playByPlayData {
            // Fetch the latest play's home score if available
            return playByPlayData.drives.last?.plays.last?.homeScore ?? game.homePoints ?? 0
        } else {
            return game.homePoints ?? 0
        }
    }
    
    // Fetch the latest away score from play-by-play data or fallback to game data
    private func latestAwayScore() -> Int {
        if let playByPlayData = playByPlayData {
            // Fetch the latest play's away score if available
            return playByPlayData.drives.last?.plays.last?.awayScore ?? game.awayPoints ?? 0
        } else {
            return game.awayPoints ?? 0
        }
    }

    // Helper functions for team logo and abbreviation
    private func teamLogoView(teamID: Int) -> some View {
        if let logo = logo(for: teamID) {
            return AnyView(
                AsyncImage(url: URL(string: logo)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 50, height: 50)
                    case .success(let image):
                        image.resizable()
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
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    private func teamAbbreviation(for teamID: Int) -> String {
        if let team = teams.first(where: { $0.id == teamID }) {
            return team.abbreviation ?? team.school
        }
        return "Team"
    }
    
    private func logo(for teamID: Int) -> String? {
        guard let team = teams.first(where: { $0.id == teamID }) else { return nil }
        return team.logos?.first?.replacingOccurrences(of: "http://", with: "https://")
    }
}

struct DriveView: View {
    var drive: Drive
    var teams: [Team]
    @Environment(\.colorScheme) var colorScheme // Detect system color scheme for each view

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Drive by \(teamName(for: drive.offenseId))")
                    .font(.custom("Exo2-Italic", size: 16))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                Spacer()
                Text("Plays: \(drive.playCount), Yards: \(drive.yards)")
                    .font(.custom("Exo2-Italic", size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 8)
            
            ForEach(drive.plays, id: \.id) { play in
                PlayView(play: play)
                    .padding(.leading, 16)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(colorScheme == .dark ? Color(.systemGray5) : Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
    
    private func teamName(for teamID: Int) -> String {
        if let team = teams.first(where: { $0.id == teamID }) {
            return team.school
        }
        return "Unknown Team"
    }
}

struct PlayView: View {
    var play: Play
    @Environment(\.colorScheme) var colorScheme // Detect system color scheme

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                // Safely unwrap play.clock
                Text("\(play.clock ?? "00:00") Q\(play.period)")
                    .font(.custom("Exo2-Italic", size: 14))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                Spacer()
                // Safely unwrap play.playType
                Text(play.playType ?? "Unknown Play")
                    .font(.custom("Exo2-Italic", size: 14))
                    .foregroundColor(.blue)
            }
            // Safely unwrap playText
            Text(play.playText ?? "No play description available")
                .font(.footnote)
                .foregroundColor(colorScheme == .dark ? .gray : .black)
        }
        .padding(.vertical, 8)
    }
}





