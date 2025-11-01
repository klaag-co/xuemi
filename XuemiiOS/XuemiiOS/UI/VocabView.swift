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
    
    var levels = ["中一", "中二", "中三", "中四"]
    
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
            List {
                ForEach(levels, id: \.self) { level in
                    Section(header: Text(level)) {
                        ForEach(filteredSections[level]!, id: \.self) { vocab in
                            Text(vocab.word)
                        }
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer (displayMode: .always), prompt: "Search words")
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
            searchText = ""
        }
    }
}


#Preview {
    VocabView()
}
