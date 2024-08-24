import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            TeamsView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Teams")
                }
            GamesView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Games")
                }
            StatsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Stats")
                }
            MoreView()
                .tabItem {
                    Image(systemName: "ellipsis.circle")
                    Text("More")
                }
        }
        .accentColor(.gamedayRed)
        .background(Color("backgroundLight")) // Background color for the entire screen
        .edgesIgnoringSafeArea(.all) // Ensures the background color extends to the edges of the screen
        .environment(\.colorScheme, colorScheme) // Respect the system preference
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .preferredColorScheme(.dark) // Preview in dark mode
            ContentView()
                .preferredColorScheme(.light) // Preview in light mode
        }
    }
}



