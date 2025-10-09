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

final class DeviceTypeManager: ObservableObject {
    @Published var deviceType: DeviceType

    init(horizontalSizeClass: UserInterfaceSizeClass?) {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            self.deviceType = .iphone
        case .pad:
            switch horizontalSizeClass {
            case .compact: self.deviceType = .ipad(.compact)
            case .regular: self.deviceType = .ipad(.regular)
            default:       self.deviceType = .ipad(.either) // safe default
            }
        default:
            self.deviceType = .unknown
        }
    }

    func updateHorizontalSizeClass(_ newValue: UserInterfaceSizeClass?) {
        guard case .pad = UIDevice.current.userInterfaceIdiom else { return }
        switch newValue {
        case .compact: self.deviceType = .ipad(.compact)
        case .regular: self.deviceType = .ipad(.regular)
        default: break
        }
    }

    var isIPhone: Bool {
        if case .iphone = deviceType { return true }
        return false
    }
    var isIPad: Bool {
        if case .ipad = deviceType { return true }
        return false
    }
}
