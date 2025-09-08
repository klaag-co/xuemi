//
//  VocabManager.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 13/11/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class VocabManager: ObservableObject {
    @Published var sections: [String: [Vocabulary]] = [:] 
    @Published var folders: [Folder] = [] {
        didSet {
            saveFoldersToUserDefaults()
        }
    }

    private let foldersKey = "customFolders"

    // MARK: - Current user document id (uid preferred, else email)
    private var userDocId: String? {
        if let uid = Auth.auth().currentUser?.uid { return uid }
        if let email = AuthenticationManager.shared.email?
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return email
        }
        return nil
    }

    init() {
        loadVocabularies()
        loadFoldersFromUserDefaults()
    }

    func loadVocabularies() {
        var vocabSections: [String : [Vocabulary]] = [:]

        for secondary in SecondaryNumber.allCases {
            for chapter in Chapter.allCases {
                for topic in Topic.allCases {
                    if let currentVocab = vocabSections[secondary.filename] {
                        vocabSections[secondary.filename] = currentVocab + loadVocabulariesFromJSON(fileName: secondary.filename, chapter: chapter.string, topic: topic.string(level: secondary, chapter: chapter))
                    } else {
                        vocabSections[secondary.filename] = loadVocabulariesFromJSON(fileName: secondary.filename, chapter: chapter.string, topic: topic.string(level: secondary, chapter: chapter))
                    }
                }
            }
        }

        self.sections = vocabSections
    }

    private func saveFoldersToUserDefaults() {
        do {
            let data = try JSONEncoder().encode(folders)
            UserDefaults.standard.set(data, forKey: foldersKey)
            Task { await updateFoldersOnFirebase(newFoldersData: data) }
        } catch {
            print("Failed to save folders: \(error)")
        }
    }

    private func loadFoldersFromUserDefaults() {
        do {
            if let data = UserDefaults.standard.data(forKey: foldersKey) {
                let loadedFolders = try JSONDecoder().decode([Folder].self, from: data)
                self.folders = loadedFolders
            }
        } catch {
            print("Failed to load folders: \(error)")
        }
        Task { await getFoldersFromFirebase() }
    }

    func addFolder(_ folder: Folder) {
        folders.append(folder)
    }

    // MARK: firebase helper functions
    // NOTE: we save documents as B64 data because i am truly not bothered to
    // do the json exploration for a collection and this works decently well anyway.
    private func getFoldersFromFirebase() async {
        guard let uid = userDocId else { return }
        do {
            let userDoc = try await Firestore.firestore()
                .collection("users").document(uid)
                .getDocument()

            guard let data = userDoc.data(),
                  let foldersDataString = data[foldersKey] as? String
            else {
                print("Could not read folders from firebase")
                return
            }

            guard let foldersData = Data(base64Encoded: foldersDataString),
                  let folders = try? JSONDecoder().decode([Folder].self, from: foldersData)
            else {
                print("Could not decode folders data")
                return
            }

            await MainActor.run { self.folders = folders }
        } catch {
            print("Error getting folders: \(error)")
        }
    }

    private func updateFoldersOnFirebase(newFoldersData: Data) async {
        guard let uid = userDocId else { return }

        do {
            try await Firestore.firestore()
                .collection("users").document(uid)
                .setData([foldersKey: newFoldersData.base64EncodedString()], merge: true)
            print("Folders updated on firebase")
        } catch {
            print("Error updating folders: \(error)")
        }
    }
}
