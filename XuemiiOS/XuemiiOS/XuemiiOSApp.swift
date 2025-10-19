//
//  XuemiiOSApp.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 16/4/24.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct XuemiiOSApp: App {
    @StateObject private var deviceTypeManager = DeviceTypeManager(horizontalSizeClass: .regular)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(BookmarkManager.shared)
                .environmentObject(deviceTypeManager)
                .onOpenURL { URL in
                    GIDSignIn.sharedInstance.handle(URL)
                }
        }
    }
}
