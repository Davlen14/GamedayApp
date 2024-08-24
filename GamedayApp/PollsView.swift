import SwiftUI

struct PollsView: View {
    @State private var rankings: [RankingWeek] = []
    @State private var selectedYear: Int = 2024
    @State private var selectedWeek: Int = 1
    @State private var selectedSeasonType: String = "regular"
    @State private var errorMessage: String?
    @State private var showingFilterSheet = false // State for showing the filter sheet
    @State private var teams: [Team] = [] // State for storing team data

    private let years = Array(2015...2024)
    private let seasonTypes = ["regular", "postseason"]
    private let weeks = Array(1...15) // Assume 15 weeks
    
    var body: some View {
        VStack {
            // Top Bar with Filter Button
            HStack {
                Button(action: {
                    showingFilterSheet = true
                }) {
                    HStack {
                        Image(systemName: "line.horizontal.3.decrease.circle.fill")
                            .font(.system(size: 20))
                        Text("Filter & Sort")
                            .font(.custom("Exo2-Italic", size: 16)) // Custom font applied
                    }
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
                .foregroundColor(.blue)
                
                Spacer()
                
                // Additional navigation or title can be added here
            }
            .padding()
            
            // Rankings List
            if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
                    .font(.custom("Exo2-Italic", size: 16))
            } else {
                List {
                    // AP Top 25 Section
                    if let apPoll = rankings.first(where: { $0.polls?.contains(where: { $0.poll == "AP Top 25" }) == true }) {
                        Section(header: PollHeaderView(poll: "AP Top 25")) {
                            ForEach(apPoll.polls?.first(where: { $0.poll == "AP Top 25" })?.ranks?.prefix(25) ?? [], id: \.rank) { rank in
                                PollRowView(rank: rank, teams: teams)
                            }
                        }
                    }
                    
                    // Coaches Poll Section
                    if let coachesPoll = rankings.first(where: { $0.polls?.contains(where: { $0.poll == "Coaches Poll" }) == true }) {
                        Section(header: PollHeaderView(poll: "Coaches Poll")) {
                            ForEach(coachesPoll.polls?.first(where: { $0.poll == "Coaches Poll" })?.ranks?.prefix(25) ?? [], id: \.rank) { rank in
                                PollRowView(rank: rank, teams: teams)
                            }
                        }
                    }
                    
                    // Playoff Committee Rankings Section
                    if let playoffPoll = rankings.first(where: { $0.polls?.contains(where: { $0.poll == "Playoff Committee Rankings" }) == true }) {
                        Section(header: PollHeaderView(poll: "Playoff Committee Rankings")) {
                            ForEach(playoffPoll.polls?.first(where: { $0.poll == "Playoff Committee Rankings" })?.ranks?.prefix(25) ?? [], id: \.rank) { rank in
                                PollRowView(rank: rank, teams: teams)
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationBarTitle("Rankings")
        .onAppear {
            Task {
                await fetchPolls()
                await fetchTeams() // Fetch team data on appear
            }
        }
        .sheet(isPresented: $showingFilterSheet) {
            FilterSheetView(selectedYear: $selectedYear, selectedWeek: $selectedWeek, selectedSeasonType: $selectedSeasonType)
        }
    }
    
    // Fetching Polls and Debugging
    private func fetchPolls() async {
        print("Fetching polls for year: \(selectedYear), seasonType: \(selectedSeasonType), week: \(selectedWeek)")
        do {
            let rankings = try await TeamService.shared.fetchPolls(year: selectedYear, seasonType: selectedSeasonType)
            DispatchQueue.main.async {
                print("Fetched Rankings: \(rankings)")
                self.rankings = rankings.filter { $0.week == selectedWeek }
            }
        } catch {
            print("Error fetching rankings: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                
                // Log raw data for debugging
                if let nsError = error as NSError?, let data = nsError.userInfo["data"] as? Data {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Raw JSON response: \(jsonString)")
                    }
                }
            }
        }
    }
    
    // Fetching Teams
    private func fetchTeams() async {
        do {
            let teams = try await TeamService.shared.fetchTeams()
            DispatchQueue.main.async {
                self.teams = teams
            }
        } catch {
            print("Error fetching teams: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    // Poll Header View
    struct PollHeaderView: View {
        var poll: String
        
        var body: some View {
            HStack {
                // Select the appropriate image based on the poll name
                Image(pollImageName(for: poll))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                Text(poll)
                    .font(.custom("Exo2-Italic", size: 20)) // Custom font applied
                    .bold()
                Spacer()
            }
            .padding()
        }
        
        private func pollImageName(for poll: String) -> String {
            switch poll {
            case "AP Top 25":
                return "AP"
            case "Coaches Poll":
                return "coach"
            case "Playoff Committee Rankings":
                return "committee"
            default:
                return ""
            }
        }
    }
    
    // Poll Row View
    struct PollRowView: View {
        var rank: Rank
        var teams: [Team] // Add teams as a parameter
        
        var body: some View {
            HStack {
                teamLogo(for: rank)
                VStack(alignment: .leading) {
                    Text("#\(rank.rank ?? 0) \(rank.school ?? "N/A")")
                        .font(.custom("Exo2-Italic", size: 18)) // Custom font applied
                    Text("\(rank.conference ?? "N/A") - Points: \(rank.points ?? 0)")
                        .font(.custom("Exo2-Italic", size: 16)) // Custom font applied
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
    
    // FilterSheetView
    struct FilterSheetView: View {
        @Binding var selectedYear: Int
        @Binding var selectedWeek: Int
        @Binding var selectedSeasonType: String
        
        private let years = Array(2015...2024)
        private let seasonTypes = ["regular", "postseason"]
        private let weeks = Array(1...15)
        
        var body: some View {
            VStack(spacing: 20) {
                Picker("Year", selection: $selectedYear) {
                    ForEach(years, id: \.self) { year in
                        Text("\(year)")
                            .font(.custom("Exo2-Italic", size: 16)) // Custom font applied
                    }
                }
                .pickerStyle(WheelPickerStyle())
                
                Picker("Season Type", selection: $selectedSeasonType) {
                    ForEach(seasonTypes, id: \.self) { type in
                        Text(type.capitalized)
                            .font(.custom("Exo2-Italic", size: 16)) // Custom font applied
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Picker("Week", selection: $selectedWeek) {
                    ForEach(weeks, id: \.self) { week in
                        Text("Week \(week)")
                    }
                }
                .pickerStyle(WheelPickerStyle())
                
                Button("Apply") {
                    // Code to apply filters and dismiss the sheet
                    // Example: dismiss action if using an Environment key
                }
                .padding()
            }
            .padding()
        }
    }
}








