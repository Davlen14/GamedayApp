//
//  BackgroundView.swift
//  GamedayApp
//
//  Created by Davlen Swain on 8/5/24.
//

import SwiftUI

struct BackgroundView: View {
    var homeTeam: String?
    var awayTeam: String?
    var teams: [Team]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let homeColor = primaryOrSecondaryColor(for: homeTeam, teams: teams) {
                    homeColor
                        .clipShape(DiagonalShape(startPoint: .topLeading, endPoint: .bottomTrailing))
                }
                if let awayColor = primaryOrSecondaryColor(for: awayTeam, teams: teams) {
                    awayColor
                        .clipShape(DiagonalShape(startPoint: .topTrailing, endPoint: .bottomLeading))
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }

    private func primaryOrSecondaryColor(for teamName: String?, teams: [Team]) -> Color? {
        guard let teamName = teamName,
              let team = teams.first(where: { $0.school == teamName }) else { return nil }

        let primaryColor = Color(hex: team.color ?? "")
        let secondaryColor = Color(hex: team.alt_color ?? "")
        let fallbackColor = Color(white: 0.9)

        // Determine if the primary and secondary colors are the same or similar
        let colorsAreSimilar = primaryColor?.isSimilar(to: secondaryColor) ?? false

        // If colors are similar or both are nil, use the fallback color
        if colorsAreSimilar || (primaryColor == nil && secondaryColor == nil) {
            return fallbackColor
        }

        // If the primary color is too similar to the team's color, use the secondary color or fallback color
        if primaryColor?.luminance ?? 0 < 0.5 {
            return primaryColor ?? secondaryColor ?? fallbackColor
        } else {
            return secondaryColor ?? fallbackColor
        }
    }
}

struct DiagonalShape: Shape {
    var startPoint: UnitPoint
    var endPoint: UnitPoint

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: startPoint.x * rect.width, y: startPoint.y * rect.height))
        path.addLine(to: CGPoint(x: endPoint.x * rect.width, y: endPoint.y * rect.height))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

extension Color {
    // Compare if two colors are similar
    func isSimilar(to color: Color?) -> Bool {
        guard let color = color else { return false }
        let threshold: Double = 0.1 // Adjust threshold for similarity as needed
        return abs(self.luminance - color.luminance) < threshold
    }
}


