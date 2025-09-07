//
//  ContentView. ft
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 16/4/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var bookmarkManager = BookmarkManager.shared
    @ObservedObject private var authmanager: AuthenticationManager = .shared

    var body: some View {
        if authmanager.isLoggedIn == true {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
//                BookmarkView()
//                    .tabItem {
//                        Label("Bookmarks", systemImage: "bookmark")
//                    }
//                LeaderboardView()
//                    .tabItem{
//                        Label("Leaderboard", systemImage: "medal")
//                    }
//                ScoreView()
//                    .tabItem{
//                        Label("Scores", systemImage: "star.circle")
//                    }
                NotesView()
                    .tabItem {
                        Label("Notes", systemImage: "doc.text")
                    }
                FolderView(vocabManager: VocabManager())
                    .tabItem {
                        Label("Vocabulary", systemImage: "pencil.and.list.clipboard")
                    }
            }
            .environmentObject(bookmarkManager)
        } else if authmanager.isLoggedIn == false {
            LoginView()
        } else {
            ProgressView()
                .controlSize(.large)
        }
    }
}

#Preview {
    ContentView()
}
