import SwiftUI
import AVFoundation

struct FlashcardView: View {
    @State private var currentSet: Int = 0

    // Data
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

    // Tag chooser state
    @State private var showTagMenu = false
    @State private var showCustomTagPrompt = false
    @State private var customTagInput = ""
    @State private var pendingWordForTag: String? = nil   // which vocab we’re tagging

    @ObservedObject private var bookmarkManager: BookmarkManager = .shared
    @ObservedObject private var progressManager: ProgressManager = .shared
    private var synthesizer = AVSpeechSynthesizer()

    // Local tag store (must match BookmarkView)
    private enum TagStore {
        static let prefix = "bookmark.tag."
        static let customKey = "bookmark.custom.topics"

        static func key(word: String, level: SecondaryNumber, chapter: Chapter, topic: Topic) -> String {
            let lv = "L\(level.string)"
            let ch = "C\(chapter.string)"
            let tp = "T\(topic.string(level: level, chapter: chapter))"
            return prefix + [word, lv, ch, tp].joined(separator: "::")
        }

        static func setTag(_ tag: String, forKey key: String) {
            UserDefaults.standard.set(tag, forKey: key)
        }

        static func predefined() -> [String] { ["艺术与文化", "科技", "社区", "环保", "教育", "社会"] }

        static func customTopics() -> [String] {
            (UserDefaults.standard.array(forKey: customKey) as? [String]) ?? []
        }

        static func addCustomTopic(_ name: String) {
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            var existing = customTopics()
            if !existing.contains(trimmed) {
                existing.append(trimmed)
                UserDefaults.standard.set(existing, forKey: customKey)
            }
        }
    }

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

    var body: some View {
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

        // ✅ Only the handwriting sheet
        .sheet(item: $spellingText) { text in
            StrokeWriteView(word: text)
        }

        // 7-topic chooser appears immediately when tapping bookmark
        .confirmationDialog("选择一个主题 · Choose a topic",
                            isPresented: $showTagMenu,
                            titleVisibility: .visible) {

            // 6 fixed topics
            ForEach(TagStore.predefined(), id: \.self) { tag in
                Button(tag) { applyTag(tag) }
            }

            // Already-created custom topics (optional)
            let customs = TagStore.customTopics()
            if !customs.isEmpty {
                Divider()
                ForEach(customs, id: \.self) { tag in
                    Button(tag) { applyTag(tag) }
                }
            }

            // Other…
            Divider()
            Button("其他… · Other…") {
                showCustomTagPrompt = true
            }

            Button("取消 · Cancel", role: .cancel) { }
        }

        .alert("输入自定义主题 · Custom Topic", isPresented: $showCustomTagPrompt) {
            TextField("e.g. 校园生活", text: $customTagInput)
            Button("保存 · Save") {
                let name = customTagInput.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !name.isEmpty else { return }
                TagStore.addCustomTopic(name)
                applyTag(name)
                customTagInput = ""
            }
            Button("取消 · Cancel", role: .cancel) {
                customTagInput = ""
            }
        } message: {
            Text("请输入一个主题名称\nPlease enter a topic name.")
        }

        .onDisappear {
            if let selection, let level, let chapter, let topic {
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

    // MARK: - Apply tag (after bookmark exists)
    private func applyTag(_ tag: String) {
        guard
            let level, let chapter, let topic,
            let word = pendingWordForTag
        else { return }

        let key = TagStore.key(word: word, level: level, chapter: chapter, topic: topic)
        TagStore.setTag(tag, forKey: key)
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

                                // Tap once:
                                // 1️⃣ ensure bookmark exists
                                // 2️⃣ immediately show 7-topic chooser
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

    // Ensure bookmark exists, then show topic menu
    private func handleBookmarkTap(vocab: Vocabulary, level: SecondaryNumber, chapter: Chapter, topic: Topic) {
        let exists = bookmarkManager.bookmarks.contains {
            $0.vocab.word == vocab.word &&
            $0.level == level &&
            $0.chapter == chapter &&
            $0.topic == topic
        }

        if exists {
            showTagMenu = true
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
                    showTagMenu = true
                }
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
        folderName: "Set A",
        currentIndex: 0
    )
}

// MARK: - Helpers for sheet(item:)

extension String: Identifiable {
    public var id: String { self }
}

public extension UIFont {
    static func textStyleSize(_ style: UIFont.TextStyle) -> CGFloat {
        UIFont.preferredFont(forTextStyle: style).pointSize
    }
}

