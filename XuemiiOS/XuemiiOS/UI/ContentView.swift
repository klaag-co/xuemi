import SwiftUI

struct ContentView: View {
    @StateObject private var bookmarkManager = BookmarkManager.shared
    @ObservedObject private var authmanager: AuthenticationManager = .shared

    var body: some View {
        if authmanager.isLoggedIn == true {
            HomeView()
//            if #available(iOS 18.0, *) {
//                TabView {
//                    Tab("Home", systemImage: "house") { HomeView() }
//                    Tab("Notes", systemImage: "doc.text") { NotesView() }
//                    Tab("Folders", systemImage: "pencil.and.list.clipboard") { FolderView(vocabManager: VocabManager()) }
//                    Tab("Settings", systemImage: "gearshape") { SettingsView() }
//                }
//                .environmentObject(bookmarkManager)
//            } else {
//                TabView {
//                    HomeView().tabItem { Label("Home", systemImage: "house") }
//                    NotesView().tabItem { Label("Notes", systemImage: "doc.text") }
//                    FolderView(vocabManager: VocabManager()).tabItem { Label("Folders", systemImage: "pencil.and.list.clipboard") }
//                    SettingsView().tabItem { Label("Settings", systemImage: "gearshape") }
//                }
//                .environmentObject(bookmarkManager)
//            }
        } else if authmanager.isLoggedIn == false {
            LoginView()
        } else {
            ProgressView().controlSize(.large)
        }
    }
}

#Preview { ContentView() }

