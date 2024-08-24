import SwiftUI

struct StatsView: View {
    @State private var playerStats: [PlayerSeasonStat] = []
    @State private var errorMessage: String?
    @State private var selectedCategory: String = "passing"
    @State private var showingModal: Bool = false
    @State private var selectedSubcategory: String?
    
    let categories = ["passing", "rushing", "receiving"]
    
    var body: some View {
        VStack(alignment: .leading) {
            headerView
            topBar
            statsContent
        }
        .padding()
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .onAppear {
            Task {
                await fetchAllTeamsStats(category: selectedCategory)
            }
        }
        .onChange(of: selectedCategory) {
            Task {
                await fetchAllTeamsStats(category: selectedCategory)
            }
        }
        .sheet(isPresented: $showingModal) {
            if let subcategory = selectedSubcategory {
                DetailedStatsView(
                    category: selectedCategory.capitalized,
                    subcategory: subcategory,
                    stats: topStats(for: subcategory, limit: 100) // Show top 100 stats in modal
                )
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Player Stats")
                .font(.custom("Exo2-Italic", size: 34))
                .foregroundColor(.gamedayRed)
                .bold()
            Text(" - 2023")
                .font(.custom("Exo2-Italic", size: 24))
                .foregroundColor(.secondary)
        }
        .padding(.bottom)
    }
    
    private var topBar: some View {
        HStack {
            Picker("Select Category", selection: $selectedCategory) {
                ForEach(categories, id: \.self) { category in
                    Text(category.capitalized).tag(category)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding(.bottom)
    }
    
    private var statsContent: some View {
        Group {
            if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.gamedayRed)
                    .padding()
                    .font(.custom("Exo2-Italic", size: 20))
            } else if playerStats.isEmpty {
                Text("No data available")
                    .foregroundColor(.gray)
                    .padding()
                    .font(.custom("Exo2-Italic", size: 20))
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(subcategoriesForCategory(selectedCategory), id: \.self) { subcategory in
                            SubcategorySection(
                                category: selectedCategory.capitalized,
                                subcategory: subcategory,
                                stats: topStats(for: subcategory, limit: 50), // Show top 10 stats in main view
                                showMoreAction: {
                                    selectedSubcategory = subcategory
                                    showingModal = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private func fetchAllTeamsStats(category: String) async {
        do {
            let teams = try await TeamService.shared.fetchTeams()
            var allPlayerStats: [PlayerSeasonStat] = []
            var lastError: Error?
            
            await withTaskGroup(of: (Result<[PlayerSeasonStat], Error>).self) { taskGroup in
                for team in teams {
                    taskGroup.addTask {
                        do {
                            let playerStats = try await TeamService.shared.fetchPlayerSeasonStats(year: 2023, team: team.school, category: category, seasonType: "regular")
                            return .success(playerStats)
                        } catch {
                            return .failure(error)
                        }
                    }
                }
                
                for await result in taskGroup {
                    switch result {
                    case .success(let playerStats):
                        allPlayerStats.append(contentsOf: playerStats)
                    case .failure(let error):
                        lastError = error
                    }
                }
            }
            
            if !allPlayerStats.isEmpty {
                self.playerStats = allPlayerStats
                self.errorMessage = nil
            } else if let error = lastError {
                self.errorMessage = error.localizedDescription
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    private func subcategoriesForCategory(_ category: String) -> [String] {
        switch category {
        case "passing":
            return ["YDS", "TD", "COMPLETIONS"]
        case "rushing":
            return ["YDS", "TD", "LONG"]
        case "receiving":
            return ["YDS", "TD", "LONG"]
        default:
            return []
        }
    }
    
    private func topStats(for subcategory: String, limit: Int) -> [PlayerSeasonStat] {
        return Array(playerStats.filter { $0.statType == subcategory }
            .sorted { ($0.stat ?? 0) > ($1.stat ?? 0) }
            .prefix(limit))
    }
    
    struct SubcategorySection: View {
        let category: String
        let subcategory: String
        let stats: [PlayerSeasonStat]
        let showMoreAction: () -> Void
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text("\(category) - \(subcategory)")
                        .font(.custom("Exo2-Italic", size: 22))
                        .bold()
                    Spacer()
                }
                
                ForEach(stats.indices, id: \.self) { index in
                    StatRowView(rank: index + 1, stat: stats[index])
                }
                
                Button(action: showMoreAction) {
                    Text("View More")
                        .font(.custom("Exo2-Italic", size: 18))
                        .foregroundColor(.blue)
                }
                .padding(.top)
            }
            .padding(.bottom)
        }
    }
    
    struct StatRowView: View {
        let rank: Int
        let stat: PlayerSeasonStat
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(rank). \(stat.player ?? "Unknown Player")")
                            .font(.custom("Exo2-Italic", size: 18))
                            .bold()
                        Text(stat.team ?? "Unknown Team")
                            .font(.custom("Exo2-Italic", size: 14))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(stat.stat.map { String(format: "%.0f", $0) } ?? "0")
                            .font(.custom("Exo2-Italic", size: 18))
                            .foregroundColor(.primary)
                        Text(stat.statType ?? "Unknown Stat Type")
                            .font(.custom("Exo2-Italic", size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
        }
    }
    
    struct DetailedStatsView: View {
        let category: String
        let subcategory: String
        let stats: [PlayerSeasonStat]
        
        var body: some View {
            NavigationView {
                VStack(alignment: .leading) {
                    Text("\(category) \(subcategory) - All Players")
                        .font(.custom("Exo2-Italic", size: 20))
                        .foregroundColor(.gamedayRed)
                        .bold()
                        .padding()
                    
                    List(stats) { stat in
                        StatRowView(rank: stats.firstIndex(of: stat)! + 1, stat: stat)
                    }
                    .listStyle(InsetGroupedListStyle())
                }
                .navigationTitle("Detailed Stats")
                .navigationBarItems(trailing: Button("Close") {
                    // Dismiss the modal
                    // Note: SwiftUI automatically handles dismissal when the sheet is no longer presented
                })
            }
        }
    }
}

struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
    }
}



