//
//  MemoryCardsResultsView.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 17/6/26.
//

import SwiftUI

struct MemoryCardsResultsView: View {
    
    // Folder name for folders, if for normal chapters and shii use "level • chapterName • topic"
    @State var parentName: String
    @State var tries: Int
    @State var cards: [MemoryCard]
        
    var body: some View {
        Group {
            if #available(iOS 26.0, *) {
                main
                    .navigationSubtitle(parentName)
            } else {
                main
            }
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.large)
    }
    
    var main: some View {
        List {
            Section {
                VStack(alignment: .leading) {
                    Text("\(tries)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .monospacedDigit()
                    Text("tries")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Section("Cards") {
                ForEach(cards) { card in
                    NavigationLink {
                        FlashcardsView(vocabularies: [card.vocab])
                    } label: {
                        VStack(alignment: .leading) {
                            Text(card.vocab.word)
                                .font(.headline)
                            Text(card.vocab.pinyin)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
}
