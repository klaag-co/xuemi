//
//  DeviceTypeManager.swift
//  Xuemi
//
//  Created by Tristan Chay on 17/8/26.
//

import SwiftUI

@Observable
class DeviceTypeManager {
    private(set) var deviceType: DeviceType

    init() {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone: self.deviceType = .iphone
        case .pad:
            let horizontalSizeClass: UserInterfaceSizeClass = .regular

            switch horizontalSizeClass {
            case .compact: self.deviceType = .ipad(.compact)
            case .regular: self.deviceType = .ipad(.regular)
            @unknown default: self.deviceType = .unknown
            }
        default: self.deviceType = .unknown
        }
    }

    func updateHorizontalSizeClass(_ newValue: UserInterfaceSizeClass?) {
        guard let newValue else { return }
        guard case .ipad = deviceType else { return }

        switch newValue {
        case .compact: self.deviceType = .ipad(.compact)
        case .regular: self.deviceType = .ipad(.regular)
        @unknown default: break
        }
    }
}

