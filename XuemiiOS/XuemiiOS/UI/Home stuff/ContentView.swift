import SwiftUI

struct ContentView: View {
// wld remove cuz why is this here??
//    @StateObject private var bookmarkManager = BookmarkManager.shared
    @ObservedObject private var authmanager: AuthenticationManager = .shared

    var body: some View {
        if authmanager.isLoggedIn == true {
            HomeView()
        } else if authmanager.isLoggedIn == false {
            LoginView()
        } else {
            ProgressView().controlSize(.large)
        }
    }
}
