//
//  FoldersManager.swift
//  Xuemi
//
//  Created by Tristan Chay on 14/6/26.
//

import SwiftUI
import FirebaseFirestore

@Observable
class FoldersManager {
    private(set) var folders: [Folder]
    private var authManager: AuthManager
    private var vocabManager: VocabularyManager
    private var settingsManager: SettingsManager
    
    init(authManager: AuthManager, vocabManager: VocabularyManager, settingsManager: SettingsManager) {
        self.authManager = authManager
        self.vocabManager = vocabManager
        self.settingsManager = settingsManager
        self.folders = []
    }
    
    func load() {
        guard let uid = authManager.uid, let chineseLevel = settingsManager.chineseLevel else { return }
        var folders: [Folder] = []
        
        Task {
            do {
                let snapshot = try await foldersCollection(uid: uid, chineseLevel: chineseLevel)
                    .order(by: "dateCreated", descending: true)
                    .getDocuments()
                if !snapshot.isEmpty {
                    snapshot.documents.forEach { document in
                        let folderName = document.data()["folderName"] as? String
                        let vocabularyIds = document.data()["vocabularyIds"] as? [String]
                        if let folderName, let vocabularyIds {
                            let vocabularies = vocabManager.mapVocabIdsToVocabs(for: vocabularyIds)
                            folders.append(
                                Folder(
                                    id: document.documentID,
                                    title: folderName,
                                    vocabularies: vocabularies
                                )
                            )
                        }
                    }
                }
                
                guard settingsManager.chineseLevel == chineseLevel else { return }
                
                withAnimation {
                    self.folders = folders
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func addFolder(title: String, vocabularies: [Vocabulary]) async {
        guard let uid = authManager.uid, let chineseLevel = settingsManager.chineseLevel else { return }
        do {
            try await foldersCollection(uid: uid, chineseLevel: chineseLevel).addDocument(data: [
                "dateCreated" : Date(),
                "folderName" : title,
                "vocabularyIds" : vocabularies.map(\.id)
            ])
            load()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateFolder(folder: Folder) async {
        guard let uid = authManager.uid, let chineseLevel = settingsManager.chineseLevel else { return }
        do {
            try await foldersCollection(uid: uid, chineseLevel: chineseLevel).document(folder.id).updateData([
                "folderName" : folder.title,
                "vocabularyIds" : folder.vocabularies.map(\.id)
            ])
            load()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func removeFolder(id: String) {
        guard let uid = authManager.uid, let chineseLevel = settingsManager.chineseLevel else { return }

        Task {
            do {
                try await foldersCollection(uid: uid, chineseLevel: chineseLevel).document(id).delete()
                withAnimation {
                    folders.removeAll(where: { $0.id == id })
                }
                load()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func addToFolder(vocabulary: Vocabulary, folder: Folder) async {
        await updateFolder(folder: folder)
    }
    
    func removeFromFolder(vocabulary: Vocabulary, folder: Folder) async {
        var folder = folder
        folder.vocabularies.removeAll(where: { $0 == vocabulary })
        await updateFolder(folder: folder)
    }
    
    func isBookmarked(vocabulary: Vocabulary) -> Bool {
        var isBookmarked = false
        folders.forEach { folder in
            if folder.vocabularies.contains(vocabulary) {
                isBookmarked = true
            }
        }
        return isBookmarked
    }
    
    private func foldersCollection(uid: String, chineseLevel: Vocabulary.ChineseLevel) -> CollectionReference {
        Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("folders-\(chineseLevel.rawValue)")
    }
}
