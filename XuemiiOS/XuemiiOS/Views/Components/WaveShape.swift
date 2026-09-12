//
//  WaveShape.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 14/6/26.
//

import SwiftUI

struct WaveShape: Shape {
    var phase: CGFloat
    var amplitude: CGFloat = 20
    var frequency: CGFloat = 1.5

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        path.move(to: CGPoint(x: 0, y: height))

        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / width
            let sine = sin(relativeX * frequency * .pi * 2 + phase)
            let y = height / 2 + sine * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: width, y: height))
        path.closeSubpath()

        return path
    }
}
