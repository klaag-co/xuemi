//
//  BookmarkManager.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 13/7/24.
//

import Foundation

struct BookmarkedVocabulary: Identifiable, Codable {
    var id = UUID()
    var vocab: Vocabulary
    var level: SecondaryNumber
    var chapter: Chapter
    var topic: Topic
}

class BookmarkManager: ObservableObject {
    static let shared: BookmarkManager = .init()
    
    @Published var bookmarks: [BookmarkedVocabulary] = [] {
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
            let bookmarksDecoded = try? propertyListDecoder.decode([BookmarkedVocabulary].self, from: retrievedBookmarkData) {
            bookmarks = bookmarksDecoded
        }
    }
}
