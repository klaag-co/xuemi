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
    @State private var showResults = false
    
    @State private var correctAnswers: Int = 0
    @State private var wrongAnswers: Int = 0
    
    @State var vocabularies: [Vocabulary]
    var level: String
    var chapter: String
    var topic: String
    
    init(vocabularies: [Vocabulary], level: String, chapter: String, topic: String) {
        self.vocabularies = vocabularies
        self.level = level
        self.chapter = chapter
        self.topic = topic
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
                .foregroundColor(showAnswer && selectedAnswer != currentVocabulary.word ? .red : .white)
                .font(.headline)
        
            ForEach(shuffledOptions[currentVocabularyIndex], id: \.self) { option in
                Button(action: {
                    if !showAnswer {
                        selectedAnswer = option
                        userAnswers[currentVocabularyIndex] = option
                        showAnswer = true
                        
                        if option == currentVocabulary.word {
                            correctAnswers += 1
                        } else {
                            wrongAnswers += 1
                        }
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
                    if showAnswer {
                        if currentVocabularyIndex < vocabularies.count - 1 {
                            currentVocabularyIndex += 1
                            resetState()
                        } else {
                            showResults = true
                        }
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .padding()
                }
                .disabled(currentVocabularyIndex == vocabularies.count - 1 && !showAnswer)
            }
            .padding(.horizontal)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadPreviousState()
        }
        .navigationDestination(isPresented: $showResults) {
            MCQResultsView(
                correctAnswers: correctAnswers,
                wrongAnswers: wrongAnswers,
                totalQuestions: vocabularies.count,
                level: level,
                chapter: chapter,
                topic: topic
            )
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
        selectedAnswer = userAnswers[currentVocabularyIndex]
        showAnswer = selectedAnswer != nil
    }
    
    func loadPreviousState() {
        selectedAnswer = userAnswers[currentVocabularyIndex]
        showAnswer = selectedAnswer != nil
    }
}
