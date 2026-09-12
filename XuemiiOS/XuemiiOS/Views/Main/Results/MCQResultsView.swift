//
//  MCQResultsView.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 17/6/26.
//

import SwiftUI

struct MCQResultsView: View {
    
    // Folder name for folders, if for normal chapters and shii use "level • chapterName • topic"
    @State var parentName: String
    
    @State var answers: [Answer]
    
    @State var correctVocabs: [Vocabulary]
    @State var wrongVocabs: [Vocabulary]
    @State var answerVocabs: [Vocabulary]
    
    init(parentName: String, answers: [Answer]) {
        self.parentName = parentName
        self.answers = answers
        
        var correctVocabs: [Vocabulary] = []
        var wrongVocabs: [Vocabulary] = []
        var answerVocabs: [Vocabulary] = []
        answers.forEach { answer in
            switch answer {
            case .correct(let vocabulary):
                correctVocabs.append(vocabulary)
            case .wrong(let wrong, let answer):
                wrongVocabs.append(wrong)
                answerVocabs.append(answer)
            }
        }
        
        self.correctVocabs = correctVocabs
        self.wrongVocabs = wrongVocabs
        self.answerVocabs = answerVocabs
    }
    
    var body: some View {
        Group {
            if #available(iOS 26.0, *) {
                main
                    .navigationSubtitle(parentName)
            } else {
                main
            }
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.large)
    }
    
    var main: some View {
        List {
            Section {
                if answers.count > 0 {
                    RingChart(value: Double(correctVocabs.count) / Double(answers.count))
                        .padding()
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: 300, alignment: .center)
                }
            }
            Section("Correct Words") {
                ForEach(correctVocabs) { vocab in
                    NavigationLink {
                        FlashcardsView(vocabularies: [vocab])
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title)
                                .foregroundStyle(.white, .green)
                            
                            VStack(alignment: .leading) {
                                Text(vocab.word)
                                    .font(.headline)
                                Text(vocab.pinyin)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            Section("Wrong Words") {
                ForEach(wrongVocabs.indices, id: \.description) { i in
                    let wrongVocab = wrongVocabs[i]
                    let answerVocab = answerVocabs[i]
                    
                    NavigationLink {
                        FlashcardsView(vocabularies: [wrongVocab, answerVocab])
                    } label: {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundStyle(.white, .red)
                            
                            VStack(alignment: .leading) {
                                Text("\(answerVocab.word) (\(answerVocab.pinyin))")
                                    .font(.headline)
                                Text("Your answer: \(wrongVocab.word) (\(wrongVocab.pinyin))")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
    }
}
