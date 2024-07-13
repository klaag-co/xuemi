//
//  BookmarkManager.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 13/7/24.
//

import Foundation

class BookmarkManager: ObservableObject {
    static let shared: BookmarkManager = .init()
    
    @Published var bookmarks: [String: [Vocabulary]] = [:] {
        didSet {
            save()
        }
    }
        
    init() {
        load()
    }
    
    func getArchiveURL() -> URL {
        let plistName = "bookmarks.plist"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        return documentsDirectory.appendingPathComponent(plistName)
    }
    
    func save() {
        let archiveURL = getArchiveURL()
        let propertyListEncoder = PropertyListEncoder()
        let encodedBookmarks = try? propertyListEncoder.encode(bookmarks)
        try? encodedBookmarks?.write(to: archiveURL, options: .noFileProtection)
    }
    
    func load() {
        let archiveURL = getArchiveURL()
        let propertyListDecoder = PropertyListDecoder()
                
        if let retrievedBookmarkData = try? Data(contentsOf: archiveURL),
            let bookmarksDecoded = try? propertyListDecoder.decode([String: [Vocabulary]].self, from: retrievedBookmarkData) {
            bookmarks = bookmarksDecoded
        }
    }
    
    func addBookmark(vocabulary: Vocabulary, level: String) {
        if bookmarks[level] == nil {
            bookmarks[level] = []
        }
        if !bookmarks[level]!.contains(where: { $0.index == vocabulary.index }) {
            bookmarks[level]!.append(vocabulary)
        }
    }
    
    func removeBookmark(vocabulary: Vocabulary, level: String) {
        bookmarks[level]?.removeAll(where: { $0.index == vocabulary.index })
    }
    
    func isBookmarked(vocabulary: Vocabulary, level: String) -> Bool {
        return bookmarks[level]?.contains(where: { $0.index == vocabulary.index }) ?? false
    }
}
