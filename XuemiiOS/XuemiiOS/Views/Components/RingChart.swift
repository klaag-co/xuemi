//
//  RingChart.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 17/6/26.
//

import SwiftUI

struct RingChart: View {
    let value: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 22)

            Circle()
                .stroke(Color.red.opacity(0.75), lineWidth: 22)

            Circle()
                .trim(from: 0, to: CGFloat(value))
                .stroke(Color.green, style: StrokeStyle(lineWidth: 22, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text("\(Int(round(value * 100)))%")
                .font(.system(size: 44, weight: .bold))
        }
    }
}
