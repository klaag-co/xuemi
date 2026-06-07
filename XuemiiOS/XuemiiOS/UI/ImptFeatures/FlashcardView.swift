//
//  FlashcardView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 30/5/24.
//

import SwiftUI
import AVFoundation

public struct FlashcardView: View {
    @State private var currentSet: Int = 0
    var vocabularies: [Vocabulary]
    var level: SecondaryNumber?
    var chapter: Chapter?
    var topic: Topic?
    var folderName: String?
    var currentIndex: Int?

    // UI state
    @State private var selection: Int? = 0
    @State private var spellingText: String? = nil
    @State private var isLargeDevice: Bool
    @State private var showTagSheet = false
    @State private var pendingTagWord: String? = nil
    @State private var selectedTag: String = ""

    // Tag chooser state
    @State private var showTagMenu = false
    @State private var showCustomTagPrompt = false
    @State private var customTagInput = ""
    @State private var pendingWordForTag: String? = nil   // which vocab we’re tagging

    @ObservedObject private var bookmarkManager: BookmarkManager = .shared
    @ObservedObject private var progressManager: ProgressManager = .shared
    private var synthesizer = AVSpeechSynthesizer()

    init(
        vocabularies: [Vocabulary],
        level: SecondaryNumber? = nil,
        chapter: Chapter? = nil,
        topic: Topic? = nil,
        folderName: String? = nil,
        currentIndex: Int? = nil
    ) {
        self.vocabularies = vocabularies
        self.level = level
        self.chapter = chapter
        self.topic = topic
        self.folderName = folderName
        self.currentIndex = currentIndex
        self._isLargeDevice = State(initialValue: UIScreen.main.bounds.height > 800)
    }

