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

    @State var vocabularies: [Vocabulary]
    var level: String?
    var chapter: String?
    var topic: String?
    var folderName: String?

    @Environment(\.dismiss) private var dismiss

    init(vocabularies: [Vocabulary], level: String, chapter: String, topic: String) {
        let shuffled = vocabularies.shuffled()
        self.vocabularies = shuffled
        self.level = level
        self.chapter = chapter
        self.topic = topic
        self.folderName = nil

        self._shuffledOptions = State(initialValue: shuffled.map { v in
            var options = shuffled.map { $0.word }
            options.removeAll { $0 == v.word }
            options.shuffle()
            let finalOptions = Array(options.prefix(3)) + [v.word]
            return finalOptions.shuffled()
        })
        self._selectedQuestions = State(initialValue: shuffled.map { $0.questions.randomElement() ?? "error" })
        self._userAnswers = State(initialValue: Array(repeating: nil, count: shuffled.count))
    }

    init(vocabularies: [Vocabulary], folderName: String) {
        let shuffled = vocabularies.shuffled()
        self.vocabularies = shuffled
        self.level = nil; self.chapter = nil; self.topic = nil
        self.folderName = folderName

        self._shuffledOptions = State(initialValue: shuffled.map { v in
            var options = shuffled.map { $0.word }
            options.removeAll { $0 == v.word }
            options.shuffle()
            let finalOptions = Array(options.prefix(3)) + [v.word]
            return finalOptions.shuffled()
        })
        self._selectedQuestions = State(initialValue: shuffled.map { $0.questions.randomElement() ?? "error" })
        self._userAnswers = State(initialValue: Array(repeating: nil, count: shuffled.count))
    }

    var currentVocabulary: Vocabulary { vocabularies[currentVocabularyIndex] }
    var currentQuestion: String { selectedQuestions[currentVocabularyIndex] }

    var body: some View {
        VStack {
            ProgressView(value: Double(currentVocabularyIndex + 1), total: Double(vocabularies.count))
                .animation(.easeInOut, value: currentVocabularyIndex)
                .padding()

            VStack {
                Text(currentQuestion)
                    .font(.system(size: 30))
                    .lineLimit(5)
                    .minimumScaleFactor(0.1)
                    .padding()

                Text(selectedAnswer == currentVocabulary.word ? " " : "正确答案是什么呢？")
                    .foregroundColor(showAnswer && selectedAnswer != currentVocabulary.word ? .red : .white)
                    .font(.system(size: 17))
            }
            .frame(maxHeight: .infinity)

            ForEach(shuffledOptions[currentVocabularyIndex], id: \.self) { option in
                Button {
                    if !showAnswer {
                        selectedAnswer = option
                        userAnswers[currentVocabularyIndex] = option
                        showAnswer = true

                        if option == currentVocabulary.word { correctAnswers += 1 }
                        else { wrongAnswers += 1 }
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
                Button {
                    if currentVocabularyIndex > 0 {
                        currentVocabularyIndex -= 1
                        loadPreviousState()
                    }
                } label: { Image(systemName: "chevron.left").padding() }
                .disabled(currentVocabularyIndex == 0)

                Spacer()

                Button {
                    if showAnswer {
                        if currentVocabularyIndex < vocabularies.count - 1 {
                            currentVocabularyIndex += 1
                            resetState()
                        } else {
                            showResults = true
                        }
                    }
                } label: { Image(systemName: "chevron.right").padding() }
                .disabled(currentVocabularyIndex == vocabularies.count - 1 && !showAnswer)
            }
            .padding(.horizontal)
            .padding(.top)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            reshuffleVocabularies()
            loadPreviousState()
        }
        .onChange(of: showResults) { done in
            if done {
                ScoreManager.shared.record(score: correctAnswers, outOf: vocabularies.count)
            }
        }
        .navigationDestination(isPresented: $showResults) {
            if let level, let chapter, let topic {
                MCQResultsView(correctAnswers: correctAnswers,
                               wrongAnswers: wrongAnswers,
                               totalQuestions: vocabularies.count,
                               level: level, chapter: chapter, topic: topic)
            } else if let folderName {
                MCQResultsView(correctAnswers: correctAnswers,
                               wrongAnswers: wrongAnswers,
                               totalQuestions: vocabularies.count,
                               folderName: folderName) {
                    dismiss()
                }
            }
        }
    }

    func buttonColor(for option: String) -> Color {
        guard showAnswer else { return Color.blue.opacity(0.5) }
        if option == currentVocabulary.word { return Color.green }
        if option == selectedAnswer        { return Color.red }
        return Color.blue.opacity(0.5)
    }

    func reshuffleVocabularies() {
        vocabularies.shuffle()
        shuffledOptions = vocabularies.map { v in
            var options = vocabularies.map { $0.word }
            options.removeAll { $0 == v.word }
            options.shuffle()
            let final = Array(options.prefix(3)) + [v.word]
            return final.shuffled()
        }
        selectedQuestions = vocabularies.map { $0.questions.randomElement() ?? "error" }
        userAnswers = Array(repeating: nil, count: vocabularies.count)
        currentVocabularyIndex = 0
        correctAnswers = 0
        wrongAnswers = 0
        selectedAnswer = nil
        showAnswer = false
    }

    func resetState() {
        selectedAnswer = userAnswers[currentVocabularyIndex]
        showAnswer = selectedAnswer != nil
    }

    func loadPreviousState() {
        selectedAnswer = userAnswers[currentVocabularyIndex]
        showAnswer = selectedAnswer != nil
    }
}

