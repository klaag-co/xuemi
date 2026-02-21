import SwiftUI

struct ShakeEffect: GeometryEffect {
    var shakes: CGFloat = 0
    var amplitude: CGFloat = 8
    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }
    func effectValue(size: CGSize) -> ProjectionTransform {
        let x = sin(shakes * .pi * 2) * amplitude
        return ProjectionTransform(CGAffineTransform(translationX: x, y: 0))
    }
}

struct MemoryCardModel: Identifiable {
    let id = UUID()
    let text: String                 // word
    var isFaceUp: Bool = true
    var isMatched: Bool = false
}

struct MemoryCardView: View {
    @State private var cards: [MemoryCardModel] = []
    @State private var selectedVocabs: [Vocabulary] = []   // <- keep chosen set with pinyin
    @State private var timeRemaining: Int = 15
    @State private var tries: Int = 0
    @State private var gameStarted: Bool = false
    @State private var isProcessing: Bool = false
    @State private var wrongCardIndex: Int? = nil
    @State private var wrongShakeTrigger: CGFloat = 0
    @State private var countdownTimer: Timer? = nil

    // Results
    @State private var showResults: Bool = false
    @State private var finalTries: Int = 0

    // Inputs
    @State var vocabularies: [Vocabulary]
    var level: SecondaryNumber
    var chapter: Chapter
    var topic: Topic
    var folderName: String? = nil

    @State private var targetVocabulary: Vocabulary? = nil
    @State private var displayedQuestion: String? = nil

    private let maxCards = 6

    var body: some View {
        VStack(spacing: 12) {
            if let question = displayedQuestion {
                Text(question)
                    .font(.title)
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                Text("Timing: \(timeRemaining)s")
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }

            Text("Tries: \(tries)")
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                ForEach(cards.indices, id: \.self) { index in
                    cardView(for: index)
                }
            }
            .padding()
        }
        .navigationTitle("Memory")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            startNewRound()
            startCountdown()
        }
        .onDisappear {
            countdownTimer?.invalidate()
            countdownTimer = nil
        }
        .navigationDestination(isPresented: $showResults) {
            let title = contextTitle()
            let history = MemoryStats.shared.history(for: title)
            MemoryResultsView(
                tries: finalTries,
                vocabularies: selectedVocabs,
                level: level,
                chapter: chapter,
                topic: topic,
                folderName: folderName,
                history: history,
                onPlayAgain: { restartGame() }
            )
        }
    }

    @ViewBuilder
    private func cardView(for index: Int) -> some View {
        let card = cards[index]
        Button(action: { handleCardTap(at: index) }) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.customblue)
                    .overlay(
                        Text(card.text)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(6)
                    )
                    .opacity(card.isFaceUp ? 1 : 0)
                    .rotation3DEffect(.degrees(card.isFaceUp ? 0 : -180), axis: (x: 0, y: 1, z: 0))

                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(white: 0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.customblue.opacity(0.6), lineWidth: 4)
                    )
                    .opacity(card.isFaceUp ? 0 : 1)
                    .rotation3DEffect(.degrees(card.isFaceUp ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            }
            .frame(height: 100)
            .modifier(wrongCardIndex == index ? ShakeEffect(shakes: wrongShakeTrigger) : ShakeEffect(shakes: 0))
            .animation(.easeInOut(duration: 0.35), value: card.isFaceUp)
            .animation(.easeInOut(duration: 0.45), value: wrongShakeTrigger)
        }
        .disabled(!gameStarted || isProcessing || card.isMatched || card.isFaceUp)
        .buttonStyle(PlainButtonStyle())
    }

    private func startNewRound() {
        // pick a set
        let available = vocabularies.shuffled()
        selectedVocabs = Array(available.prefix(maxCards))
        cards = selectedVocabs.map { MemoryCardModel(text: $0.word, isFaceUp: true, isMatched: false) }

        targetVocabulary = selectedVocabs.randomElement()
        displayedQuestion = nil
        tries = 0
        gameStarted = false
        isProcessing = false
        wrongCardIndex = nil
        wrongShakeTrigger = 0
        timeRemaining = 15
    }

    private func restartGame() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        startNewRound()
        startCountdown()
    }

    private func startCountdown() {
        countdownTimer?.invalidate()
        timeRemaining = 15
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
                countdownTimer = nil
                hideAllCards()
                displayedQuestion = targetVocabulary?.questions.randomElement() ?? "问题"
                gameStarted = true
            }
        }
    }

    private func hideAllCards() {
        for i in cards.indices {
            withAnimation(.easeInOut(duration: 0.35)) {
                cards[i].isFaceUp = false
            }
        }
    }

    private func handleCardTap(at index: Int) {
        guard gameStarted, !isProcessing, !cards[index].isMatched, !cards[index].isFaceUp else { return }

        isProcessing = true
        tries += 1

        withAnimation(.easeInOut(duration: 0.35)) {
            cards[index].isFaceUp = true
        }

        let tappedIndex = index

        if cards[tappedIndex].text == targetVocabulary?.word {
            cards[tappedIndex].isMatched = true
            if let nextTarget = cards.first(where: { !$0.isMatched }) {
                targetVocabulary = selectedVocabs.first { $0.word == nextTarget.text }
                displayedQuestion = targetVocabulary?.questions.randomElement()
                isProcessing = false
            } else {
                // finished
                finalTries = tries
                recordAttempt(tries: tries)
                checkForCompletion()
            }
        } else {
            wrongCardIndex = tappedIndex
            wrongShakeTrigger += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeInOut(duration: 0.35)) {
                    cards[tappedIndex].isFaceUp = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    wrongCardIndex = nil
                    isProcessing = false
                }
            }
        }
    }

    private func checkForCompletion() {
        if cards.allSatisfy({ $0.isMatched }) {
            gameStarted = false
            showResults = true
        } else {
            isProcessing = false
        }
    }

    private func contextTitle() -> String {
        "中\(level.string) · \(chapter.string) · \(topic.string(level: level, chapter: chapter))"
    }

    private func recordAttempt(tries: Int) {
        let minis = selectedVocabs.map { VocabLite(id: $0.index, word: $0.word, pinyin: $0.pinyin) }
        MemoryStats.shared.record(
            tries: tries,
            contextTitle: contextTitle(),
            levelRaw: level.rawValue,
            chapterRaw: nil,
            topicRaw: nil,
            folderName: folderName,
            vocab: minis
        )
    }
}