    public var body: some View {
        ZStack {
            VStack {
                ProgressView(
                    value: Double(selection ?? 0) / Double(max(1, vocabularies.count - 1)),
                    total: 1
                )
                .accentColor(.blue)
                .padding(30)
                .animation(.default, value: selection)

                Spacer()

                if vocabularies.isEmpty {
                    Text("No vocabulary found")
                } else {
                    GeometryReader { _ in
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 0) {
                                ForEach(Array(vocabularies.enumerated()), id: \.offset) { (_, vocab) in
                                    viewForCard(vocab: vocab)
                                }
                            }
                            .scrollTargetLayout()
                        }
                        .scrollPosition(id: $selection)
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .safeAreaPadding(.horizontal, 25)
                }
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $spellingText) { text in
            StrokeWriteView(word: text)
        }
        .sheet(isPresented: $showTagSheet) {
            NavigationStack {
                List {
                    Section("Save to topic tag?") {
                        
                        ForEach(BookmarkTagStore.predefined, id: \.self) { tag in
                            Button {
                                selectedTag = tag
                            } label: {
                                HStack {
                                    Text(tag)
                                    
                                    Spacer()
                                    
                                    if selectedTag == tag {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            .foregroundStyle(.primary)
                        }
                        
                        ForEach(BookmarkTagStore.customTopics(), id: \.self) { tag in
                            Button {
                                selectedTag = tag
                            } label: {
                                HStack {
                                    Text(tag)
                                    
                                    Spacer()
                                    
                                    if selectedTag == tag {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            .foregroundStyle(.primary)
                        }
                        
                        Button("加主题…") {
                            showCustomTagPrompt = true
                        }
                    }
                }
                Button {
                    if !selectedTag.isEmpty {
                        applyTag(selectedTag)
                    }
                    showTagSheet = false
                } label: {
                    Text(selectedTag.isEmpty ? "Skip" : "Save")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(.white)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                }
                .navigationTitle("Bookmarked ✅")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showTagSheet = false
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .presentationDetents([.large])
        }
        .alert("输入自定义主题", isPresented: $showCustomTagPrompt) {
            TextField("e.g. 校园生活", text: $customTagInput)
            Button("保存") {
                let name = customTagInput.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !name.isEmpty else { return }
                BookmarkTagStore.addCustomTopic(name)
                selectedTag = name
                customTagInput = ""
            }
            Button("取消", role: .cancel) {
                customTagInput = ""
            }
        } message: {
            Text("请输入一个主题名称")
        }

        .onDisappear {
            if let selection, let level, let chapter, let topic, topic != .eoy {
                progressManager.updateProgress(
                    level: level,
                    chapter: chapter,
                    topic: topic,
                    currentIndex: selection
                )
                LastProgressStore.set(level: level, chapter: chapter, topic: topic, currentIndex: selection)
            }
        }
        .onAppear {
            if let currentIndex = currentIndex {
                withAnimation { selection = currentIndex }
            }
        }
    }

    private func applyTag(_ tag: String) {
        guard
            let level,
            let chapter,
            let topic,
            let word = pendingWordForTag
        else { return }
        
        let key = BookmarkTagStore.key(
            word: word,
            level: level,
            chapter: chapter,
            topic: topic
        )
        
        BookmarkTagStore.setTag(tag, forKey: key)
    }


    private func viewForCard(vocab: Vocabulary) -> some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor(red: 240/255, green: 248/255, blue: 255/255, alpha: 1)))
                .shadow(radius: 4)
                .padding(.vertical)
                .padding(.horizontal, 5)
                .containerRelativeFrame(.horizontal)
                .overlay {
                    VStack {
                        // Header
                        HStack {
                            Spacer()
                            if let level, let chapter, let _ = topic {
                                Text("中\(level.string): \(chapter.string)")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.6)
                                    .font(.title3)
                                    .fontWeight(.bold)
                            } else if let folderName, !folderName.isEmpty {
                                Text(folderName)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.6)
                                    .font(.title3)
                                    .fontWeight(.bold)
                            }
                            Spacer()

                            if let level, let chapter, let topic {
                                let isBookmarked = bookmarkManager.bookmarks.contains {
                                    $0.vocab.word == vocab.word &&
                                    $0.level == level &&
                                    $0.chapter == chapter &&
                                    $0.topic == topic
                                }

                                Button {
                                    pendingWordForTag = vocab.word
                                    handleBookmarkTap(vocab: vocab, level: level, chapter: chapter, topic: topic)
                                } label: {
                                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                        .font(.system(size: 20))
                                }
                            }
                        }
                        .padding([.horizontal, .top], 30)
                        Spacer()
                        
                        HStack {
                            Spacer()
                            Text("Click the word to practice handwriting!")
                                .font(.system(size: 10))
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 10)
                            Spacer()
                        }
                        
                        VStack {
                            Text(vocab.word)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                                .font(.system(size: 48))
                                .underline()
                                .fontWeight(.bold)
                                .onTapGesture { spellingText = vocab.word }
                        }

                        HStack {
                            Text(vocab.pinyin)
                                .lineLimit(2)
                                .minimumScaleFactor(0.6)
                                .font(.largeTitle)
                            Button {
                                let utterance = AVSpeechUtterance(string: vocab.word)
                                if let voice = AVSpeechSynthesisVoice.speechVoices().first(where: { $0.language == "zh-CN" }) {
                                    utterance.voice = voice
                                } else {
                                    utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
                                }
                                utterance.rate = 0.5
                                synthesizer.speak(utterance)
                            } label: {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.blue)
                                    .padding(.leading, 5)
                            }
                        }
                        .padding(.top, 5)
                        
                        VStack {
                            Text(vocab.chineseDefinition)
                                .lineLimit(4)
                                .minimumScaleFactor(0.6)
                            Text(vocab.englishDefinition)
                                .lineLimit(4)
                                .minimumScaleFactor(0.6)
                                .padding(.top, 5)
                                .padding(.bottom, 10)
                        }
                        .font(.title3)
                        .padding(.top)
                        .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .padding(.horizontal)
                }
        }
    }

    private func handleBookmarkTap(vocab: Vocabulary, level: SecondaryNumber, chapter: Chapter, topic: Topic) {
        let exists = bookmarkManager.bookmarks.contains {
            $0.vocab.word == vocab.word &&
            $0.level == level &&
            $0.chapter == chapter &&
            $0.topic == topic
        }

        if exists {
            Task {
                await bookmarkManager.deleteBookmarkFromFirebase(id: bookmarkManager.bookmarks.first {
                    $0.vocab.word == vocab.word &&
                    $0.level == level &&
                    $0.chapter == chapter &&
                    $0.topic == topic
                }!.id)
            }
          
        } else {
            Task {
                await bookmarkManager.addBookmarkToFirebase(
                    bookmarkedVocabulary: BookmarkedVocabulary(
                        id: "",
                        vocab: vocab,
                        level: level,
                        chapter: chapter,
                        topic: topic,
                        currentIndex: selection ?? 0
                    )
                )
                await MainActor.run {
                    pendingTagWord = vocab.word
                    selectedTag = ""
                    showTagSheet = true
                }
            }
        }
    }
}

extension String: Identifiable {
    public var id: String { self }
}

public extension UIFont {
    static func textStyleSize(_ style: UIFont.TextStyle) -> CGFloat {
        UIFont.preferredFont(forTextStyle: style).pointSize
    }
}
