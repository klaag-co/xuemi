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
    
    var filteredBookmarks: [BookmarkedVocabulary] {
        if searchText.isEmpty {
            return bookmarkManager.bookmarks
        } else {
            return bookmarkManager.bookmarks.filter({ $0.vocab.word.uppercased().contains(searchText.uppercased()) })
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                bookmarkedWordsForLevel(level: .one)
                bookmarkedWordsForLevel(level: .two)
                bookmarkedWordsForLevel(level: .three)
                bookmarkedWordsForLevel(level: .four)
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("Bookmarks")
        }
    }
    
    func bookmarkedWordsForLevel(level: SecondaryNumber) -> some View {
        DisclosureGroup(level.filename) {
            ForEach(filteredBookmarks.filter { $0.level == level }, id: \.id) { bookmarkedVocab in
                VStack(alignment: .leading) {
                    Text(bookmarkedVocab.vocab.word)
                    Text("\(bookmarkedVocab.level.filename) \(bookmarkedVocab.chapter.string)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

#Preview {
    BookmarkView()
        .environmentObject(BookmarkManager.shared)
}
