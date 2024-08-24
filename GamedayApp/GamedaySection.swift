//
//  GamedaySection.swift
//  GamedayApp
//
//  Created by Davlen Swain on 8/1/24.
//

import SwiftUI

struct GamedaySection: View {
    var body: some View {
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
        .padding(.vertical, 6) // Consistent padding
        .background(Color(red: 255/255, green: 51/255, blue: 51/255).opacity(1)) // Ensure full opacity
        .offset(y: -10) // Adjusted offset
        .zIndex(1) // Keep this on top
    }
}

struct GamedaySection_Previews: PreviewProvider {
    static var previews: some View {
        GamedaySection()
    }
}
