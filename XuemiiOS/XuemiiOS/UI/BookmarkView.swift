//
//  FavouritesView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 16/4/24.
//  Updated: Topic tags with always-visible headers, custom topic editing.
//

import SwiftUI

// MARK: - Local tag store (no backend changes)
private enum BookmarkTagStore {
    // 6 fixed topics (the 7th "Other" is for creating custom topics)
    static let predefined: [String] = ["艺术与文化", "科技", "社区", "环保", "教育", "社会"]

    private static let customTopicsKey = "bookmark.custom.topics"                // [String]
    private static let idToTopicKeyPrefix = "bookmark.tag."                      // per-bookmark key

    // Build a stable key from the bookmark identity (no backend change needed)
    static func key(for vocab: BookmarkedVocabulary) -> String {
        let w = vocab.vocab.word
        let lv = "L\(vocab.level.string)"
        let ch = "C\(vocab.chapter.string)"
        let tp = "T\(vocab.topic.string(level: vocab.level, chapter: vocab.chapter))"
        return idToTopicKeyPrefix + [w, lv, ch, tp].joined(separator: "::")
    }

    // Read/write a tag for a specific bookmark “identity”
    static func tag(forKey key: String) -> String? {
        UserDefaults.standard.string(forKey: key)
    }
    static func setTag(_ tag: String, forKey key: String) {
        UserDefaults.standard.set(tag, forKey: key)
    }
    static func clearTag(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }

    // Custom topics list
    static func customTopics() -> [String] {
        (UserDefaults.standard.array(forKey: customTopicsKey) as? [String]) ?? []
    }
    static func setCustomTopics(_ topics: [String]) {
        UserDefaults.standard.set(topics, forKey: customTopicsKey)
    }

    // All topics (fixed + custom)
    static func allTopics() -> [String] {
        predefined + customTopics()
    }
}

struct BookmarkView: View {
    @State private var searchText = ""

    // For refreshing when tags/custom topics change
    @State private var tagVersion: Int = 0
    @State private var customTopics: [String] = BookmarkTagStore.customTopics()

    @EnvironmentObject var bookmarkManager: BookmarkManager

    // MARK: - Filter (by search)
    var filteredBookmarks: [BookmarkedVocabulary] {
        if searchText.isEmpty {
            return bookmarkManager.bookmarks
        } else {
            return bookmarkManager.bookmarks.filter { $0.vocab.word.uppercased().contains(searchText.uppercased()) }
        }
    }

    // MARK: - Grouping helpers
    private func tag(for b: BookmarkedVocabulary) -> String? {
        BookmarkTagStore.tag(forKey: BookmarkTagStore.key(for: b))
    }
    private func bookmarks(forTopic topic: String) -> [BookmarkedVocabulary] {
        filteredBookmarks.filter { tag(for: $0) == topic }
    }

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    // ===== Existing Sec 1–4 remains unchanged =====
                    Section {
                        bookmarkedWordsForLevel(level: .one)
                        bookmarkedWordsForLevel(level: .two)
                        bookmarkedWordsForLevel(level: .three)
                        bookmarkedWordsForLevel(level: .four)
                    } footer: {
                        Text("Swipe left to unbookmark")
                    }

                    // ===== New Topic Tags section =====
                    Section("按主题 · Topic Tags") {
                        // 6 fixed topics – always visible as headers (even if empty)
                        ForEach(BookmarkTagStore.predefined, id: \.self) { topic in
                            let items = bookmarks(forTopic: topic)
                            DisclosureGroup(topic) {
                                if items.isEmpty {
                                    Text("No bookmarks yet")
                                        .foregroundColor(.secondary)
                                        .font(.subheadline)
                                } else {
                                    ForEach(items, id: \.id) { bookmarkedVocab in
                                        bookmarkRow(bookmarkedVocab)
                                    }
                                }
                            }
                        }

                        // Custom topics created via “Other…”
                        if !customTopics.isEmpty {
                            ForEach(customTopics, id: \.self) { topic in
                                let items = bookmarks(forTopic: topic)
                                DisclosureGroup(topic) {
                                    if items.isEmpty {
                                        Text("No bookmarks yet")
                                            .foregroundColor(.secondary)
                                            .font(.subheadline)
                                    } else {
                                        ForEach(items, id: \.id) { bookmarkedVocab in
                                            bookmarkRow(bookmarkedVocab)
                                        }
                                    }
                                }
                            }
                            .onDelete { indexSet in
                                // Delete custom topic(s) and clear tags pointing to them
                                let topicsToRemove = indexSet.map { customTopics[$0] }

                                for t in topicsToRemove {
                                    for b in bookmarkManager.bookmarks {
                                        let key = BookmarkTagStore.key(for: b)
                                        if BookmarkTagStore.tag(forKey: key) == t {
                                            BookmarkTagStore.clearTag(forKey: key)
                                        }
                                    }
                                }

                                customTopics.remove(atOffsets: indexSet)
                                BookmarkTagStore.setCustomTopics(customTopics)
                                tagVersion += 1
                            }
                        }
                    }
                }
                // re-create list when tagVersion changes so groups refresh
                .id(tagVersion)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                .navigationTitle("Bookmarks")
                .toolbar {
                    EditButton() // allows delete for custom topics
                }
            }
        }
        // Listen for any UserDefaults changes (tags/custom topics) and refresh
        .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
            customTopics = BookmarkTagStore.customTopics()
            tagVersion += 1
        }
    }

    // Row used in both Level and Topic sections
    private func bookmarkRow(_ bookmarkedVocab: BookmarkedVocabulary) -> some View {
        VStack(alignment: .leading) {
            NavigationLink(destination: FlashcardView(
                vocabularies: loadVocabulariesFromJSON(
                    fileName: "中\(bookmarkedVocab.level.string)",
                    chapter: bookmarkedVocab.chapter.string,
                    topic: bookmarkedVocab.topic.string(level: bookmarkedVocab.level, chapter: bookmarkedVocab.chapter)
                ),
                level: bookmarkedVocab.level,
                chapter: bookmarkedVocab.chapter,
                topic: bookmarkedVocab.topic,
                currentIndex: bookmarkedVocab.currentIndex
            )) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(bookmarkedVocab.vocab.word)
                    HStack(spacing: 8) {
                        Text("\(bookmarkedVocab.level.filename) \(bookmarkedVocab.chapter.string)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        if let tag = BookmarkTagStore.tag(forKey: BookmarkTagStore.key(for: bookmarkedVocab)) {
                            Text("• \(tag)")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                    }
                }
            }
        }
        .swipeActions {
            Button(role: .destructive) {
                Task { await bookmarkManager.deleteBookmarkFromFirebase(id: bookmarkedVocab.id) }
                // Clear local tag mapping too
                BookmarkTagStore.clearTag(forKey: BookmarkTagStore.key(for: bookmarkedVocab))
                tagVersion += 1
            } label: {
                Label("Unbookmark", systemImage: "trash")
            }
        }
    }

    // ===== Existing Level grouping UI (unchanged) =====
    func bookmarkedWordsForLevel(level: SecondaryNumber) -> some View {
        DisclosureGroup(level.filename) {
            ForEach(filteredBookmarks.filter { $0.level == level }, id: \.id) { bookmarkedVocab in
                bookmarkRow(bookmarkedVocab)
            }
        }
    }
}

#Preview {
    BookmarkView()
        .environmentObject(BookmarkManager.shared)
}

