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
    
    private let levels = ["中一", "中二", "中三", "中四"]
    
    private var filteredSections: [String: [Vocabulary]] {
        let all = vocabManager.sections
        
        guard !searchText.isEmpty else {
            return all
        }
        
        let filtered = all.mapValues { vocabs in
            vocabs.filter {
                $0.word.localizedCaseInsensitiveContains(searchText)
                || $0.pinyin.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(levels, id: \.self) { level in
                    Section(header: Text(level)) {
                        
                        let vocabs = filteredSections[level] ?? []
                        
                        if vocabs.isEmpty {
                            EmptyView()
                        } else {
                            ForEach(vocabs, id: \.index) { vocab in
                                Text(vocab.word)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search words"
            )
        }
        .navigationTitle("Vocabulary List")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: NewFolderView(vocabManager: vocabManager)) {
                    Image(systemName: "folder.badge.plus")
                }
            }
        }
        .onChange(of: searchText) { _, newValue in
            if newValue.isEmpty {
            }
        }
    }
}


#Preview {
    VocabView()
}
