//
//  MemoryCardView.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 15/6/26.
//

import SwiftUI

struct MemoryCardView: View {
    
    // Folder name for folders, if for normal chapters and shii use "level • chapterName • topic"
    @State var parentName: String
    
    @State private var allVocabularies: [Vocabulary]
    @State private var cards: [MemoryCard]
    
    @State private var tries = 0
    var gameStarted: Bool {
        timeRemaining <= 0
    }
    
    @State private var isLoading = false
    
    @State private var timeRemaining = 15
    @State private var countdownTimer: Timer? = nil

    @State private var targetWord: String? = nil
    @State private var targetQuestion: String? = nil
    
    @State private var wrongCardIndex: Int? = nil
    @State private var wrongShakeTrigger: CGFloat = 0
    
    @State private var isResultsLoading = false
    @State private var showingResults = false
    
    @Environment(ScoresManager.self) private var scoresManager
    
    init(parentName: String, vocabularies: [Vocabulary]) {
        self.parentName = parentName
        self.allVocabularies = vocabularies
        let shuffledVocabularies = Array(vocabularies.shuffled().prefix(6))
        self.cards = shuffledVocabularies.map({ MemoryCard(vocab: $0) })
    }
    
    var body: some View {
        Group {
            if !showingResults {
                main
            } else {
                MemoryCardsResultsView(parentName: parentName, tries: tries, cards: cards)
            }
        }
    }
    
    var main: some View {
        Group {
            if #available(iOS 26.0, *) {
                memoryCards
                    .navigationSubtitle(parentName)
            } else {
                memoryCards
            }
        }
        .navigationTitle("Memory Cards")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isResultsLoading {
                ToolbarItem(placement: .topBarTrailing) {
                    ProgressView()
                }
            }
        }
    }

    var memoryCards: some View {
        VStack(spacing: 12) {
            if gameStarted {
                VStack {
                    Text(targetQuestion ?? "question")
                        .font(.title)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.center)
                    
                    Text("Tries: \(tries)")
                        .foregroundStyle(.secondary)
                }
                .padding()
            } else {
                Text("\(timeRemaining)s")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .contentTransition(.numericText())
                    .monospacedDigit()
                    .animation(.default, value: timeRemaining)
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                ForEach(cards.indices, id: \.self) { index in
                    Button {
                        let card = cards[index]
                        guard gameStarted, !isLoading, !isResultsLoading, !card.isMatched, !card.isFaceUp else { return }
                        handleCardTap(at: index)
                    } label: {
                        MemoryCardItem(index: index, cards: cards, wrongCardIndex: wrongCardIndex, wrongShakeTrigger: wrongShakeTrigger)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .onAppear {
            startCountdown()
        }
        .onDisappear {
            countdownTimer?.invalidate()
            countdownTimer = nil
        }
    }

    func startCountdown() {
        countdownTimer?.invalidate()
        timeRemaining = 15
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
                
                if timeRemaining <= 0 {
                    timer.invalidate()
                    countdownTimer = nil
                    hideAllCards()
                    getNextVocabulary()
                }
            }
        }
    }
    
    func getNextVocabulary() {
        let filteredCards = cards.filter({ !$0.isMatched })
        if filteredCards.count > 0 {
            let randomCard = filteredCards.randomElement()
            targetWord = randomCard?.vocab.word
            targetQuestion = randomCard?.vocab.questions.randomElement()
        } else {
            Task {
                isResultsLoading = true
                await scoresManager.logScore(
                    parentName: parentName,
                    value: Double(tries),
                    for: .memory,
                    memoryCards: cards.map(\.vocab)
                )
                withAnimation {
                    showingResults = true
                }
                isResultsLoading = false
            }
        }
    }

    func hideAllCards() {
        cards.indices.forEach { i in
            withAnimation {
                cards[i].isFaceUp = false
            }
        }
    }

    func handleCardTap(at index: Int) {
        guard gameStarted, !isLoading, !cards[index].isMatched, !cards[index].isFaceUp else { return }

        tries += 1
        isLoading = true

        withAnimation {
            cards[index].isFaceUp = true
        }

        if cards[index].vocab.word == targetWord {
            cards[index].isMatched = true
            getNextVocabulary()
            isLoading = false
        } else {
            wrongCardIndex = index
            wrongShakeTrigger += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation {
                    cards[index].isFaceUp = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    wrongCardIndex = nil
                    isLoading = false
                }
            }
        }
    }
}
