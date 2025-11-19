import SwiftUI

struct MCQView: View {
    @State private var selectedAnswer: String? = nil
    @State private var showAnswer = false
    @State private var currentVocabularyIndex = 0
    @State private var shuffledOptions: [[String]] = []
    @State private var selectedQuestions: [String] = []
    @State private var userAnswers: [String?] = []
    @State private var showResults = false
    @State private var correctAnswers: Int = 0
    @State private var wrongAnswers: Int = 0
    @State private var improvements: [(vocab: Vocabulary, index: Int)] = []

    // INPUTS
    @State var vocabularies: [Vocabulary]
    var level: SecondaryNumber?
    var chapter: Chapter?
    var topic: Topic?
    var folderName: String?

    @Environment(\.dismiss) private var dismiss

    // MARK: - Inits

    // Init used when coming from level/chapter/topic
    init(vocabularies: [Vocabulary], level: SecondaryNumber, chapter: Chapter, topic: Topic) {
        let shuffled = vocabularies.shuffled()
        self.vocabularies = shuffled
        self.level = level
        self.chapter = chapter
        self.topic = topic
        self.folderName = nil

        self._shuffledOptions = State(initialValue: MCQView.buildOptions(from: shuffled))
        self._selectedQuestions = State(initialValue: shuffled.map { $0.questions.randomElement() ?? "error" })
        self._userAnswers = State(initialValue: Array(repeating: nil, count: shuffled.count))
    }

    // Init used when coming from a saved folder/set
    init(vocabularies: [Vocabulary], folderName: String) {
        let shuffled = vocabularies.shuffled()
        self.vocabularies = shuffled
        self.level = nil
        self.chapter = nil
        self.topic = nil
        self.folderName = folderName

        self._shuffledOptions = State(initialValue: MCQView.buildOptions(from: shuffled))
        self._selectedQuestions = State(initialValue: shuffled.map { $0.questions.randomElement() ?? "error" })
        self._userAnswers = State(initialValue: Array(repeating: nil, count: shuffled.count))
    }

    // MARK: - Safe helpers

    private var hasData: Bool {
        !vocabularies.isEmpty &&
        shuffledOptions.count == vocabularies.count &&
        selectedQuestions.count == vocabularies.count &&
        currentVocabularyIndex >= 0 &&
        currentVocabularyIndex < vocabularies.count
    }

    private var safeOptions: [String] {
        guard hasData else { return [] }
        return shuffledOptions[currentVocabularyIndex]
    }

    private var currentVocabulary: Vocabulary? {
        guard hasData else { return nil }
        return vocabularies[currentVocabularyIndex]
    }

    private var currentQuestion: String {
        guard hasData else { return "" }
        return selectedQuestions[currentVocabularyIndex]
    }
    
    @EnvironmentObject private var deviceTypeManager: DeviceTypeManager

    // MARK: - Body

