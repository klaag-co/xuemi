import SwiftUI

struct ContentView: View {
    @StateObject private var authmanager = AuthenticationManager.shared

    var body: some View {
        Group {
            if authmanager.isLoggedIn == true {
                HomeView()
            } else if authmanager.isLoggedIn == false {
                LoginView()
            } else {
                ProgressView()
                    .controlSize(.large)
            }
        }
        .onAppear {
            authmanager.checkStatus()
        }
    }
}
