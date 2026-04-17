//
//  DeviceType.swift
//  XuemiiOS
//
//  Created by Kmy Er on 6/10/25.
//

import SwiftUI

enum DeviceType: Equatable {
    case iphone
    case ipad(iPadLayout)
    case unknown

    enum iPadLayout: Equatable {
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


