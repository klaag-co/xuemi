//
//  LeaderboardView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 8/7/25.
//

import SwiftUI

struct LeaderboardView: View {
    let leaderboardData: [String?] = [
        "School of Science & Technology",
        "NUS High School of Mathematics and Science",
        nil,
        nil,
        "Crescent Girls' School",
        "School of Arts and Culture",
        nil,
        nil,
        nil,
        nil
    ]

    var body: some View {
        VStack(spacing: 16) {
            Text("Leaderboard")
                .font(.largeTitle)
                .bold()
                .padding(.top)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(0..<10) { index in
                        LeaderboardRow(rank: index + 1, schoolName: leaderboardData[index])
                    }
                }
            }
        }
        .padding(.vertical)
    }
}

struct LeaderboardRow: View {
    let rank: Int
    let schoolName: String?

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.black, lineWidth: 1)
                    .frame(width: 50, height: 50)
                Text("\(rank)")
                    .font(.headline)
                    .bold()
            }
            if let school = schoolName {
                Text(school)
                    .font(.body)
                    .bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .truncationMode(.tail)
            }

            Spacer()
        }
        .padding(.trailing)
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .background(
            Capsule()
                .fill(Color.customgray)
                .overlay(
                    Capsule()
                        .stroke(Color.black, lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
}


#Preview {
    LeaderboardView()
}
