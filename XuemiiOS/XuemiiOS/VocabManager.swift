//
//  VocabManager.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 13/11/24.
//

import Foundation

class VocabManager: ObservableObject {
    @Published var sections: [String: [String]] = [:] 
    @Published var folders: [Folder] = [] {
        didSet {
            saveFoldersToUserDefaults()
        }
    }

    private let foldersKey = "customFolders"

    init() {
        loadVocabularyFromJSON()
        loadFoldersFromUserDefaults()
    }

    // Load Vocabulary List from JSON
    func loadVocabularyFromJSON() {
        guard let url = Bundle.main.url(forResource: "vocabxuemi", withExtension: "json") else {
            print("JSON file not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decodedData = try JSONDecoder().decode([String: [String]].self, from: data)
            self.sections = decodedData
        } catch {
            print("Error loading JSON: \(error)")
        }
    }

    // Save Folders to UserDefaults
    private func saveFoldersToUserDefaults() {
        do {
            let data = try JSONEncoder().encode(folders)
            UserDefaults.standard.set(data, forKey: foldersKey)
        } catch {
            print("Failed to save folders: \(error)")
        }
    }

    // Load Folders from UserDefaults
    private func loadFoldersFromUserDefaults() {
        guard let data = UserDefaults.standard.data(forKey: foldersKey) else { return }
        do {
            let loadedFolders = try JSONDecoder().decode([Folder].self, from: data)
            self.folders = loadedFolders
        } catch {
            print("Failed to load folders: \(error)")
        }
    }

    // Add a new folder
    func addFolder(_ folder: Folder) {
        folders.append(folder)
    }
}
