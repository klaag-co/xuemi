//
//  BookmarkManager.swift
//  XuemiiOS
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct BookmarkedVocabulary: Identifiable, Codable {
    var id: String
    var vocab: Vocabulary
    var level: SecondaryNumber
    var chapter: Chapter
    var topic: Topic
    var currentIndex: Int
}

final class BookmarkManager: ObservableObject {
    static let shared = BookmarkManager()

    @Published var bookmarks: [BookmarkedVocabulary] = [] {
        didSet { save() }
    }

    private init() { load() }

    // MARK: - Current user document id (uid preferred, else email)
    private var userDocId: String? {
        if let uid = Auth.auth().currentUser?.uid { return uid }
        if let email = AuthenticationManager.shared.email?
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return email
        }
        return nil
    }

    // MARK: - Local persistence (unchanged)
    private func archiveURL() -> URL {
        let plistName = "bookmarks.plist"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent(plistName)
    }

    private func save() {
        let encoder = PropertyListEncoder()
        if let data = try? encoder.encode(bookmarks) {
            try? data.write(to: archiveURL(), options: .noFileProtection)
        }
    }

    private func load() {
        let url = archiveURL()
        let decoder = PropertyListDecoder()
        if
            let data = try? Data(contentsOf: url),
            let decoded = try? decoder.decode([BookmarkedVocabulary].self, from: data)
        {
            bookmarks = decoded
            Task { await getBookmarksFromFirebase() }
        }
    }

    // MARK: - Firebase helpers

    func getBookmarksFromFirebase() async {
        guard let uid = userDocId else { return }
        do {
            let snap = try await Firestore.firestore()
                .collection("users").document(uid)
                .collection("bookmarks")
                .getDocuments()

            var loaded: [BookmarkedVocabulary] = []

            for doc in snap.documents {
                let d = doc.data()

                // Read enum indices safely -> cases
                func caseAtIndex<C: CaseIterable>(_ idx: Int, _: C.Type) -> C? {
                    let all = Array(C.allCases)
                    guard idx >= 0 && idx < all.count else { return nil }
                    return all[idx]
                }

                guard
                    let index = d["index"] as? Int,
                    let word = d["word"] as? String,
                    let pinyin = d["pinyin"] as? String,
                    let englishDefinition = d["englishDefinition"] as? String,
                    let chineseDefinition = d["chineseDefinition"] as? String,
                    let example = d["example"] as? String,
                    let questions = d["questions"] as? [String],
                    let levelIdx = d["level"] as? Int,
                    let chapterIdx = d["chapter"] as? Int,
                    let topicIdx = d["topic"] as? Int,
                    let currentIndex = d["currentIndex"] as? Int,
                    let level = caseAtIndex(levelIdx, SecondaryNumber.self),
                    let chapter = caseAtIndex(chapterIdx, Chapter.self),
                    let topic = caseAtIndex(topicIdx, Topic.self)
                else {
                    continue
                }

                let vocab = Vocabulary(
                    index: index,
                    word: word,
                    pinyin: pinyin,
                    englishDefinition: englishDefinition,
                    chineseDefinition: chineseDefinition,
                    example: example,
                    questions: questions
                )

                loaded.append(BookmarkedVocabulary(
                    id: doc.documentID,
                    vocab: vocab,
                    level: level,
                    chapter: chapter,
                    topic: topic,
                    currentIndex: currentIndex
                ))
            }

            await MainActor.run { self.bookmarks = loaded }
        } catch {
            print("Error getting bookmarks: \(error)")
        }
    }

    func addBookmarkToFirebase(bookmarkedVocabulary: BookmarkedVocabulary) async {
        guard let uid = userDocId else { return }

        // Convert enum cases to indices for storage
        func indexOf<C: CaseIterable & Equatable>(_ value: C) -> Int {
            Array(C.allCases).firstIndex(of: value) ?? 0
        }

        let data: [String: Any] = [
            "chapter": indexOf(bookmarkedVocabulary.chapter),
            "currentIndex": bookmarkedVocabulary.currentIndex,
            "level": indexOf(bookmarkedVocabulary.level),
            "topic": indexOf(bookmarkedVocabulary.topic),
            "index": bookmarkedVocabulary.vocab.index,
            "word": bookmarkedVocabulary.vocab.word,
            "pinyin": bookmarkedVocabulary.vocab.pinyin,
            "englishDefinition": bookmarkedVocabulary.vocab.englishDefinition,
            "chineseDefinition": bookmarkedVocabulary.vocab.chineseDefinition,
            "example": bookmarkedVocabulary.vocab.example,
            "questions": bookmarkedVocabulary.vocab.questions
        ]

        do {
            let ref = try await Firestore.firestore()
                .collection("users").document(uid)
                .collection("bookmarks").addDocument(data: data)
            print("Bookmark added with ID: \(ref.documentID)")
            await getBookmarksFromFirebase()
        } catch {
            print("Error adding bookmark: \(error)")
        }
    }

    func deleteBookmarkFromFirebase(id: String) async {
        guard let uid = userDocId else { return }
        do {
            try await Firestore.firestore()
                .collection("users").document(uid)
                .collection("bookmarks").document(id).delete()
            print("Bookmark deleted")
            await getBookmarksFromFirebase()
        } catch {
            print("Error deleting bookmark: \(error)")
        }
    }
}

