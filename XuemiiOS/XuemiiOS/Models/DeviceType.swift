//
//  DeviceType.swift
//  Xuemi
//
//  Created by Tristan Chay on 17/8/26.
//

import SwiftUI

enum DeviceType: Equatable {
    case iphone, ipad(iPadLayout), unknown

    enum iPadLayout {
        case regular, compact, either
    }

    static func == (lhs: DeviceType, rhs: DeviceType) -> Bool {
        switch (lhs, rhs) {
        case (.iphone, .iphone): return true
        case (.unknown, .unknown): return true
        case let (.ipad(a), .ipad(b)):
            return b == .either ? true : (a == b)
        default:
            return false
        }
    }
}
