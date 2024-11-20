//
//  ContentView. ft
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 16/4/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var bookmarkManager = BookmarkManager.shared

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            BookmarkView()
                .tabItem {
                    Label("Bookmarks", systemImage: "bookmark")
                }
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
    }
}

#Preview {
    ContentView()
}
