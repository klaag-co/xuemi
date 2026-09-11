//
//  MCQView.swift
//  Xuemi
//
//  Created by Tristan Chay on 15/6/26.
//

import SwiftUI

struct MCQView: View {
    
    // Folder name for folders, if for normal chapters and shii use "level • chapterName • topic"
    @State var parentName: String
    
    @State var shuffledVocabularies: [Vocabulary]
    @State private var shuffledOptions: [[Vocabulary]]
    @State private var shuffledQuestions: [String]
    
    @State var currentIndex = 0
    
    @State private var selectedAnswer: Vocabulary? = nil
    @State private var userAnswers: [Answer?]
    var correctAnswersCount: Int {
        var count = 0
        self.userAnswers.compactMap({ $0 }).forEach { answer in
            switch answer {
            case .correct(_): count += 1
            case .wrong(_, _): break
            }
        }
        return count
    }
    
    @State private var isResultsLoading = false
    @State private var showingResults = false
    
    @Environment(ScoresManager.self) private var scoresManager
    
    private var dataIsValid: Bool {
        !shuffledVocabularies.isEmpty &&
        shuffledOptions.count == shuffledVocabularies.count &&
        shuffledQuestions.count == shuffledVocabularies.count &&
        currentIndex >= 0 &&
        currentIndex < shuffledVocabularies.count
    }

    private var currentVocabulary: Vocabulary? {
        guard dataIsValid else { return nil }
        return shuffledVocabularies[currentIndex]
    }
    
    init(parentName: String, vocabularies: [Vocabulary], numberOfQuestions: Int? = nil) {
        self.parentName = parentName
        
        var shuffledVocabularies = vocabularies.shuffled()
        if let numberOfQuestions {
            shuffledVocabularies = Array(shuffledVocabularies.prefix(numberOfQuestions))
        }
        self.shuffledVocabularies = shuffledVocabularies
        
        var shuffledQuestions: [String] = []
        shuffledVocabularies.forEach { vocabulary in
            shuffledQuestions.append(vocabulary.questions.randomElement() ?? "")
        }
        self.shuffledQuestions = shuffledQuestions
        
        var shuffledOptions: [[Vocabulary]] = []
        shuffledVocabularies.forEach { vocabulary in
            var options: [Vocabulary?] = []

            var allVocabularies = vocabularies
            allVocabularies.removeAll(where: { $0.id == vocabulary.id })
            
            options.append(vocabulary)
            for _ in 0..<3 {
                let randomVocab = allVocabularies.randomElement()
                options.append(randomVocab)
                allVocabularies.removeAll(where: { $0.id == randomVocab?.id })
            }
            
            shuffledOptions.append(options.compactMap({ $0 }).shuffled())
        }
        self.shuffledOptions = shuffledOptions
        
        self._userAnswers = State(initialValue: Array(repeating: nil, count: shuffledVocabularies.count))
    }
    
    var body: some View {
        Group {
            if !showingResults {
                main
            } else {
                MCQResultsView(parentName: parentName, answers: userAnswers.compactMap({ $0 }))
            }
        }
    }
    
