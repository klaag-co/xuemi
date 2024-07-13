//
//  FlashcardView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 19/6/24.
//

import SwiftUI

struct FlashcardView: View {
    @State private var currentSet: Int = 0
    var vocabularies: [Vocabulary]
    var level: SecondaryNumber
    var chapter: Chapter
    var topic: Topic
    
    @EnvironmentObject var bookmarkManager: BookmarkManager

    var body: some View {
        ZStack {
            VStack {
                ProgressView(value: Double(currentSet) / Double(vocabularies.count), total: 1)
                    .accentColor(.blue)
                    .padding(30)

                Spacer()

                if vocabularies.isEmpty {
                    Text("No vocabulary found")
                } else {
                    TabView {
                        ForEach(vocabularies, id: \.index) { vocab in
                            VStack(spacing: 0) {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(UIColor(red: 240/255, green: 248/255, blue: 255/255, alpha: 1)))
                                    .shadow(radius: 4)
                                    .overlay {
                                        VStack {
                                            HStack {
                                                Spacer()
                                                Text("中\(level.string): \(chapter.string) - \(topic.string)")
                                                    .font(.title3)
                                                    .fontWeight(.bold)
                                                Spacer()
                                                Button {
                                                    if !bookmarkManager.bookmarks.contains(where: { $0.vocab == vocab && $0.level == level && $0.chapter == chapter && $0.topic == topic }) {
                                                        bookmarkManager.bookmarks.append(BookmarkedVocabulary(vocab: vocab, level: level, chapter: chapter, topic: topic))
                                                    } else {
                                                        bookmarkManager.bookmarks.removeAll(where: { $0.vocab == vocab && $0.level == level && $0.chapter == chapter && $0.topic == topic})
                                                    }
                                                } label: {
                                                    Image(systemName: bookmarkManager.bookmarks.contains(where: { $0.vocab == vocab && $0.level == level && $0.chapter == chapter && $0.topic == topic }) ? "bookmark.fill" : "bookmark")
                                                }
                                            }
                                            .padding([.horizontal, .top], 30)
                                            Spacer()

                                            Text(vocab.word)
                                                .font(.system(size: 48))
                                                .fontWeight(.bold)

                                            Text(vocab.pinyin)
                                                .font(.largeTitle)
                                                .padding(.top, 5)

                                            VStack {
                                                Text(vocab.englishDefinition)
                                                Text(vocab.chineseDefinition)
                                                    .padding(.top, 5)
                                            }
                                            .font(.title3)
                                            .padding(.top)
                                            .multilineTextAlignment(.center)
                                            Spacer()
                                        }
                                        .padding(.horizontal)
                                    }
                            }
                            .padding(30)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }

                Spacer()
            }
        }
    }
}

#Preview {
    FlashcardView(vocabularies: [
        Vocabulary(index: 1, word: "hello", pinyin: "hi", englishDefinition: "hi", chineseDefinition: "hi", example: "hi"),
        Vocabulary(index: 2, word: "hi2", pinyin: "hi2", englishDefinition: "hi2", chineseDefinition: "hi2", example: "hi2")
    ], level: .one, chapter: .one, topic: .one)
    .environmentObject(BookmarkManager.shared)
}
