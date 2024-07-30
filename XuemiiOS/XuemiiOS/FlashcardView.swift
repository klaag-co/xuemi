import SwiftUI
import AVFoundation

public struct FlashcardView: View {
    @State private var currentSet: Int = 0
    var vocabularies: [Vocabulary]
    var level: SecondaryNumber
    var chapter: Chapter
    var topic: Topic
    
    @State var selection: Int? = 0
    @State var spellingText: String? = nil
    
    @EnvironmentObject var bookmarkManager: BookmarkManager
    private var synthesizer = AVSpeechSynthesizer()
    
    init(vocabularies: [Vocabulary], level: SecondaryNumber, chapter: Chapter, topic: Topic) {
        self.vocabularies = vocabularies
        self.level = level
        self.chapter = chapter
        self.topic = topic
    }
    
    public var body: some View {
        ZStack {
            VStack {
                ProgressView(value: Double(selection ?? 0) / Double(vocabularies.count - 1), total: 1)
                    .accentColor(.blue)
                    .padding(30)
                    .animation(.default, value: selection)

                Spacer()

                if vocabularies.isEmpty {
                    Text("No vocabulary found")
                } else {
                    GeometryReader { proxy in
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
        .sheet(item: $spellingText) { text in
            StrokeWriteView(word: text)
        }
    }
    
    func viewForCard(vocab: Vocabulary) -> some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor(red: 240/255, green: 248/255, blue: 255/255, alpha: 1)))
                .shadow(radius: 4)
                .padding(.vertical)
                .padding(.horizontal, 5)
                .containerRelativeFrame(.horizontal)
                .overlay {
                    VStack {
                        HStack {
                            Spacer()
                            Text("中\(level.string): \(chapter.string)")
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                                .font(.title3)
                                .fontWeight(.bold)
                            Spacer()
                            Button {
                                if !bookmarkManager.bookmarks.contains(where: { $0.vocab == vocab && $0.level == level && $0.chapter == chapter && $0.topic == topic }) {
                                    print("Bookmark appended for word: \(vocab.word)")
                                    bookmarkManager.bookmarks.append(BookmarkedVocabulary(vocab: vocab, level: level, chapter: chapter, topic: topic))
                                } else {
                                    print("Bookmark removed for word: \(vocab.word)")
                                    bookmarkManager.bookmarks.removeAll(where: { $0.vocab == vocab && $0.level == level && $0.chapter == chapter && $0.topic == topic })
                                }
                            } label: {
                                Image(systemName: bookmarkManager.bookmarks.contains(where: { $0.vocab == vocab && $0.level == level && $0.chapter == chapter && $0.topic == topic }) ? "bookmark.fill" : "bookmark")
                            }
                        }
                        .padding([.horizontal, .top], 30)
                        Spacer()
                        
                        HStack {
                            Text("Click the word to practice handwriting!")
                                .font(.system(size: 10))
                                .padding(.leading, 55)
                                .padding(.bottom, 10)
                            Spacer()
                        }
                        
                        VStack {
                            Text(vocab.word)
                                .font(.system(size: 48))
                                .underline()
                                .fontWeight(.bold)
                                .onTapGesture {
                                    spellingText = vocab.word
                                }
                        }
                        
                        HStack {
                            Text(vocab.pinyin)
                                .font(.largeTitle)
                            Button(action: {
                                let utterance = AVSpeechUtterance(string: vocab.word)
                                utterance.voice = AVSpeechSynthesisVoice(language: "zh-SG")
                                utterance.rate = 0.1
                                synthesizer.speak(utterance)
                            }) {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.blue)
                                    .padding(.leading, 5)
                            }
                        }
                        .padding(.top, 5)
                        
                        VStack {
                            Text(vocab.chineseDefinition)
                                .minimumScaleFactor(0.1)
                            Text(vocab.englishDefinition)
                                .minimumScaleFactor(0.1)
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

#Preview {
    FlashcardView(vocabularies: [
        Vocabulary(index: 1, word: "hello", pinyin: "hi", englishDefinition: "hi", chineseDefinition: "hi", example: "hi", q1: "", q2: ""),
        Vocabulary(index: 2, word: "hi2", pinyin: "hi2", englishDefinition: "hi2", chineseDefinition: "hi2", example: "hi2", q1: "", q2: "")
    ], level: .one, chapter: .one, topic: .one)
    .environmentObject(BookmarkManager.shared)
}

extension String: Identifiable {
    public var id: String { self }
}

