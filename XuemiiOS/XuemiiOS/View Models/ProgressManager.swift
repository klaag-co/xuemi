//
//  ProgressManager.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 19/6/26.
//

import SwiftUI
import FirebaseFirestore

@Observable
final class ProgressManager {

    private(set) var recentDecks: [ProgressState]?

    private let authManager: AuthManager
    private let settingsManager: SettingsManager

    init(authManager: AuthManager, settingsManager: SettingsManager) {
        self.authManager = authManager
        self.settingsManager = settingsManager
    }

    func load() {
        guard let uid = authManager.uid, let chineseLevel = settingsManager.chineseLevel else { return }

        Task {
            do {
                let snapshot = try await Firestore.firestore()
                    .collection("users")
                    .document(uid)
                    .collection("flashcardProgress-\(chineseLevel.rawValue)")
                    .order(by: "lastOpened", descending: true)
                    .limit(to: 5)
                    .getDocuments()

                guard settingsManager.chineseLevel == chineseLevel else { return }

                var progress: [ProgressState] = []

                for document in snapshot.documents {
                    guard
                        let level = document["level"] as? String,
                        let chapter = document["chapter"] as? String,
                        let topic = document["topic"] as? String,
                        let currentIndex = document["currentIndex"] as? Int
                    else {
                        continue
                    }

                    progress.append(
                        ProgressState(
                            level: level,
                            chapter: chapter,
                            topic: topic,
                            currentIndex: currentIndex
                        )
                    )
                }
                
                withAnimation {
                    recentDecks = progress
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func save(
        level: String,
        chapter: String,
        topic: String,
        currentIndex: Int
    ) async {
        guard let uid = authManager.uid, let chineseLevel = settingsManager.chineseLevel else { return }

        let documentID = "\(level)_\(chapter)_\(topic)"

        do {
            try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .collection("flashcardProgress-\(chineseLevel.rawValue)")
                .document(documentID)
                .setData([
                    "level": level,
                    "chapter": chapter,
                    "topic": topic,
                    "currentIndex": currentIndex,
                    "lastOpened": Date()
                ])

            try await trimToFive(uid: uid, chineseLevel: chineseLevel)

            load()
        } catch {
            print(error.localizedDescription)
        }
    }

    private func trimToFive(uid: String, chineseLevel: Vocabulary.ChineseLevel) async throws {
        let snapshot = try await Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("flashcardProgress-\(chineseLevel.rawValue)")
            .order(by: "lastOpened", descending: true)
            .getDocuments()

        for document in snapshot.documents.dropFirst(5) {
            try await document.reference.delete()
        }
    }
}
