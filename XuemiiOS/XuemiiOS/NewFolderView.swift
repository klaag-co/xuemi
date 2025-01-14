//
//  NewFolderView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 20/11/24.
//

import SwiftUI

struct NewFolderView: View {
    @ObservedObject var vocabManager: VocabManager
    @State private var selectedWords: [Vocabulary] = []
    @State private var folderName: String = ""
    @State private var searchText: String = ""
    @State private var showingAlert = false
    @Environment(\.dismiss) var dismiss

    var filteredSections: [String: [Vocabulary]] {
        if searchText.isEmpty {
            return vocabManager.sections
        } else {
            return vocabManager.sections.mapValues { vocabs in
                vocabs.filter { $0.word.localizedCaseInsensitiveContains(searchText) }
            }.filter { !$0.value.isEmpty }
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Enter Folder Name", text: $folderName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                List {
                    ForEach(filteredSections.keys.sorted(), id: \.self) { section in
                        Section(header: Text(section)) {
                            ForEach(filteredSections[section]!, id: \.self) { vocab in
                                HStack {
                                    Text(vocab.word)
                                    Spacer()
                                    if selectedWords.contains(vocab) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                            .onTapGesture {
                                                selectedWords.removeAll { $0 == vocab }
                                            }
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundColor(.gray)
                                            .onTapGesture {
                                                selectedWords.append(vocab)
                                            }
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .searchable(text: $searchText, prompt: "Search words")

                Button("Save Folder") {
                    if folderName == "" {
                        showingAlert = true
                    }
                    else {
                        saveFolder()
                        dismiss()
                    }
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Empty folder name"), message: Text("Please enter a folder name."))
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationTitle("New Folder")
        }
    }

    func saveFolder() {
        guard !folderName.isEmpty && !selectedWords.isEmpty else { return }
        let newFolder = Folder(name: folderName, vocabs: selectedWords)
        vocabManager.addFolder(newFolder)
    }
}

#Preview {
    NewFolderView(vocabManager: VocabManager())
}
