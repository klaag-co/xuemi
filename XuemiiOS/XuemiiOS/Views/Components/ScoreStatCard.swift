//
//  ScoreStatCard.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 19/6/26.
//

import SwiftUI

struct ScoreStatCard: View {
    let value: String
    let label: String

    @Environment(DeviceTypeManager.self) private var deviceTypeManager

    var body: some View {
        Group {
            sizing
                .padding(.vertical)
                .padding(.horizontal)
                .background(Color(.secondarySystemBackground))
                .mask(RoundedRectangle(cornerRadius: 24))
        }
    }

    var sizing: some View {
        Group {
            if deviceTypeManager.deviceType != .ipad(.regular) {
                content
                    .frame(maxWidth: .infinity)
            } else {
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    var content: some View {
        VStack {
            Text(value)
                .font(.title2.weight(.bold))
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .contentTransition(.numericText())
                .monospacedDigit()

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}
