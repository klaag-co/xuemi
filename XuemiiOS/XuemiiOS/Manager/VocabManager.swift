//
//  VocabManager.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 13/11/24.
//

import Foundation

class VocabManager: ObservableObject {
    @Published var sections: [String: [Vocabulary]] = [:] 
    @Published var folders: [Folder] = [] {
        didSet {
            saveFoldersToUserDefaults()
        }
    }

    private let foldersKey = "customFolders"

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
        } catch {
            print("Failed to save folders: \(error)")
        }
    }

    private func loadFoldersFromUserDefaults() {
        guard let data = UserDefaults.standard.data(forKey: foldersKey) else { return }
        do {
            let loadedFolders = try JSONDecoder().decode([Folder].self, from: data)
            self.folders = loadedFolders
        } catch {
            print("Failed to load folders: \(error)")
        }
    }

    func addFolder(_ folder: Folder) {
        folders.append(folder)
    }
}
