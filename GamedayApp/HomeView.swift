import SwiftUI

// Custom Color extension to create a darker shade
extension Color {
    func darker(by percentage: CGFloat = 30.0) -> Color {
        return self.adjustBrightness(by: -1 * abs(percentage))
    }

    private func adjustBrightness(by percentage: CGFloat) -> Color {
        let color = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        brightness += (percentage / 100)
        brightness = max(min(brightness, 1.0), 0.0)

        return Color(UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha))
    }
}

// FBS Conferences Set
let fbsConferences: Set<String> = [
    "ACC", "Big Ten", "Big 12", "Pac-12", "SEC",
    "American", "Conference USA", "MAC", "Mountain West", "Sun Belt", "Independent"
]

struct HomeView: View {
    @State private var games: [Game] = []
    @State private var gameMediaList: [GameMedia] = []
    @State private var errorMessage: String?
    @State private var currentWeek: Int = 2
    @State private var currentYear: Int = Calendar.current.component(.year, from: Date())
    @State private var teams: [Team] = []
    @State private var rankings: [RankingWeek] = []
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // Top Bar with Gradient Background and Gameday+ Section (Light Mode)
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [Color(red: 153/255, green: 0/255, blue: 0/255), Color(red: 255/255, green: 51/255, blue: 51/255).darker(by: 15)]), startPoint: .top, endPoint: .bottom)
                        .edgesIgnoringSafeArea(.top)
                        .frame(height: 114)
                    
                    HStack {
                        NavigationLink(destination: PollsView()) {
                            HStack(spacing: 4) {
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 15))
                                Text("Polls")
                                    .font(.custom("Exo2-Italic", size: 10))
                            }
                            .padding(8)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.8), lineWidth: 1)
                            )
                        }
                        
                        NavigationLink(destination: LinesView()) {
                            HStack(spacing: 4) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.system(size: 16))
                                Text("Lines")
                                    .font(.custom("Exo2-Italic", size: 12))
                            }
                            .padding(8)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.8), lineWidth: 1)
                            )
                        }
                        
                        Button(action: {
                            // Action for News
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "newspaper.fill")
                                    .font(.system(size: 13))
                                Text("News")
                                    .font(.custom("Exo2-Italic", size: 10))
                            }
                            .padding(8)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.8), lineWidth: 1)
                            )
                        }
                        
                        NavigationLink(destination: ChatView()) {
                            HStack(spacing: 4) {
                                Image(systemName: "message.fill")
                                    .font(.system(size: 16))
                                Text("Chat")
                                    .font(.custom("Exo2-Italic", size: 12))
                            }
                            .padding(8)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.8), lineWidth: 1)
                            )
                        }
                        
                        Spacer()
                        Text("View All")
                            .font(.custom("Exo2-Italic", size: 12))
                            .foregroundColor(.white)
                            .padding(.trailing)
                    }
                    .padding(.horizontal)
                    .padding(.top, 35)
                    .padding(.bottom, 5)
                }
                
                // Gameday+ and Login Section (Light Mode)
                VStack {
                    HStack {
                        Text("GameDay+")
                            .font(.custom("Exo2-Italic", size: 18))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.leading)
                        
                        Spacer()
                        
                        Button(action: {
                            // Action for Log in
                        }) {
                            Text("Log in")
                                .font(.custom("Exo2-Italic", size: 14))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.white)
                                .foregroundColor(Color(red: 153/255, green: 0/255, blue: 0/255))
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            // Action for Join
                        }) {
                            Text("Join")
                                .font(.custom("Exo2-Italic", size: 14))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.gray.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.trailing)
                    }
                    .padding(.vertical, 6)
                    .background(Color(red: 255/255, green: 51/255, blue: 51/255).opacity(1))
                    .offset(y: -10)
                    .zIndex(1)
                }
                
                // Slidable Games Section (Dark Mode Compatible)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(games) { game in
                            NavigationLink(
                                destination: HomeGameDetailView(game: game, teams: teams)
                            ) {
                                HomeGameCardView(game: game, teams: teams, gameMedia: gameMedia(for: game))
                                    .frame(width: 200, height: 100)
                                    .background(colorScheme == .dark ? Color.black : Color.white)
                                    .shadow(color: colorScheme == .dark ? Color.black.opacity(0.8) : Color.gray.opacity(0.2), radius: 5, x: 0, y: 2)
                                    .padding(.vertical, 10)
                            }
                        }
                    }
                    .padding(.horizontal, 0)
                }
                .background(colorScheme == .dark ? Color.black : Color.white)
                .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 2)
                .padding(.bottom, 20)
                
                // Rankings Section (Dark Mode Compatible)
                ScrollView {
                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            VStack {
                                Image("AP")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .padding(.bottom, 5)
                                Text("AP Top 25 Rankings")
                                    .font(.custom("Exo2-Italic", size: 26))
                                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.8) : .gray)
                                    .fontWeight(.bold)
                            }
                            Spacer()
                        }
                        .padding(.top, 10)
                        
                        VStack(spacing: 12) {
                            ForEach(rankings.first?.polls?.first(where: { $0.poll == "AP Top 25" })?.ranks?.prefix(25) ?? [], id: \.rank) { rank in
                                PollRowView(rank: rank, teams: teams)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .background(colorScheme == .dark ? Color.black : Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Latest News Section (Dark Mode Compatible)
                    VStack(alignment: .leading) {
                        Text("Latest News")
                            .font(.custom("Exo2-Italic", size: 24))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .padding(.horizontal)
                            .padding(.top, 20)
                            .padding(.bottom, 10)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                NewsCard(imageName: "quinn", title: "SEC Media Days", link: "https://glorycolorado.com/posts/deion-sanders-speaks-out-colorado-football-team-expectations-big-12-media-days")
                                NewsCard(imageName: "Ryan", title: "Ryan Day Hot Seat?", link: "https://www.on3.com/teams/texas-longhorns/news/sec-media-days-storylines-former-southwest-conference-rivals-get-to-welcome-texas-to-the-sec")
                                NewsCard(imageName: "Sanders", title: "Sanders speaks out", link: "https://www.elevenwarriors.com/ohio-state-football/2024/07/147841/ohio-state-quarterback-will-howard-feeling-so-much-more-comfortable-after-six-months-with-the-buckeyes")
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 10)
                    }
                    
                    // Top Stories Section (Dark Mode Compatible)
                    VStack(alignment: .leading) {
                        Text("Top Stories")
                            .font(.custom("Exo2-Italic", size: 24))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .padding(.horizontal)
                            .padding(.top, 20)
                            .padding(.bottom, 10)
                        
                        VStack(spacing: 20) {
                            StoryCard(imageName: "geo", number: 1, title: "Georgia Football: Recent Arrests and Updates", author: "Joe Flint and Isabella Simonetti", link: "https://www.onlineathens.com/story/sports/college/bulldogs-extra/2023/03/02/georgia-football-arrests-jalen-carter-jamon-dumas-johnson-kirby-smart-stetson-bennett-kenny-mcintosh/69961564007/")
                            StoryCard(imageName: "mich", number: 2, title: "Opinion: A Two-Quarterback System Could Make Michigan Very Dangerous in 2024", author: "Sports Illustrated", link: "https://www.si.com/college/michigan/football/opinion-a-two-quarterback-system-could-make-michigan-very-dangerous-in-2024")
                            StoryCard(imageName: "toledo", number: 3, title: "Briggs: Here's How Toledo and Bowling Green Could Be Promoted to the Big Leagues", author: "Kyle Mizokami", link: "https://www.toledoblade.com/sports/college/2024/05/01/briggs-here-s-how-toledo-and-bowling-green-could-be-promoted-to-the-big-leagues/stories/20240501106")
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
            }
            .background(colorScheme == .dark ? Color.black : Color.gamedayWhite)
            .edgesIgnoringSafeArea(.top)
            .onAppear {
                Task {
                    await fetchGames()
                    await fetchTeams()
                    await fetchRankings()
                    await fetchGameMedia()
                }
            }
            .onChange(of: currentWeek) { _, _ in Task { await fetchGames() } }
            .onChange(of: currentYear) { _, _ in Task { await fetchGames() } }
        }
    }

    // Fetch functions and utility methods stay the same
    private func fetchRankings() async {
        do {
            let rankings = try await TeamService.shared.fetchPolls(year: currentYear, seasonType: "regular")
            DispatchQueue.main.async {
                self.rankings = rankings.filter { $0.week == currentWeek }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func gameMedia(for game: Game) -> GameMedia? {
        return gameMediaList.first { $0.homeTeam == game.homeTeam && $0.awayTeam == game.awayTeam }
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
            let mediaList = try await TeamService.shared.fetchGameMedia(year: currentYear, week: currentWeek)
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
    
    
    struct HomeGameCardView: View {
        var game: Game
        var teams: [Team]
        var gameMedia: GameMedia?
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    // Home Team Logo and Name + Score
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
                        Text(teamAbbreviation(for: game.homeTeamID, isHomeTeam: true))
                            .font(.custom("Exo2-Italic", size: 14))
                            .foregroundColor(Color(.label))
                        
                        // Home Team Points Below the Name
                        Text("(\(game.homePoints ?? 0))")
                            .font(.custom("Exo2-Italic", size: 14))
                            .fontWeight(.bold)
                            .foregroundColor(game.homePoints ?? 0 > game.awayPoints ?? 0 ? .green : .black)
                    }
                    
                    Spacer()
                    
                    Text("vs")
                        .font(.custom("Exo2-Italic", size: 14))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    // Away Team Name + Score
                    VStack(alignment: .trailing) {
                        Text(teamAbbreviation(for: game.awayTeamID, isHomeTeam: false))
                            .font(.custom("Exo2-Italic", size: 14))
                            .foregroundColor(Color(.label))
                        
                        // Away Team Points Below the Name
                        Text("(\(game.awayPoints ?? 0))")
                            .font(.custom("Exo2-Italic", size: 14))
                            .fontWeight(.bold)
                            .foregroundColor(game.awayPoints ?? 0 > game.homePoints ?? 0 ? .green : .black)
                    }
                    
                    // Away Team Logo
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
                
                // Displaying only the network information
                if let gameMedia = gameMedia {
                    HStack {
                        Image(systemName: "tv")
                        Text("Network: \(gameMedia.outlet)")
                            .font(.custom("Exo2-Italic", size: 12))
                            .foregroundColor(.gray)
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
        
        func teamAbbreviation(for teamID: Int, isHomeTeam: Bool) -> String {
            if let team = teams.first(where: { $0.id == teamID }) {
                if let abbreviation = team.abbreviation, !abbreviation.isEmpty {
                    return abbreviation
                }
                return team.school
            }
            return isHomeTeam ? "Home" : "Away"
        }
    }
    
    struct PollRowView: View {
        var rank: Rank
        var teams: [Team]
        
        var body: some View {
            HStack {
                teamLogo(for: rank)
                VStack(alignment: .leading) {
                    Text("#\(rank.rank ?? 0) \(rank.school ?? "N/A")")
                        .font(.custom("Exo2-Italic", size: 18))
                    Text("\(rank.conference ?? "N/A") - Points: \(rank.points ?? 0)")
                        .font(.custom("Exo2-Italic", size: 16))
                }
                .padding(.leading, 8)
            }
            .padding(.vertical, 8)
        }
        
        private func teamLogo(for rank: Rank) -> some View {
            if let team = teams.first(where: { $0.school == rank.school }), let logoURL = team.logos?.first {
                let secureURL = logoURL.replacingOccurrences(of: "http://", with: "https://")
                if let url = URL(string: secureURL) {
                    return AnyView(AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 25, height: 25)
                        case .success(let image):
                            image.resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25) // Remove .clipShape(Circle()) to make it square
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
                .frame(width: 25, height: 25)
                .clipShape(Circle())
                .foregroundColor(.gray)
        }
    }
    
    struct NewsCard: View {
        var imageName: String
        var title: String
        var link: String
        
        var body: some View {
            VStack(alignment: .leading) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 150)
                    .clipped()
                    .cornerRadius(10)
                
                Text(title)
                    .font(.custom("Exo2-Italic", size: 16))
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .padding(.top, 5)
                
                Link(destination: URL(string: link)!) {
                    Text("Read more")
                        .font(.custom("Exo2-Italic", size: 14))
                        .foregroundColor(.blue)
                        .padding(.top, 5)
                }
            }
            .frame(width: 200)
        }
    }
    
    struct StoryCard: View {
        var imageName: String
        var number: Int
        var title: String
        var author: String
        var link: String
        
        var body: some View {
            HStack {
                Text("\(number)")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.black)
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.custom("Exo2-Italic", size: 20))
                        .foregroundColor(.black)
                        .lineLimit(2)
                    
                    Text(author)
                        .font(.custom("Exo2-Italic", size: 14))
                        .foregroundColor(.gray)
                    
                    Link(destination: URL(string: link)!) {
                        Text("Read more")
                            .font(.custom("Exo2-Italic", size: 14))
                            .foregroundColor(.blue)
                    }
                }
                .padding(.leading, 10)
                
                Spacer()
                
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 2)
        }
    }
    
    struct HomeView_Previews: PreviewProvider {
        static var previews: some View {
            HomeView()
        }
    }
}





