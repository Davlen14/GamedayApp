import SwiftUI

struct LinesView: View {
    @State private var gameLines: [GameLine] = []
    @State private var errorMessage: String?
    @State private var teams: [Team] = []
    @State private var currentWeek: Int = 1
    @State private var searchText: String = ""
    private let maxWeek = 15 // Assuming 15 weeks in the season
    private let validProviders = ["ESPN Bet", "DraftKings", "Bovada", "Caesars Sportsbook"] // Valid providers

    var body: some View {
        NavigationView {
            VStack {
                // Top Bar with Title and Week Picker
                HStack {
                    Image(systemName: "football.fill")
                        .foregroundColor(.red)
                    Text("Betting Lines")
                        .font(.custom("Exo2-Italic", size: 24))
                        .bold()
                    Spacer()
                    Button(action: {
                        // Open Filter & Sort modal
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)

                // Search Box
                HStack {
                    TextField("Search for teams or games", text: $searchText)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .font(.custom("Exo2-Italic", size: 16))
                }
                .padding(.horizontal)

                // Week Selection
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(1...maxWeek, id: \.self) { week in
                            Button(action: {
                                currentWeek = week
                            }) {
                                Text("Week \(week)")
                                    .padding(.horizontal)
                                    .padding(.vertical, 10)
                                    .background(currentWeek == week ? Color.red : Color.white)
                                    .foregroundColor(currentWeek == week ? Color.white : Color.red)
                                    .cornerRadius(10)
                                    .font(.custom("Exo2-Italic", size: 16))
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Game Lines Content
                if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                        .font(.custom("Exo2-Italic", size: 16))
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(filteredGameLines()) { gameLine in
                                LineCardView(gameLine: gameLine, teams: teams)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .onAppear {
                Task {
                    await fetchGameLines()
                    await fetchTeams()
                }
            }
            .navigationBarHidden(true)
        }
    }

    private func fetchGameLines() async {
        do {
            let lines = try await TeamService.shared.fetchGameLines(year: 2023)
            DispatchQueue.main.async {
                self.gameLines = lines
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func fetchTeams() async {
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

    private func filteredGameLines() -> [GameLine] {
        gameLines.filter {
            $0.week == currentWeek &&
            $0.lines?.contains(where: { validProviders.contains($0.provider ?? "") }) == true &&
            (searchText.isEmpty || $0.homeTeam?.contains(searchText) == true || $0.awayTeam?.contains(searchText) == true)
        }
    }
}

struct LineCardView: View {
    var gameLine: GameLine
    var teams: [Team]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                // Home Team Logo and Info
                if let homeTeam = teams.first(where: { $0.school == gameLine.homeTeam }),
                   let homeLogo = homeTeam.logos?.first,
                   let homeColor = homeTeam.color,
                   let homeColorHex = Color(hex: homeColor) {
                    VStack {
                        AsyncImage(url: URL(string: homeLogo.replacingOccurrences(of: "http://", with: "https://"))) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 30, height: 30)
                            case .success(let image):
                                image.resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .cornerRadius(5)
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        Text("\(gameLine.homeScore ?? 0)")
                            .font(.custom("Exo2-Italic", size: 20))
                            .foregroundColor(.white)
                            .bold()
                    }
                    .padding()
                    .background(homeColorHex)
                    .cornerRadius(10)
                }

                Spacer()

                // VS
                Text("vs")
                    .font(.custom("Exo2-Italic", size: 16))
                    .foregroundColor(.gray)

                Spacer()

                // Away Team Logo and Info
                if let awayTeam = teams.first(where: { $0.school == gameLine.awayTeam }),
                   let awayLogo = awayTeam.logos?.first,
                   let awayColor = awayTeam.color,
                   let awayColorHex = Color(hex: awayColor) {
                    VStack {
                        AsyncImage(url: URL(string: awayLogo.replacingOccurrences(of: "http://", with: "https://"))) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 30, height: 30)
                            case .success(let image):
                                image.resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .cornerRadius(5)
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        Text("\(gameLine.awayScore ?? 0)")
                            .font(.custom("Exo2-Italic", size: 20))
                            .foregroundColor(.white)
                            .bold()
                    }
                    .padding()
                    .background(awayColorHex)
                    .cornerRadius(10)
                }
            }

            Spacer()

            // Game Information
            VStack(alignment: .leading, spacing: 5) {
                Text(formattedDate(from: gameLine.startDate))
                    .font(.custom("Exo2-Italic", size: 14))
                    .foregroundColor(.gray)
                Text("\(gameLine.homeTeam ?? "Unknown Team") vs \(gameLine.awayTeam ?? "Unknown Team")")
                    .font(.custom("Exo2-Italic", size: 18))
            }

            // Betting Lines
            ForEach(filteredLines()) { line in
                HStack {
                    // Display Sportsbook Image
                    Image(sportsbookImageName(for: line.provider))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 50) // Larger image size
                        .cornerRadius(4) // Slightly rounded corners

                    Text(line.provider ?? "Unknown")
                        .font(.custom("Exo2-Italic", size: 14)) // Larger text size
                        .foregroundColor(.gray)
                    Spacer()
                    Text("Spread: \(line.spread ?? 0.0, specifier: "%.1f")")
                        .font(.custom("Exo2-Italic", size: 14)) // Larger text size
                    Spacer()
                    Text("O/U: \(line.overUnder ?? 0.0, specifier: "%.1f")")
                        .font(.custom("Exo2-Italic", size: 14)) // Larger text size
                }
                .padding(.vertical, 4)
                .background(Color(.systemGray5))
                .cornerRadius(8)
                .frame(maxWidth: .infinity, minHeight: 20, maxHeight: 20) // Fixed frame size
                .clipped() // Clip content that overflows
            }
            .padding()
            .background(Color(.systemGray5))
            .cornerRadius(10)
            .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 2)
        }
    }

    private func formattedDate(from dateString: String?) -> String {
        guard let dateString = dateString, let date = ISO8601DateFormatter().date(from: dateString) else {
            return "Date Unavailable"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone.current
        
        return formatter.string(from: date)
    }

    private func sportsbookImageName(for provider: String?) -> String {
        switch provider {
        case "DraftKings":
            return "draftkings"
        case "ESPN Bet":
            return "espnbet"
        case "Bovada":
            return "bovada"
        case "Caesars Sportsbook":
            return "caesars"
        default:
            return "placeholder" // Use a default image if the provider is unknown
        }
    }
    

    private func filteredLines() -> [GameLine.Line] {
        return gameLine.lines?.filter { line in
            ["ESPN Bet", "DraftKings", "Bovada", "Caesars Sportsbook"].contains(line.provider ?? "")
        } ?? []
    }
}



