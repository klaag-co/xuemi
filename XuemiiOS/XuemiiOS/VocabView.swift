//
//  VocabView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 12/11/24.
//

import SwiftUI

struct VocabView: View {
    @ObservedObject var vocabManager = VocabManager()
    @State private var searchText = ""
    
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
                TextField("Search words", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
            }
            List {
                ForEach(filteredSections.keys.sorted(), id: \.self) { section in
                    Section(header: Text(section)) {
                        ForEach(filteredSections[section]!, id: \.self) { vocab in
                            Text(vocab.word)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden) 
        }
        .navigationTitle("Vocabulary List")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: NewFolderView(vocabManager: vocabManager)) {
                    Image(systemName: "folder.badge.plus")
                }
            }
        }
        .onAppear {
            searchText = "" // Reset search text to avoid residual state
        }
    }
}


#Preview {
    VocabView()
}
