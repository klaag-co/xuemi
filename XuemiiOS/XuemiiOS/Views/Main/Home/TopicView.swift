//
//  TopicView.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 18/6/26.
//

import SwiftUI

struct TopicView: View {
    @Environment(VocabularyManager.self) private var vocabManager
    let level: String
    let chapter: String
    
    @State private var showingSheet: Topic? = nil
    @State private var selectedTopicForMCQView: Topic? = nil
    @State private var selectedTopicForFlashcardsView: Topic? = nil
    @State private var selectedTopicForSpellingView: Topic? = nil
    @State private var selectedTopicForMemoryCardView: Topic? = nil
    
    var body: some View {
        ScrollView {
            Text("\(chapter)")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .padding()
                .frame(height: 80)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
                .background(.customBlue)
                .mask(RoundedRectangle(cornerRadius: 24))
                .padding([.horizontal, .bottom])
            
            ForEach(vocabManager.topics(for: level, chapter: chapter), id: \.self) { topic in
                Button {
                    showingSheet = Topic(parentName: "\(level) • \(chapter) • \(topic)", vocabularies: vocabManager.vocabularies(for: level, chapter: chapter, topic: topic))
                } label: {
                    VStack(alignment: .leading) {
                        Text(topic)
                            .font(.title)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .padding()
                            .frame(height: 65)
                            .frame(maxWidth: .infinity)
                            .tint(.primary)
                            .background(Color(.secondarySystemBackground))
                            .mask(RoundedRectangle(cornerRadius: 24))
                            .padding(.horizontal)
                    }
                }
            }
        }
        .navigationTitle("\(level)")
        .sheet(item: $showingSheet) { _ in
            PracticeModeSelectionView(
                selectedTopic: $showingSheet,
                selectedTopicForMCQView: $selectedTopicForMCQView,
                selectedTopicForFlashcardsView: $selectedTopicForFlashcardsView,
                selectedTopicForSpellingView: $selectedTopicForSpellingView,
                selectedTopicForMemoryCardView: $selectedTopicForMemoryCardView
            )
            .presentationDetents([.medium])
        }
        .navigationDestination(item: $selectedTopicForMCQView) { topic in
            MCQView(parentName: topic.parentName, vocabularies: topic.vocabularies)
        }
        .navigationDestination(item: $selectedTopicForFlashcardsView) { topic in
            FlashcardsView(
                level: level,
                chapter: chapter,
                topic: topic.vocabularies.first?.topicName ?? "",
                parentName: topic.parentName,
                vocabularies: topic.vocabularies
            )
        }
        .navigationDestination(item: $selectedTopicForSpellingView) { topic in
            SpellingView(parentName: topic.parentName, vocabularies: topic.vocabularies)
        }
        .navigationDestination(item: $selectedTopicForMemoryCardView) { topic in
            MemoryCardView(parentName: topic.parentName, vocabularies: topic.vocabularies)
        }
    }
}

#Preview {
    TopicView(level: "67", chapter: "hi")
}
