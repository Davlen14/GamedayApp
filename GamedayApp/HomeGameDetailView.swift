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
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            // Enlarged Scoreboard Section
            ZStack {
                RoundedRectangle(cornerRadius: 15)
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
                    .frame(height: 200) // Larger height to match the reference image
                    .padding(.horizontal)
                
                HStack {
                    // Home Team Section
                    teamInfoView(teamID: game.homeTeamID, score: game.homePoints ?? 0)
                    
                    Spacer()
                    
                    // Game Status and Field Progress
                    VStack(spacing: 8) {
                        Text(game.clock ?? "Time N/A")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        Text("Quarter \(game.period ?? 1)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        
                        HStack {
                            Text("1st & 10")
                                .font(.system(size: 14))
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            
                            Text("at \(game.possession ?? "N/A")")
                                .font(.system(size: 14))
                                .foregroundColor(.blue)
                        }
                        
                        // Field Progress Indicator
                        FieldProgressView(ballPosition: 0.35, firstDownPosition: 0.65)
                            .frame(height: 70) // Slightly larger height for the field
                            .padding(.top, 8)
                    }
                    
                    Spacer()
                    
                    // Away Team Section
                    teamInfoView(teamID: game.awayTeamID, score: game.awayPoints ?? 0)
                }
                .padding(.horizontal)
            }
            .padding(.top, 16)
            
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
    }
    
    // Team Info Section
    private func teamInfoView(teamID: Int, score: Int) -> some View {
        VStack {
            if let teamLogo = logo(for: teamID) {
                AsyncImage(url: URL(string: teamLogo)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 40, height: 40)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .cornerRadius(6)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            
            Text(teamAbbreviation(for: teamID))
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            Text("\(score)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .white : .black)
        }
    }
    
    // Quarter Scores Section
    private func quarterScoreView() -> some View {
        VStack(spacing: 10) {
            HStack {
                Spacer()
                Text("Q1")
                Spacer()
                Text("Q2")
                Spacer()
                Text("Q3")
                Spacer()
                Text("Q4")
                Spacer()
            }
            .font(.headline)
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .padding(.horizontal)
            
            HStack {
                // Home Team Quarters
                quarterScores(for: game.homePoints)
                Spacer()
                // Away Team Quarters
                quarterScores(for: game.awayPoints)
            }
            .font(.title3)
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    private func quarterScores(for points: Int?) -> some View {
        Text("\(points ?? 0)") // Placeholder for quarter score logic
            .foregroundColor(points == 0 ? .red : .blue)
    }
    
    // Field Progress View with more clarity for the field
    struct FieldProgressView: View {
        var ballPosition: Double // Normalized ball position (0.0 to 1.0)
        var firstDownPosition: Double // Normalized first down position (0.0 to 1.0)
        
        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    // Background field with alternating zones
                    HStack(spacing: 0) {
                        ForEach(0..<10) { i in
                            Rectangle()
                                .fill(Color.clear) // Clear background for zones
                                .frame(width: geometry.size.width / 10)
                        }
                    }
                    
                    // Yardlines in light gray
                    HStack {
                        ForEach(0..<6) { i in
                            Text("\(i * 20)")
                                .foregroundColor(Color.gray.opacity(0.6)) // Light gray yard markers
                                .frame(width: geometry.size.width / 6)
                        }
                    }
                    
                    // First Down Marker (yellow)
                    Capsule()
                        .fill(Color.yellow)
                        .frame(width: 4, height: 50)
                        .position(x: geometry.size.width * firstDownPosition, y: geometry.size.height / 2)
                    
                    // Ball Progress Marker (red)
                    Capsule()
                        .fill(Color.red)
                        .frame(width: geometry.size.width * ballPosition, height: 8)
                        .position(x: geometry.size.width * ballPosition, y: geometry.size.height / 2)
                }
            }
        }
    }
    
    // Helper functions for team logo and abbreviation
    private func logo(for teamID: Int) -> String? {
        guard let team = teams.first(where: { $0.id == teamID }) else {
            return nil
        }
        guard let logo = team.logos?.first else {
            return nil
        }
        return logo.replacingOccurrences(of: "http://", with: "https://")
    }
    
    private func teamAbbreviation(for teamID: Int) -> String {
        if let team = teams.first(where: { $0.id == teamID }) {
            return team.abbreviation ?? team.school
        }
        return "Team"
    }
}










