//
//  AboutFeatureCard.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 14/6/26.
//

import SwiftUI

struct AboutFeatureCard: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(.accent)
                .frame(width: 32, height: 32)
                .background(Color.accent.opacity(0.12))
                .mask(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(12)
        .background(Color(.systemGray6))
        .mask(RoundedRectangle(cornerRadius: 24))
    }
}
