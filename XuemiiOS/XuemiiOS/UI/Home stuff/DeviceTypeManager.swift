//
//  DeviceTypeManager.swift
//  XuemiiOS
//
//  Created by Kmy Er on 1/11/25.
//

import SwiftUI

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