    var body: some View {
        VStack {
            if !hasData {
                // Empty / error state
                VStack(spacing: 12) {
                    Text("没有找到题目")
                        .font(.title3).bold()
                    Text("这个单元暂时没有词语。请返回重试。")
                        .foregroundStyle(.secondary)
                    Button("返回") { dismiss() }
                        .buttonStyle(.borderedProminent)
                }
                .padding()
            } else {
                ProgressView(
                    value: Double(min(currentVocabularyIndex + 1, vocabularies.count)),
                    total: Double(max(vocabularies.count, 1))
                )
                .animation(.easeInOut, value: currentVocabularyIndex)
                .padding()

                VStack {
                    Text(currentQuestion)
                        .font(.system(size: 30))
                        .lineLimit(5)
                        .minimumScaleFactor(0.1)
                        .padding()

                    // Show prompt only if we have a vocab to compare against
                    if let vocab = currentVocabulary {
                        Text(selectedAnswer == vocab.word ? " " : "正确答案是什么呢？")
                            .foregroundColor(showAnswer && selectedAnswer != vocab.word ? .red : .white)
                            .font(.system(size: 17))
                    }
                }
                .frame(maxHeight: .infinity)

                ForEach(safeOptions, id: \.self) { option in
                    Button {
                        guard !showAnswer, let vocab = currentVocabulary else { return }
                        selectedAnswer = option
                        userAnswers[currentVocabularyIndex] = option
                        showAnswer = true

                        if option == vocab.word {
                            correctAnswers += 1
                        } else {
                            wrongAnswers += 1
                            improvements.append((vocab, vocab.index))
                        }
                    } label: {
                        Text(option)
                            .frame(maxWidth: .infinity)
                            .font(.system(size: 30)).bold()
                            .padding()
                            .background(buttonColor(for: option))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                    }
                    .disabled(showAnswer)
                }

                HStack {
                    if #available(iOS 26.0, *) {
                        Button {
                            guard currentVocabularyIndex > 0 else { return }
                            currentVocabularyIndex -= 1
                            loadPreviousState()
                        } label: {
                            Image(systemName: "chevron.left")
                                .padding(8)
                        }
                        .disabled(currentVocabularyIndex == 0)
                        .buttonBorderShape(.circle)
                        .buttonStyle(.glass)
                    } else {
                        Button {
                            guard currentVocabularyIndex > 0 else { return }
                            currentVocabularyIndex -= 1
                            loadPreviousState()
                        } label: {
                            Image(systemName: "chevron.left").padding()
                        }
                        .disabled(currentVocabularyIndex == 0)
                    }

                    Spacer()

                    if #available(iOS 26.0, *) {
                        Button {
                            guard showAnswer else { return }
                            if currentVocabularyIndex < vocabularies.count - 1 {
                                currentVocabularyIndex += 1
                                resetState()
                            } else {
                                showResults = true
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                                .padding(8)
                        }
                        .disabled(currentVocabularyIndex == vocabularies.count - 1 && !showAnswer)
                        .buttonBorderShape(.circle)
                        .buttonStyle(.glass)
                    } else {
                        Button {
                            guard showAnswer else { return }
                            if currentVocabularyIndex < vocabularies.count - 1 {
                                currentVocabularyIndex += 1
                                resetState()
                            } else {
                                showResults = true
                            }
                        } label: {
                            Image(systemName: "chevron.right").padding()
                        }
                        .disabled(currentVocabularyIndex == vocabularies.count - 1 && !showAnswer)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Only reshuffle if arrays are out of sync
            if shuffledOptions.count != vocabularies.count || selectedQuestions.count != vocabularies.count {
                reshuffleVocabularies()
            }
            loadPreviousState()
        }
        .navigationDestination(isPresented: $showResults) {
            if let level, let chapter, let topic {
                MCQResultsView(
                    correctAnswers: correctAnswers,
                    wrongAnswers: wrongAnswers,
                    improvements: improvements,
                    totalQuestions: vocabularies.count,
                    vocabularies: vocabularies,
                    userAnswers: userAnswers,
                    level: level,
                    chapter: chapter,
                    topic: topic,
                    folderName: nil,
                    onDone: {
                        if deviceTypeManager.isIPad {
                            dismiss()
                        } else {
                            PathManager.global.popToRoot()
                        }
                    } // go Home
                )
            } else if let folderName {
                MCQResultsView(
                    correctAnswers: correctAnswers,
                    wrongAnswers: wrongAnswers,
                    improvements: improvements,
                    totalQuestions: vocabularies.count,
                    vocabularies: vocabularies,
                    userAnswers: userAnswers,
                    level: nil,
                    chapter: nil,
                    topic: nil,
                    folderName: folderName,
                    onDone: {
                        if deviceTypeManager.isIPad {
                            dismiss()
                        } else {
                            PathManager.global.popToRoot()
                        }
                    } // go Home
                )
            }
        }
    }

    // MARK: - Helpers

    private func buttonColor(for option: String) -> Color {
        guard showAnswer, let vocab = currentVocabulary else { return Color.blue.opacity(0.5) }
        if option == vocab.word { return .green }
        if option == selectedAnswer { return .red }
        return Color.blue.opacity(0.5)
    }

    private static func buildOptions(from vocabularies: [Vocabulary]) -> [[String]] {
        vocabularies.map { v in
            var options = vocabularies.map { $0.word }
            options.removeAll { $0 == v.word }
            options.shuffle()
            let final = Array(options.prefix(3)) + [v.word]
            return final.shuffled()
        }
    }

    private func reshuffleVocabularies() {
        vocabularies.shuffle()
        shuffledOptions = Self.buildOptions(from: vocabularies)
        selectedQuestions = vocabularies.map { $0.questions.randomElement() ?? "error" }
        userAnswers = Array(repeating: nil, count: vocabularies.count)
        currentVocabularyIndex = 0
        correctAnswers = 0
        wrongAnswers = 0
        selectedAnswer = nil
        showAnswer = false
    }

    private func resetState() {
        guard hasData else { return }
        selectedAnswer = userAnswers[currentVocabularyIndex]
        showAnswer = selectedAnswer != nil
    }

    private func loadPreviousState() {
        guard hasData else { return }
        selectedAnswer = userAnswers[currentVocabularyIndex]
        showAnswer = selectedAnswer != nil
    }
}

