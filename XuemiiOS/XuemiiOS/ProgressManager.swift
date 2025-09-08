//
//  ProgressManager.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 30/7/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct ProgressState: Codable, Identifiable, Hashable {
    var id = UUID()
    var level: SecondaryNumber
    var chapter: Chapter
    var topic: Topic
    var currentIndex: Int
}

class ProgressManager: ObservableObject {
    static let shared: ProgressManager = .init()
    
    @Published var currentProgress: ProgressState? {
        didSet {
            save()
        }
    }

    // MARK: - Current user document id (uid preferred, else email)
    private var userDocId: String? {
        if let uid = Auth.auth().currentUser?.uid { return uid }
        if let email = AuthenticationManager.shared.email?
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return email
        }
        return nil
    }

    private func getArchiveURL() -> URL {
        let plistName = "progress.plist"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent(plistName)
    }
    
    private func save() {
        guard let currentProgress = currentProgress else { return }
        let archiveURL = getArchiveURL()
        let propertyListEncoder = PropertyListEncoder()
        if let encodedProgress = try? propertyListEncoder.encode(currentProgress) {
            try? encodedProgress.write(to: archiveURL, options: .noFileProtection)
        }
    }
    
    private func load() {
        let archiveURL = getArchiveURL()
        let propertyListDecoder = PropertyListDecoder()
        if let retrievedProgressData = try? Data(contentsOf: archiveURL),
           let decodedProgress = try? propertyListDecoder.decode(ProgressState.self, from: retrievedProgressData) {
            currentProgress = decodedProgress
        }
        Task { await getProgressFromFirebase() }
    }
    
    func updateProgress(level: SecondaryNumber, chapter: Chapter, topic: Topic, currentIndex: Int) {
        let newProgress = ProgressState(level: level, chapter: chapter, topic: topic, currentIndex: currentIndex)
        currentProgress = newProgress
        Task { await updateProgressOnFirebase(newProgress: newProgress) }
    }
    
    init() {
        load()
    }

    // MARK: firebase helpers

    private func getProgressFromFirebase() async {
        guard let uid = userDocId else { return }
        do {
            let userDoc = try await Firestore.firestore()
                .collection("users").document(uid)
                .getDocument()

            guard let data = userDoc.data(),
                  let progressData = data["progress"] as? [String: Any]
            else {
                print("Could not read progress from firebase")
                return
            }

            guard let idString = progressData["id"] as? String,
                  let id = UUID(uuidString: idString),
                  let levelInt = progressData["level"] as? Int,
                  let level = SecondaryNumber(rawValue: levelInt),
                  let chapterInt = progressData["chapter"] as? Int,
                  let chapter = Chapter(rawValue: chapterInt),
                  let topicInt = progressData["topic"] as? Int,
                  let topic = Topic(rawValue: topicInt),
                  let currentIndex = progressData["currentIndex"] as? Int
            else {
                print("Could not read fields of progress")
                return
            }

            let progress = ProgressState(
                id: id,
                level: level,
                chapter: chapter,
                topic: topic,
                currentIndex: currentIndex
            )

            await MainActor.run { self.currentProgress = progress }
        } catch {
            print("Error getting progress: \(error)")
        }
    }

    private func updateProgressOnFirebase(newProgress: ProgressState) async {
        guard let uid = userDocId else { return }

        let data: [String: Any] = [
            "id": newProgress.id.uuidString,
            "level": newProgress.level.rawValue,
            "chapter": newProgress.chapter.rawValue,
            "topic": newProgress.topic.rawValue,
            "currentIndex": newProgress.currentIndex
        ]

        do {
            try await Firestore.firestore()
                .collection("users").document(uid)
                .setData(["progress": data], merge: true)
            print("Progress updated on firebase")
            await getProgressFromFirebase()
        } catch {
            print("Error updating progress: \(error)")
        }
    }
}