    var main: some View {
        Group {
            if #available(iOS 26.0, *) {
                quiz
                    .navigationSubtitle(parentName)
            } else {
                quiz
            }
        }
        .navigationTitle("MCQ")
        .navigationBarTitleDisplayMode(.inline)
    }
    var quiz: some View {
        VStack {
            Gauge(value: Double(currentIndex + 1) / Double(max(1, shuffledVocabularies.count))) {
                EmptyView()
            }
            .tint(.accent)
            .animation(.bouncy, value: currentIndex)
            
            Spacer()
            
            VStack {
                if let currentVocabulary {
                    Text(shuffledQuestions[currentIndex])
                        .font(.largeTitle)
                        .lineLimit(7)
                        .minimumScaleFactor(0.1)
                        .padding()
                    
                    if let selectedAnswer, selectedAnswer.word != currentVocabulary.word {
                        Text("正确答案是什么呢？")
                            .foregroundColor(.red)
                    }
                }
            }
            .frame(maxHeight: .infinity)
            
            Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                GridRow {
                    ForEach(shuffledOptions[currentIndex].prefix(2), id: \.self) { option in
                        mcqButton(option: option)
                    }
                }
                
                GridRow {
                    ForEach(shuffledOptions[currentIndex].suffix(2), id: \.self) { option in
                        mcqButton(option: option)
                    }
                }
            }
            
            HStack {
                previousButton
                Spacer()
                nextButton
            }
            .padding(.vertical)
        }
        .padding(.horizontal)
    }
    
    var previousButton: some View {
        Group {
            if #available(iOS 26.0, *) {
                Button(action: previous) {
                    Image(systemName: "chevron.left")
                        .padding(8)
                }
                .disabled(currentIndex == 0)
                .buttonBorderShape(.circle)
                .buttonStyle(.glass)
            } else {
                Button(action: previous) {
                    Image(systemName: "chevron.left")
                        .padding(8)
                }
                .disabled(currentIndex == 0)
            }
        }
    }
    
    var nextButton: some View {
        Group {
            if #available(iOS 26.0, *) {
                Button(action: next) {
                    Group {
                        if !isResultsLoading {
                            Image(systemName:  currentIndex == shuffledVocabularies.count - 1 ? "checkmark" : "chevron.right")
                        } else {
                            ProgressView()
                        }
                    }
                    .padding(8)
                }
                .disabled(selectedAnswer == nil || isResultsLoading)
                .buttonBorderShape(.circle)
                .buttonStyle(.glassProminent)
            } else {
                Button(action: next) {
                    Group {
                        if !isResultsLoading {
                            Image(systemName: currentIndex == shuffledVocabularies.count - 1 ? "checkmark" : "chevron.right")
                        } else {
                            ProgressView()
                        }
                    }
                    .padding(8)
                }
                .disabled(selectedAnswer == nil || isResultsLoading)
            }
        }
    }
    
    @ViewBuilder
    func mcqButton(option: Vocabulary) -> some View {
        Group {
            if #available(iOS 26.0, *) {
                Button {
                    mcqButtonPressed(option: option)
                } label: {
                    Text(option.word)
                        .padding(8)
                        .font(.title)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .foregroundStyle(.white)
                }
                .buttonStyle(.glass(.regular.tint(selectedAnswer != nil ? option.word == currentVocabulary?.word ? .green : selectedAnswer?.word == option.word ? .red : .accent : .accent)))
            } else {
                Button {
                    mcqButtonPressed(option: option)
                } label: {
                    Text(option.word)
                        .padding(8)
                        .font(.title)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .background(selectedAnswer != nil ? option.word == currentVocabulary?.word ? .green : selectedAnswer?.word == option.word ? .red : .accent : .accent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .mask(Capsule())
            }
        }
    }
    
    func mcqButtonPressed(option: Vocabulary) {
        guard let currentVocabulary, selectedAnswer == nil else { return }
        
        if option.word == currentVocabulary.word {
            withAnimation {
                selectedAnswer = option
                userAnswers[currentIndex] = .correct(option)
            }
        } else {
            withAnimation {
                selectedAnswer = option
                userAnswers[currentIndex] = .wrong(option, currentVocabulary)
            }
        }
    }
    
    func next() {
        guard selectedAnswer != nil else { return }
        
        if currentIndex < shuffledVocabularies.count - 1 {
            currentIndex += 1
            switch userAnswers[currentIndex] {
            case .correct(let userAnswer): self.selectedAnswer = userAnswer
            case .wrong(let userAnswer, _): self.selectedAnswer = userAnswer
            default: self.selectedAnswer = nil
            }
        } else {
            Task {
                isResultsLoading = true
                await scoresManager.logScore(
                    parentName: parentName,
                    value: Double(correctAnswersCount) / Double(userAnswers.count),
                    for: .mcq,
                    mcqAnswers: userAnswers.compactMap { $0 }
                )
                withAnimation {
                    showingResults = true
                }
                isResultsLoading = false
            }
        }
    }
    
    func previous() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        switch userAnswers[currentIndex] {
        case .correct(let userAnswer): self.selectedAnswer = userAnswer
        case .wrong(let userAnswer, _): self.selectedAnswer = userAnswer
        default: self.selectedAnswer = nil
        }
    }
}
