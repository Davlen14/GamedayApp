//
//  TopBar.swift
//  GamedayApp
//
//  Created by Davlen Swain on 8/1/24.
//

import SwiftUI

struct TopBar: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(red: 153/255, green: 0/255, blue: 0/255), Color(red: 255/255, green: 51/255, blue: 51/255).darker(by: 15)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.top)
                .frame(height: 55) // Adjusted height for uniformity

            HStack {
                Button(action: {
                    // Action for Ranks
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 16))
                        Text("Ranks")
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
                    // Action for Lines
                }) {
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
                            .font(.system(size: 16))
                        Text("News")
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
            .padding(.top, 1) // Adjusted top padding for safe area
            .padding(.bottom, 5) // Consistent bottom padding
        }
    }
}

struct TopBar_Previews: PreviewProvider {
    static var previews: some View {
        TopBar()
    }
}


