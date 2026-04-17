//
//  ContentsView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 20/12/24.
//

import SwiftUI

struct ContentsView: View {
    var folder: Folder

    var body: some View {
        VStack {
            Text(folder.name)
                .font(.largeTitle)
                .bold()
                .padding()

            List(folder.vocabs, id: \.id) { vocab in
                NavigationLink(destination: FlashcardView(vocabularies: folder.vocabs, currentIndex: getIndexForVocab(vocab))){
                    VStack(alignment: .leading) {
                        Text(vocab.word)
                            .font(.headline)
                        Text("Pinyin: \(vocab.pinyin)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Contents")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func getIndexForVocab (_ vocab: Vocabulary) -> Int? {
        folder.vocabs.firstIndex(of: vocab)
    }
}
