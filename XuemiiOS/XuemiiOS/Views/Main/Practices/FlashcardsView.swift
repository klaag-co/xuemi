//
//  FlashcardsView.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 14/6/26.
//

import SwiftUI

struct FlashcardsView: View {
    
    @Environment(ProgressManager.self) private var progressManager

    var level: String? = nil
    var chapter: String? = nil
    var topic: String? = nil
    
    var parentName: String? = nil
    let vocabularies: [Vocabulary]
    var initialIndex: Int = 0
    var folder: Folder? = nil

    @State private var currentIndex: Int?
    @State private var handwritingWord: String? = nil
    @State private var selectedVocabularyToBookmark: Vocabulary? = nil
    
    var body: some View {
        Group {
            if let parentName, #available(iOS 26.0, *) {
                main
                    .navigationSubtitle(parentName)
            } else {
                main
            }
        }
        .navigationTitle("Flashcards")
        .navigationBarTitleDisplayMode(.inline)
    }
    var main: some View {
        NavigationStack {
            VStack {
                Gauge(value: Double((currentIndex ?? 0) + 1) / Double(max(1, vocabularies.count))) {
                    EmptyView()
                }
                .tint(.accent)
                .animation(.bouncy, value: currentIndex)
                .padding(.horizontal)
                
                Spacer()
                
                if vocabularies.isEmpty {
                    ContentUnavailableView("Something Went Wrong", systemImage: "questionmark.circle.fill", description: Text("No vocabulary found, please try again later."))
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        CustomGlassEffectContainer {
                            LazyHStack {
                                ForEach(Array(vocabularies.enumerated()), id: \.offset) { (_, vocabulary) in
                                    FlashcardItem(
                                        vocabulary: vocabulary,
                                        folder: folder,
                                        handwritingWord: $handwritingWord,
                                        selectedVocabularyToBookmark: $selectedVocabularyToBookmark
                                    )
                                }
                            }
                            .scrollTargetLayout()
                        }
                    }
                    .scrollPosition(id: $currentIndex)
                    .scrollTargetBehavior(.viewAligned)
                    .safeAreaPadding(.horizontal, 32)
                }
                
                Spacer()
            }
            .sheet(item: $handwritingWord) { word in
                HandwritingView(word: word)
                    .presentationDetents([.medium, .large])
            }
            .sheet(item: $selectedVocabularyToBookmark) { vocabulary in
                AddToFolderView(vocabulary: vocabulary)
                    .presentationDetents([.medium, .large])
            }
            .onAppear {
                withAnimation {
                    currentIndex = initialIndex
                }
            }
            .onDisappear {
                guard let level, let chapter, let topic else { return }
                
                Task {
                    await progressManager.save(
                        level: level,
                        chapter: chapter,
                        topic: topic,
                        currentIndex: currentIndex ?? 0
                    )
                }
            }
        }
    }
}

