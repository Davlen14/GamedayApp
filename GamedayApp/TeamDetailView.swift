import SwiftUI

struct TeamDetailView: View {
    var team: Team
    @State private var selectedCategory = "Rankings"
    @State private var selectedSortOption = "Name"
    @State private var ratings: [TeamRating] = []
    @State private var roster: [Player] = []
    @State private var errorMessage: String?

    let conferenceLogos: [String: String] = [
        "ACC": "ACC",
        "American Athletic": "American Athletic",
        "Big 12": "Big 12",
        "Big Ten": "Big Ten",
        "Conference USA": "Conference USA",
        "Mid-American": "Mid-American",
        "Mountain West": "Mountain West",
        "Pac-12": "Pac-12",
        "SEC": "SEC",
        "Sun Belt": "Sun Belt",
        "FBS Independents": "FBS Independents"
    ]

    let categories = ["Rankings", "Roster", "Statistics", "Schedule", "News"]
    let sortOptions = ["Name", "Position", "Height", "Year"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Team logo and conference logo
                HStack {
                    if let logoURL = team.logos?.first {
                        AsyncImage(url: URL(string: logoURL.replacingOccurrences(of: "http://", with: "https://"))) { phase in
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
                                    .clipShape(Circle())
                                    .foregroundColor(.gray)
                            @unknown default:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .foregroundColor(.gray)
                            }
                        }
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .foregroundColor(.gray)
                    }

                    if let conference = team.conference,
                       let logoName = conferenceLogos[conference] {
                        Image(logoName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .padding(.leading, 8)
                    }
                }

                // Team's school name as the main title
                Text(team.school)
                    .font(.largeTitle)
                    .padding(.top)

                // Team's mascot and conference
                if let mascot = team.mascot, let conference = team.conference {
                    Text("\(mascot) • \(conference)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // Segmented control for categories
                Picker("Select a category", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                // Category content based on selection
                Group {
                    switch selectedCategory {
                    case "Rankings":
                        rankingsSection
                    case "Roster":
                        rosterSection
                    case "Statistics":
                        Text("Statistics content here")
                    case "Schedule":
                        Text("Schedule content here")
                    case "News":
                        Text("News content here")
                    default:
                        Text("Select a category")
                    }
                }
                .padding()
            }
            .padding(.horizontal)
            .navigationTitle(team.school)
            .onAppear {
                Task {
                    await fetchTeamRatings()
                    await fetchTeamRoster()
                }
            }
        }
    }

    private var rankingsSection: some View {
        VStack(alignment: .leading) {
            Text("Rankings")
                .font(.headline)
                .padding(.bottom, 4)

            if let teamRating = ratings.first(where: { $0.team.lowercased() == team.school.lowercased() }) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Overall Rank: \(teamRating.overallRanking != nil ? "\(teamRating.overallRanking!)" : "N/A")")
                        .font(.custom("Exo2-Italic", size: 14))
                        .foregroundColor(.blue)

                    Text("Offense Rank: \(teamRating.offenseRanking != nil ? "\(teamRating.offenseRanking!)" : "N/A")")
                        .font(.custom("Exo2-Italic", size: 14))
                        .foregroundColor(.green)

                    Text("Defense Rank: \(teamRating.defenseRanking != nil ? "\(teamRating.defenseRanking!)" : "N/A")")
                        .font(.custom("Exo2-Italic", size: 14))
                        .foregroundColor(.red)
                }
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .font(.subheadline)
                    .foregroundColor(.red)
            } else {
                Text("Loading rankings...")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }

    private var rosterSection: some View {
        VStack(alignment: .leading) {
            Text("Roster")
                .font(.headline)
                .padding(.bottom, 4)

            // Sort picker
            Picker("Sort by", selection: $selectedSortOption) {
                ForEach(sortOptions, id: \.self) { option in
                    Text(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.bottom, 8)

            if roster.isEmpty {
                if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .font(.subheadline)
                        .foregroundColor(.red)
                } else {
                    Text("Loading roster...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            } else {
                // Sorting logic
                let sortedRoster = roster.sorted {
                    switch selectedSortOption {
                    case "Name":
                        return $0.lastName < $1.lastName
                    case "Position":
                        return ($0.position ?? "") < ($1.position ?? "")
                    case "Height":
                        return ($0.height ?? 0) < ($1.height ?? 0)
                    case "Year":
                        let year0 = $0.year ?? 0
                        let year1 = $1.year ?? 0
                        return year0 < year1
                    default:
                        return $0.lastName < $1.lastName
                    }
                }

                // Modern table-like view
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(sortedRoster) { player in
                        VStack(alignment: .leading) {
                            HStack {
                                // Display "N/A" if both firstName and lastName are nil or empty
                                Text("\((player.firstName.isEmpty && player.lastName.isEmpty) ? "N/A" : player.name)")
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                // Display "N/A" if position is nil
                                Text("\(player.position ?? "N/A")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                // Display "Height: N/A" if height is nil or not available
                                Text("Height: \(player.height != nil ? formatHeight(player.height) : "N/A")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                // Display "Year: N/A" if year is 0 or less
                                Text("Year: \(player.year != nil ? "\(player.year!)" : "N/A")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
            }
        }
    }

    // Function to convert height in inches to feet and inches in the format "X'Y"
    private func formatHeight(_ inches: Int?) -> String {
        guard let inches = inches else { return "N/A" }
        let feet = inches / 12
        let remainderInches = inches % 12
        return "\(feet)'\(remainderInches)"
    }

    private func fetchTeamRatings() async {
        do {
            let ratings = try await TeamService.shared.fetchRatings(year: 2023)
            self.ratings = ratings
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    private func fetchTeamRoster() async {
        do {
            let players = try await TeamService.shared.fetchRoster(team: team.school, year: 2024)
            self.roster = players
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}



struct TeamDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let exampleTeam = Team(id: 1, school: "Example School", mascot: "Eagles", conference: "Big Ten", logos: ["https://example.com/logo.png"])
        TeamDetailView(team: exampleTeam)
    }
}

