//
//  ShakeEffect.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 15/6/26.
//

import SwiftUI

struct ShakeEffect: GeometryEffect {
    var shakes: CGFloat = 0
    var amplitude: CGFloat = 8
    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }
    func effectValue(size: CGSize) -> ProjectionTransform {
        let x = sin(shakes * .pi * 2) * amplitude
        return ProjectionTransform(CGAffineTransform(translationX: x, y: 0))
    }
}
