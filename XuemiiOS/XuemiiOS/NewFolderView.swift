//
//  NewFolderView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 20/11/24.
//

import SwiftUI

struct NewFolderView: View {
    @ObservedObject var vocabManager: VocabManager
    @State private var selectedWords: [String] = []
    @State private var folderName: String = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Enter Folder Name", text: $folderName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                List {
                    ForEach(vocabManager.sections.keys.sorted(), id: \.self) { section in
                        Section(header: Text(section)) {
                            ForEach(vocabManager.sections[section]!, id: \.self) { word in
                                HStack {
                                    Text(word)
                                    Spacer()
                                    if selectedWords.contains(word) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                            .onTapGesture {
                                                selectedWords.removeAll { $0 == word }
                                            }
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundColor(.gray)
                                            .onTapGesture {
                                                selectedWords.append(word)
                                            }
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())

                Button("Save Folder") {
                    saveFolder()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationTitle("New Folder")
        }
    }

    func saveFolder() {
        guard !folderName.isEmpty && !selectedWords.isEmpty else { return }
        let newFolder = Folder(name: folderName, words: selectedWords)
        vocabManager.addFolder(newFolder)
    }
}


#Preview {
    NewFolderView(vocabManager: VocabManager())
}
