import SwiftUI
import AVFoundation

public struct FlashcardView: View {
    @State private var currentSet: Int = 0

    // Data
    var vocabularies: [Vocabulary]
    var level: SecondaryNumber?
    var chapter: Chapter?
    var topic: Topic?
    var folderName: String?         // ✅ added
    var currentIndex: Int?

    // UI state
    @State private var selection: Int? = 0
    @State private var spellingText: String? = nil
    @State private var isLargeDevice: Bool

    @ObservedObject private var bookmarkManager: BookmarkManager = .shared
    @ObservedObject private var progressManager: ProgressManager = .shared
    private var synthesizer = AVSpeechSynthesizer()

    // Keep init internal unless all parameter types are public.
    init(
        vocabularies: [Vocabulary],
        level: SecondaryNumber? = nil,
        chapter: Chapter? = nil,
        topic: Topic? = nil,
        folderName: String? = nil,      // ✅ added
        currentIndex: Int? = nil
    ) {
        self.vocabularies = vocabularies
        self.level = level
        self.chapter = chapter
        self.topic = topic
        self.folderName = folderName    // ✅ added
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
                                ForEach(Array(vocabularies.enumerated()), id: \.offset) { (index, vocab) in
                                    viewForCard(vocab: vocab)
                                        .id(index)
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
        .onDisappear {
            if let selection, let level, let chapter, let topic {
                progressManager.updateProgress(
                    level: level,
                    chapter: chapter,
                    topic: topic,
                    currentIndex: selection
                )
            }
        }
        .onAppear {
            if let currentIndex = currentIndex {
                withAnimation { selection = currentIndex }
            }
        }
    }

    // MARK: - Card

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
                        // Header: show path if available; else show folder name
                        HStack {
                            Spacer()
                            if let level, let chapter, let topic {
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

                            // Bookmark only when we have full path context (level/chapter/topic)
                            if let level, let chapter, let topic {
                                Button {
                                    if !bookmarkManager.bookmarks.contains(where: {
                                        $0.vocab.word == vocab.word &&
                                        $0.level == level &&
                                        $0.chapter == chapter &&
                                        $0.topic == topic
                                    }) {
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
                                        }
                                    } else if let bookmark = bookmarkManager.bookmarks.first(where: {
                                        $0.vocab.word == vocab.word &&
                                        $0.level == level &&
                                        $0.chapter == chapter &&
                                        $0.topic == topic
                                    }) {
                                        Task { await bookmarkManager.deleteBookmarkFromFirebase(id: bookmark.id) }
                                    }
                                } label: {
                                    Image(systemName:
                                            bookmarkManager.bookmarks.contains(where: {
                                                $0.vocab.word == vocab.word &&
                                                $0.level == level &&
                                                $0.chapter == chapter &&
                                                $0.topic == topic
                                            }) ? "bookmark.fill" : "bookmark")
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
                                if let voice = AVSpeechSynthesisVoice.speechVoices().first(where: {
                                    $0.language == "zh-CN"
                                }) {
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
                                .lineLimit(2)
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
}

// MARK: - Preview

#Preview {
    FlashcardView(
        vocabularies: [
            Vocabulary(index: 1, word: "你好", pinyin: "nǐ hǎo",
                       englishDefinition: "hello", chineseDefinition: "打招呼", example: "你好！",
                       questions: ["“你好”的英文是什么？", "‘hello’ 的汉语是什么？"]),
            Vocabulary(index: 2, word: "谢谢", pinyin: "xiè xie",
                       englishDefinition: "thanks", chineseDefinition: "表达感谢", example: "谢谢你！",
                       questions: ["‘谢谢’的意思是？"])
        ],
        folderName: "Set A",          // ✅ works with MCQResultsView’s calls
        currentIndex: 0
    )
}

// MARK: - Support

extension String: Identifiable {
    public var id: String { self }
}

public extension UIFont {
    static func textStyleSize(_ style: UIFont.TextStyle) -> CGFloat {
        UIFont.preferredFont(forTextStyle: style).pointSize
    }
}

