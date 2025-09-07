//
//  FolderView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 13/11/24.
//

import SwiftUI

struct Folder: Identifiable, Codable, Hashable {
    var id = UUID()
    let name: String
    let vocabs: [Vocabulary]
}

struct FolderView: View {
    @ObservedObject var vocabManager: VocabManager
    
    @State private var showSpeaker = false
    @State private var showContents = false
    @State private var selectedFolder: Folder?
    @State private var selectedFolderForMCQView: Folder?
    @State private var selectedFolderForSpeakerView: Folder?
    @State private var selectedFolderForContentsView: Folder?

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Fixed Folders")) {
                    NavigationLink(destination: VocabView(vocabManager: vocabManager)) {
                        Text("Vocabulary List")
                            .font(.headline)
                    }
                    NavigationLink(destination: BookmarkView()) {
                        Text("Bookmarks")
                            .font(.headline)
                    }
                }
                Section(header: Text("Custom Folders")) {
                    if vocabManager.folders.isEmpty {
                        Text("No custom folders yet").foregroundColor(.gray)
                    } else {
                        ForEach(vocabManager.folders) { folder in
//                            NavigationLink(destination: CustomFolderWordsView(folder: folder)) {
//                                Text(folder.name)
                            Button (action: {
                                selectedFolder = folder
                            }) {
                                Text(folder.name)
                                    .foregroundStyle(.black)
                            }
                        }
                        .onDelete { indexSet in
                            vocabManager.folders.remove(atOffsets: indexSet)
                        }
                        .sheet(item: $selectedFolder) { folder in
                            NavigationStack {
                                VStack {
                                    Button {
                                        selectedFolder = nil
                                        selectedFolderForMCQView = folder
                                    } label: {
                                        Text("MCQ")
                                            .font(.title)
                                            .padding()
                                            .frame(height: 65)
                                            .frame(maxWidth: .infinity)
                                            .foregroundStyle(.black)
                                            .background(.customgray)
                                            .mask(RoundedRectangle(cornerRadius: 16))
                                            .padding(.horizontal)
                                    }
                                    
                                    Button {
                                        selectedFolder = nil
                                        selectedFolderForSpeakerView = folder
                                    } label: {
                                        Text("Pronounciation")
                                            .font(.title)
                                            .padding()
                                            .frame(height: 65)
                                            .frame(maxWidth: .infinity)
                                            .foregroundStyle(.black)
                                            .background(.customgray)
                                            .mask(RoundedRectangle(cornerRadius: 16))
                                            .padding(.horizontal)
                                    }
                                    
                                    Button {
                                        selectedFolder = nil
                                        selectedFolderForContentsView = folder
                                    } label: {
                                        Text("Contents")
                                            .font(.title)
                                            .padding()
                                            .frame(height: 65)
                                            .frame(maxWidth: .infinity)
                                            .foregroundStyle(.black)
                                            .background(.customgray)
                                            .mask(RoundedRectangle(cornerRadius: 16))
                                            .padding(.horizontal)
                                    }
                                }
                                .navigationTitle("习题")
                            }
                            .presentationDetents([.medium])
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Folders")
            .navigationDestination(item: $selectedFolderForSpeakerView) { folder in
                       SpeakerView(words: folder.vocabs)
                   }

            .navigationDestination(item: $selectedFolderForMCQView) { folder in
                MCQView(vocabularies: folder.vocabs, folderName: folder.name)
            }
            .navigationDestination(item: $selectedFolderForContentsView) { folder in
                ContentsView(folder: folder)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: NewFolderView(vocabManager: vocabManager)) {
                        Image(systemName: "folder.badge.plus")
                    }
                }
            }
        }
    }
}

struct CustomFolderWordsView: View {
    let folder: Folder

    var body: some View {
        List(folder.vocabs, id: \.self) { vocab in
            Text(vocab.word)
        }
        .navigationTitle(folder.name)
    }
}



struct FolderDetailView: View {
    var folder: Folder

    var body: some View {
        List(folder.vocabs, id: \.self) { vocab in
            Text(vocab.word)
        }
        .navigationTitle(folder.name)
    }
}

#Preview {
    FolderView(vocabManager: VocabManager())
}
