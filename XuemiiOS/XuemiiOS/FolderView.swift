//
//  FolderView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 13/11/24.
//

import SwiftUI

struct Folder: Identifiable, Codable {
    let id: UUID
    let name: String
    let words: [String]

    init(id: UUID = UUID(), name: String, words: [String]) {
        self.id = id
        self.name = name
        self.words = words
    }
}

struct FolderView: View {
    @ObservedObject var vocabManager: VocabManager

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Fixed Folders")) {
                    NavigationLink(destination: VocabView(vocabManager: vocabManager)) {
                        Text("Vocabulary List")
                            .font(.headline)
                    }
                }
                Section(header: Text("Custom Folders")) {
                    if vocabManager.folders.isEmpty {
                        Text("No custom folders yet").foregroundColor(.gray)
                    } else {
                        ForEach(vocabManager.folders) { folder in
                            NavigationLink(destination: CustomFolderWordsView(folder: folder)) {
                                Text(folder.name)
                            }
                        }
                        .onDelete { indexSet in
                            vocabManager.folders.remove(atOffsets: indexSet)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Folders")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: NewFolderView(vocabManager: vocabManager)) {
                        Image(systemName: "folder.badge.plus")
                            .font(.title2)
                    }
                }
            }
        }
    }
}

struct CustomFolderWordsView: View {
    let folder: Folder

    var body: some View {
        List(folder.words, id: \.self) { word in
            Text(word)
        }
        .navigationTitle(folder.name)
    }
}



struct FolderDetailView: View {
    var folder: Folder

    var body: some View {
        List(folder.words, id: \.self) { word in
            Text(word)
        }
        .navigationTitle(folder.name)
    }
}

#Preview {
    FolderView(vocabManager: VocabManager())
}
