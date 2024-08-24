//
//  ColorExtension.swift
//  GamedayApp
//
//  Created by Davlen Swain on 8/5/24.
//

import SwiftUI

extension Color {
    // Initialize a Color from a hex string
    init?(hex: String) {
        let r, g, b: Double

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = Double((hexNumber & 0xff0000) >> 16) / 255
                    g = Double((hexNumber & 0x00ff00) >> 8) / 255
                    b = Double(hexNumber & 0x0000ff) / 255

                    self.init(red: r, green: g, blue: b)
                    return
                }
            }
        }
        return nil
    }

    // Calculate the luminance of the color
    var luminance: Double {
        let components = self.cgColor?.components ?? [0, 0, 0]
        let r = components[0] * 0.299
        let g = components[1] * 0.587
        let b = components[2] * 0.114
        return Double(r + g + b)
    }

    // Calculate the contrast ratio between two colors
    static func contrastRatio(between color1: Color, and color2: Color) -> Double {
        let l1 = color1.luminance + 0.05
        let l2 = color2.luminance + 0.05
        return max(l1, l2) / min(l1, l2)
    }
}

// Function to determine if the primary or secondary color should be used
func backgroundColor(for team: Team, against backgroundColor: Color) -> Color {
    let lightGrey = Color(white: 0.9) // Light grey color as a fallback

    // Primary and secondary colors from the team data
    let primaryColor = Color(hex: team.color ?? "")
    let secondaryColor = Color(hex: team.alt_color ?? "")

    // Calculate contrast ratios
    let primaryContrast = primaryColor.map { Color.contrastRatio(between: $0, and: backgroundColor) } ?? 0
    let secondaryContrast = secondaryColor.map { Color.contrastRatio(between: $0, and: backgroundColor) } ?? 0

    // Determine suitable color
    if primaryContrast >= 4.5 {
        return primaryColor ?? lightGrey
    } else if secondaryContrast >= 4.5 {
        return secondaryColor ?? lightGrey
    } else {
        return lightGrey
    }
}
