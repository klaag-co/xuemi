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
            return bookmarkManager.bookmarks.filter { $0.vocab.word.uppercased().contains(searchText.uppercased()) }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    bookmarkedWordsForLevel(level: .one)
                    bookmarkedWordsForLevel(level: .two)
                    bookmarkedWordsForLevel(level: .three)
                    bookmarkedWordsForLevel(level: .four)
                    
                    Section(header: Text("Swipe left to unbookmark")){
                        //nothing
                    }
                }
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                .navigationTitle("Bookmarks")
            }
        }
    }
    
    func bookmarkedWordsForLevel(level: SecondaryNumber) -> some View {
        DisclosureGroup(level.filename) {
            ForEach(filteredBookmarks.filter { $0.level == level }, id: \.id) { bookmarkedVocab in
                VStack(alignment: .leading) {
                    NavigationLink(destination: FlashcardView(
                        vocabularies: loadVocabulariesFromJSON(fileName: "中\(bookmarkedVocab.level.string)", chapter: bookmarkedVocab.chapter.string, topic: bookmarkedVocab.topic.string(level: bookmarkedVocab.level, chapter: bookmarkedVocab.chapter)),
                        level: bookmarkedVocab.level,
                        chapter: bookmarkedVocab.chapter,
                        topic: bookmarkedVocab.topic,
                        currentIndex: bookmarkedVocab.currentIndex
                    )) {
                        VStack(alignment: .leading) {
                            Text(bookmarkedVocab.vocab.word)
                            Text("\(bookmarkedVocab.level.filename) \(bookmarkedVocab.chapter.string)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .swipeActions {
                    Button(role: .destructive) {
                        removeBookmark(bookmarkedVocab)
                    } label: {
                        Label("Unbookmark", systemImage: "trash")
                    }
                }
            }
        }
    }
    
    func removeBookmark(_ bookmarkedVocab: BookmarkedVocabulary) {
        if let index = bookmarkManager.bookmarks.firstIndex(where: { $0.id == bookmarkedVocab.id }) {
            bookmarkManager.bookmarks.remove(at: index)
        }
    }
}

#Preview {
    BookmarkView()
        .environmentObject(BookmarkManager.shared)
}
