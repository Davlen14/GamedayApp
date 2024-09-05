//
//  WinProbabilityView.swift
//  GamedayApp
//
//  Created by Davlen Swain on 8/27/24.
//

import SwiftUI

struct WinProbabilityView: View {
    let homeTeam: String
    let awayTeam: String
    let homeWinProb: Double
    let awayWinProb: Double
    let homeLogoURL: String?
    let awayLogoURL: String?

    var body: some View {
        VStack {
            Text("Win Probability")
                .font(.headline)
                .padding(.bottom, 4)

            HStack {
                if let homeLogoURL = homeLogoURL {
                    AsyncImage(url: URL(string: homeLogoURL)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 40, height: 40)
                        case .success(let image):
                            image.resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }

                ZStack(alignment: .leading) {
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.green)
                                .frame(width: geometry.size.width * CGFloat(homeWinProb))
                            Rectangle()
                                .fill(Color.red)
                                .frame(width: geometry.size.width * CGFloat(awayWinProb))
                        }
                    }
                    .frame(height: 30)
                }
                .padding(.horizontal)

                if let awayLogoURL = awayLogoURL {
                    AsyncImage(url: URL(string: awayLogoURL)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 40, height: 40)
                        case .success(let image):
                            image.resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
            }

            HStack {
                Text("\(homeTeam) \(Int(homeWinProb * 100))%")
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(awayTeam) \(Int(awayWinProb * 100))%")
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(.vertical)
    }
}

