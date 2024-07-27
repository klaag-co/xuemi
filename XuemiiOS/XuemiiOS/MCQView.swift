//
//  MCQView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 16/7/24.
//

import SwiftUI

struct MCQView: View {
    @State private var selectedAnswer: String? = nil
    @State private var showAnswer = false
    @State private var currentVocabularyIndex = 0
    @State private var shuffledOptions: [[String]] = []
    @State private var selectedQuestions: [String] = []
    @State private var userAnswers: [String?] = []
    var vocabularies: [Vocabulary]
    
    init(vocabularies: [Vocabulary]) {
        self.vocabularies = vocabularies
        self._shuffledOptions = State(initialValue: vocabularies.map { vocabulary in
            var options = vocabularies.map { $0.word }
            options.removeAll { $0 == vocabulary.word }
            options.shuffle()
            let finalOptions = Array(options.prefix(3)) + [vocabulary.word]
            return finalOptions.shuffled()
        })
        self._selectedQuestions = State(initialValue: vocabularies.map { _ in Bool.random() ? "q1" : "q2" })
        self._userAnswers = State(initialValue: Array(repeating: nil, count: vocabularies.count))
    }
    
    var currentVocabulary: Vocabulary {
        vocabularies[currentVocabularyIndex]
    }
    
    var currentQuestion: String {
        selectedQuestions[currentVocabularyIndex] == "q1" ? currentVocabulary.q1 : currentVocabulary.q2
    }
    
    var body: some View {
        VStack {
            ProgressView(value: Double(currentVocabularyIndex + 1), total: Double(vocabularies.count))
                .padding()
            
            Text(currentQuestion)
                .font(.title)
                .minimumScaleFactor(0.1)
                .padding()
            
            Text(selectedAnswer == currentVocabulary.word ? " " : "正确答案是什么呢？")
                .foregroundColor(showAnswer ? .red : .white)
                .font(.headline)
        
            ForEach(shuffledOptions[currentVocabularyIndex], id: \.self) { option in
                Button(action: {
                    if !showAnswer {
                        selectedAnswer = option
                        userAnswers[currentVocabularyIndex] = option
                        showAnswer = true
                    }
                }) {
                    Text(option)
                        .frame(maxWidth: .infinity)
                        .font(.title)
                        .bold()
                        .padding()
                        .background(buttonColor(for: option))
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                }
                .disabled(showAnswer)
            }
            
            Spacer()
            
            HStack {
                Button(action: {
                    if currentVocabularyIndex > 0 {
                        currentVocabularyIndex -= 1
                        loadPreviousState()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .padding()
                }
                .disabled(currentVocabularyIndex == 0)
                
                Spacer()
                
                Button(action: {
                    if currentVocabularyIndex < vocabularies.count - 1 {
                        currentVocabularyIndex += 1
                        resetState()
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .padding()
                }
                .disabled(currentVocabularyIndex == vocabularies.count - 1 || !showAnswer)
            }
            .padding(.horizontal)
        }
    }
    
    func buttonColor(for option: String) -> Color {
        guard showAnswer else { return Color.blue.opacity(0.5) }
        
        if option == currentVocabulary.word {
            return Color.green
        } else if option == selectedAnswer {
            return Color.red
        } else {
            return Color.blue.opacity(0.5)
        }
    }
    
    func resetState() {
        if userAnswers[currentVocabularyIndex] == nil {
            selectedAnswer = nil
            showAnswer = false
        }
    }
    
    func loadPreviousState() {
        selectedAnswer = userAnswers[currentVocabularyIndex]
        showAnswer = selectedAnswer != nil
    }
}

#Preview {
    MCQView(vocabularies: [
        Vocabulary(index: 1, word: "淘气", pinyin: "táo qì", englishDefinition: "naughty; mischievous", chineseDefinition: "1.顽皮  2.生闲气；惹气。", example: "这孩子很聪明，就是有些～，净搞恶作剧。", q1: "顽皮，不听话", q2: "这孩子很聪明，就是有些～，净搞恶作剧。"),
        Vocabulary(index: 2, word: "爱不释手", pinyin: "ài bù shì shǒu", englishDefinition: "to love sth too much to part with it (idiom)", chineseDefinition: "喜爱得舍不得放下。", example: "他对新书爱不释手。", q1: "喜爱得舍不得放下。", q2: "他对新书爱不释手。")
    ])
}
