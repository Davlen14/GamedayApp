import SwiftUI
import Charts

struct MoreView: View {
    @State private var teamRecords: [TeamRecord] = []
    @State private var selectedYears: Set<Int> = [2023]
    @State private var selectedTeams: Set<String> = ["Ohio State"]
    @State private var errorMessage: String?
    
    let teams = ["Ohio State", "Michigan", "Alabama", "Clemson", "Georgia", "Texas", "Missouri"]
    let years = Array(2015...2023).map { String($0) }
    
    var body: some View {
        NavigationView {
            VStack {
                MultiSelectDropdownView(title: "Select Years", options: years, selectedOptions: Binding(
                    get: { Set(selectedYears.map { String($0) }) },
                    set: { selectedYears = Set($0.compactMap { Int($0) }) }
                ))
                .padding()

                MultiSelectDropdownView(title: "Select Teams", options: teams, selectedOptions: $selectedTeams)
                .padding()

                if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else {
                    if filteredRecords.isEmpty {
                        Text("No data available")
                            .foregroundColor(.gray)
                    } else {
                        Chart {
                            ForEach(filteredChartData, id: \.team) { data in
                                ForEach(data.wins, id: \.year) { winData in
                                    LineMark(
                                        x: .value("Year", winData.year),
                                        y: .value("Wins", winData.wins)
                                    )
                                    .foregroundStyle(by: .value("Team", data.team))
                                    .shadow(color: .black.opacity(0.5), radius: 10, x: 5, y: 10) // Heavier shadow
                                }
                            }
                        }

                        .chartXAxis {
                            AxisMarks(values: .stride(by: 1)) {
                                AxisGridLine()
                                AxisTick()
                                AxisValueLabel()
                            }
                        }
                        .chartXScale(domain: 2015...2023)
                        .padding()
                    }
                }
            }
            .navigationTitle("Team Wins Over Years")
            .onAppear {
                Task {
                    await fetchTeamRecords()
                }
            }
            .onChange(of: selectedYears) {
                Task {
                    await fetchTeamRecords()
                }
            }
            .onChange(of: selectedTeams) {
                Task {
                    await fetchTeamRecords()
                }
            }
        }
    }
    
    private var filteredRecords: [TeamRecord] {
        teamRecords.filter { record in
            selectedYears.contains(record.year ?? 0) && selectedTeams.contains(record.team ?? "")
        }
    }
    
    private var filteredChartData: [TeamChartData] {
        var data: [TeamChartData] = []
        
        for team in selectedTeams {
            var wins: [YearWinsData] = []
            for year in 2015...2023 {
                let recordsForYear = filteredRecords.filter { $0.year == year && $0.team == team }
                let totalWins = recordsForYear.reduce(0) { $0 + ($1.total?.wins ?? 0) }
                wins.append(YearWinsData(year: year, wins: totalWins))
            }
            data.append(TeamChartData(team: team, wins: wins))
        }
        
        return data
    }
    
    @MainActor
    private func fetchTeamRecords() async {
        let teamIds = [
            "Ohio State": 1,  // Replace with actual team IDs
            "Michigan": 2,
            "Alabama": 3,
            "Clemson": 4,
            "Georgia": 5,
            "Texas": 6,
            "Missouri": 7
        ]
        
        teamRecords.removeAll()
        errorMessage = nil

        var fetchedRecords = [TeamRecord]()
        var errors = [String]()

        await withTaskGroup(of: (Result<[TeamRecord], Error>).self) { taskGroup in
            for team in selectedTeams {
                guard let teamId = teamIds[team] else { continue }
                for year in selectedYears {
                    taskGroup.addTask {
                        do {
                            let records = try await TeamService.shared.fetchTeamRecords(teamId: teamId, year: year)
                            return .success(records)
                        } catch {
                            return .failure(error)
                        }
                    }
                }
            }
            
            for await result in taskGroup {
                switch result {
                case .success(let records):
                    fetchedRecords.append(contentsOf: records)
                case .failure(let error):
                    errors.append(error.localizedDescription)
                }
            }
        }

        if !errors.isEmpty {
            self.errorMessage = errors.joined(separator: "\n")
        } else {
            self.teamRecords = fetchedRecords
        }
    }
}

struct TeamChartData {
    let team: String
    let wins: [YearWinsData]
}

struct YearWinsData {
    let year: Int
    let wins: Int
}

struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        MoreView()
    }
}





















