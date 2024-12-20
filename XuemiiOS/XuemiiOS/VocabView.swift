//
//  VocabView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 12/11/24.
//

import SwiftUI

struct VocabView: View {
    @ObservedObject var vocabManager = VocabManager()

    var body: some View {
        List {
            ForEach(vocabManager.sections.keys.sorted(), id: \.self) { section in
                Section(header: Text(section)) {
                    ForEach(vocabManager.sections[section]!, id: \.self) { vocab in
                        Text(vocab.word)
                    }
                }
            }
        }
        .navigationTitle("Vocabulary List")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: NewFolderView(vocabManager: vocabManager)) {
                    Image(systemName: "folder.badge.plus")
                }
            }
        }
    }
}


#Preview {
    VocabView()
}
