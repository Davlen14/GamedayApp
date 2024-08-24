import SwiftUI
import Charts

struct RankingsComparisonView: View {
    var rankingsData: [RankingWeek]
    var selectedTeams: Set<String> // Ensure selectedTeams is a Set

    @State private var selectedWeek: Int = 1 // Default to week 1
    @State private var selectedYear: Int = 2023 // Default to 2023
    @State private var showAllWeeks: Bool = false // Toggle for showing all weeks

    private let years = Array(2015...2024)
    private let weeks = Array(1...15) // Assume 15 weeks

    var body: some View {
        VStack {
            Text("Rankings Comparison")
                .font(.custom("Exo2-Italic", size: 24))
                .bold()
                .padding()

            // Year and Week Picker
            HStack {
                Picker("Year", selection: $selectedYear) {
                    ForEach(years, id: \.self) { year in
                        Text("\(year)")
                            .font(.custom("Exo2-Italic", size: 16))
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                Picker("Week", selection: $selectedWeek) {
                    ForEach(weeks, id: \.self) { week in
                        Text("Week \(week)")
                            .font(.custom("Exo2-Italic", size: 16))
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 150)
                .clipped()
            }

            Toggle("Show All Weeks", isOn: $showAllWeeks)
                .padding()

            // Display the chart
            Chart {
                ForEach(Array(selectedTeams).sorted(), id: \.self) { team in
                    let teamData = getTeamData(for: team, year: selectedYear)
                    ForEach(teamData) { dataPoint in
                        if showAllWeeks || dataPoint.week == selectedWeek {
                            LineMark(
                                x: .value("Week", dataPoint.week),
                                y: .value("Ranking", dataPoint.rank)
                            )
                            .foregroundStyle(by: .value("Team", team))
                            .symbol(Circle())
                            .interpolationMethod(.catmullRom) // Smooth line interpolation
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: 1)) { value in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .frame(height: 300) // Set the height of the chart
            .padding()

            Spacer()
        }
    }

    // Function to extract data for a specific team and year
    private func getTeamData(for team: String, year: Int) -> [TeamRanking] {
        var data: [TeamRanking] = []

        for rankingWeek in rankingsData where rankingWeek.season == year {
            for poll in rankingWeek.polls ?? [] {
                for rank in poll.ranks ?? [] {
                    if rank.school == team {
                        let teamRanking = TeamRanking(
                            teamName: rank.school ?? "Unknown",
                            week: rankingWeek.week ?? 0,
                            year: rankingWeek.season ?? 0,
                            rank: rank.rank ?? 0
                        )
                        data.append(teamRanking)
                    }
                }
            }
        }

        return data.sorted { $0.week < $1.week }
    }
}

// Define a struct for holding team ranking data
struct TeamRanking: Identifiable {
    let id = UUID()
    let teamName: String
    let week: Int
    let year: Int
    let rank: Int
}





