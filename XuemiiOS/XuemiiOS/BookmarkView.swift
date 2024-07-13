//
//  FavouritesView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 16/4/24.
//

import SwiftUI

struct BookmarkView: View {
    @State private var searchText = ""
    
    @EnvironmentObject var bookmarkManager: BookmarkManager
    
    var filteredBookmarks: [String: [Vocabulary]] {
        if searchText.isEmpty {
            return bookmarkManager.bookmarks
        } else {
            var result = [String: [Vocabulary]]()
            for (key, value) in bookmarkManager.bookmarks {
                let filtered = value.filter { $0.word.contains(searchText) }
                if !filtered.isEmpty {
                    result[key] = filtered
                }
            }
            return result
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredBookmarks.keys.sorted(), id: \.self) { level in
                    Section(header: Text(level)) {
                        ForEach(filteredBookmarks[level]!, id: \.index) { vocab in
                            Text(vocab.word)
                        }
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("Bookmarks")
        }
    }
}

#Preview {
    BookmarkView()
        .environmentObject(BookmarkManager.shared)
}
