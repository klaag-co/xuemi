//
//  BookmarkManager.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 13/7/24.
//

import SwiftUI
import FirebaseFirestore

struct BookmarkedVocabulary: Identifiable, Codable {
    var id: String
    var vocab: Vocabulary
    var level: SecondaryNumber
    var chapter: Chapter
    var topic: Topic
    var currentIndex: Int
}

class BookmarkManager: ObservableObject {
    static let shared: BookmarkManager = .init()
    @ObservedObject var authManager = AuthenticationManager.shared
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
            Task {
                await getBookmarksFromFirebase()
            }
        }
    }
    
    func getBookmarksFromFirebase() async {
        do {
            let querySnapshot = try await Firestore.firestore().collection("users").document(authManager.userID!).collection("bookmarks").getDocuments()
            var bookmarksInternal: [BookmarkedVocabulary] = []
            for document in querySnapshot.documents {
                bookmarksInternal.append(
                    BookmarkedVocabulary(
                        id: document.documentID,
                        vocab: Vocabulary(
                            index: document.data()["index"] as! Int,
                            word: document.data()["word"] as! String,
                            pinyin: document.data()["pinyin"] as! String,
                            englishDefinition: document.data()["englishDefinition"] as! String,
                            chineseDefinition: document.data()["chineseDefinition"] as! String,
                            example: document.data()["example"] as! String,
                            questions: document.data()["questions"] as! [String]
                        ),
                        level: SecondaryNumber(rawValue: document.data()["level"] as! Int)!,
                        chapter: Chapter(rawValue: document.data()["chapter"] as! Int)!,
                        topic: Topic(rawValue: document.data()["topic"] as! Int)!,
                        currentIndex: document.data()["currentIndex"] as! Int
                    )
                )
          }
            bookmarks = bookmarksInternal
        } catch {
          print("Error getting documents: \(error)")
        }
    }
    
    func addBookmarkToFirebase(bookmarkedVocabulary: BookmarkedVocabulary) async {
        do {
            let ref = try await Firestore.firestore().collection("users").document(authManager.userID!).collection("bookmarks").addDocument(data: [
                "chapter": bookmarkedVocabulary.chapter.rawValue,
                "currentIndex": bookmarkedVocabulary.currentIndex,
                "level" : bookmarkedVocabulary.level.rawValue,
                "topic" : bookmarkedVocabulary.topic.rawValue,
                "index" : bookmarkedVocabulary.vocab.index,
                "word" : bookmarkedVocabulary.vocab.word,
                "pinyin" : bookmarkedVocabulary.vocab.pinyin,
                "englishDefinition" : bookmarkedVocabulary.vocab.englishDefinition,
                "chineseDefinition" : bookmarkedVocabulary.vocab.chineseDefinition,
                "example" : bookmarkedVocabulary.vocab.example,
                "questions" : bookmarkedVocabulary.vocab.questions
          ])
            await getBookmarksFromFirebase()
          print("Document added with ID: \(ref.documentID)")
        } catch {
          print("Error adding document: \(error)")
        }
    }
    
    func deleteBookmarkFromFirebase(id: String) async {
        do {
            try await Firestore.firestore().collection("users").document(authManager.userID!).collection("bookmarks").document(id).delete()
          print("Document successfully removed!")
            await getBookmarksFromFirebase()
        } catch {
          print("Error removing document: \(error)")
        }
    }
}
