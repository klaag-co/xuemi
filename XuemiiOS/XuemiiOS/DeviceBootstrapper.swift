//
//  DeviceBootstrapper.swift
//  XuemiiOS
//
//  Created by Kmy Er on 6/10/25.
//

import SwiftUI

struct DeviceBootstrapper: View {
    @Environment(\.horizontalSizeClass) private var hSize
    @StateObject private var device = DeviceTypeManager(horizontalSizeClass: nil)

    var body: some View {
        ContentView()
            .environmentObject(device)
            .onAppear { device.updateHorizontalSizeClass(hSize) }
            .onChange(of: hSize) { device.updateHorizontalSizeClass($0) }
    }
}
