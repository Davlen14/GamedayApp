import SwiftUI

struct TeamsView: View {
    @State private var teams: [Team] = []
    @State private var ratings: [TeamRating] = []
    @State private var errorMessage: String?
    @State private var searchText: String = ""

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

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                topBar
                searchBar
                content
                Spacer()
            }
            .background(Color(UIColor.systemBackground))
            .onAppear {
                Task {
                    await fetchTeams()
                    await fetchRatings()
                }
            }
        }
    }

    private var topBar: some View {
        ZStack {
            LinearGradient(gradient: Gradient(stops: [
                .init(color: Color.gray, location: 0.0),
                .init(color: Color.gamedayRed, location: 0.25),
                .init(color: Color.gamedayRed, location: 1.0)
            ]), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.top)
            .frame(height: 100)

            Text("Teams and Rankings")
                .font(.custom("Exo2-Italic", size: 34))
                .foregroundColor(.white)
                .bold()
                .padding(.top, 20)
        }
    }

    private var searchBar: some View {
        HStack {
            TextField("Search teams or conferences", text: $searchText)
                .padding(7)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 10)
        }
        .padding(.top)
    }

    private var content: some View {
        Group {
            if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .font(.custom("Exo2-Italic", size: 16))
                    .foregroundColor(.red)
                    .padding()
            } else {
                List {
                    ForEach(filteredConferences, id: \.self) { conference in
                        conferenceSection(for: conference)
                    }
                }
            }
        }
    }

    private var filteredConferences: [String] {
        if searchText.isEmpty {
            return conferenceLogos.keys.sorted()
        } else {
            let filteredTeams = teams.filter { $0.school.lowercased().contains(searchText.lowercased()) }
            let filteredConferences = conferenceLogos.keys.filter { $0.lowercased().contains(searchText.lowercased()) }
            let filteredTeamConferences = filteredTeams.compactMap { $0.conference }

            return Set(filteredConferences + filteredTeamConferences).sorted()
        }
    }

    private func conferenceSection(for conference: String) -> some View {
        Section(header: conferenceHeader(for: conference)) {
            ForEach(filteredTeams(for: conference)) { team in
                NavigationLink(destination: TeamDetailView(team: team)) {
                    teamRow(for: team)
                }
            }
        }
    }

    private func conferenceHeader(for conference: String) -> some View {
        VStack {
            if let logoName = conferenceLogos[conference] {
                Image(logoName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            }
        }
        .padding(.vertical, 5)
    }

    private func filteredTeams(for conference: String) -> [Team] {
        if searchText.isEmpty {
            return teams.filter { $0.conference == conference }
        } else {
            return teams.filter { $0.conference == conference && $0.school.lowercased().contains(searchText.lowercased()) }
        }
    }

    private func teamRow(for team: Team) -> some View {
        HStack {
            teamLogo(for: team)
            teamDetails(for: team)
                .padding(.leading, 8)
        }
        .padding(.vertical, 8)
    }

    private func teamLogo(for team: Team) -> some View {
        if let logoURL = team.logos?.first {
            let secureURL = logoURL.replacingOccurrences(of: "http://", with: "https://")
            if let url = URL(string: secureURL) {
                return AnyView(AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 35, height: 35)
                    case .success(let image):
                        image.resizable()
                             .scaledToFit()
                             .frame(width: 35, height: 35)
                    case .failure:
                        fallbackLogo
                    @unknown default:
                        fallbackLogo
                    }
                })
            }
        }
        return AnyView(fallbackLogo)
    }

    private var fallbackLogo: some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .frame(width: 35, height: 35)
            .foregroundColor(.gray)
    }

    private func teamDetails(for team: Team) -> some View {
        let teamRating = ratings.first { $0.team.lowercased() == team.school.lowercased() }
        
        return VStack(alignment: .leading) {
            Text(team.school)
                .font(.custom("Exo2-Italic", size: 18))
                .foregroundColor(.primary)
            
            HStack {
                Text("Overall: \(teamRating?.overallRanking.map { String($0) } ?? "N/A")")
                    .font(.custom("Exo2-Italic", size: 14))
                    .foregroundColor(.gray)

                Text("Offense: \(teamRating?.offenseRanking.map { String($0) } ?? "N/A")")
                    .font(.custom("Exo2-Italic", size: 14))
                    .foregroundColor(.gray)
                    .padding(.leading, 8)

                Text("Defense: \(teamRating?.defenseRanking.map { String($0) } ?? "N/A")")
                    .font(.custom("Exo2-Italic", size: 14))
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
            }
        }
    }

    private func fetchTeams() async {
        do {
            let fetchedTeams = try await TeamService.shared.fetchTeams()
            DispatchQueue.main.async {
                self.teams = fetchedTeams
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func fetchRatings() async {
        do {
            let fetchedRatings = try await TeamService.shared.fetchRatings(year: 2023)
            DispatchQueue.main.async {
                self.ratings = fetchedRatings
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}

struct TeamsView_Previews: PreviewProvider {
    static var previews: some View {
        TeamsView()
    }
}






















