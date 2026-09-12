//
//  SpellingView.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 15/6/26.
//

import SwiftUI
import AVFoundation

struct SpellingView: View {
    @State private var parentName: String
    @State private var vocabularies: [Vocabulary]
    
    @State private var currentIndex = 0
    @State private var showingAnswer = false
    
    init(parentName: String, vocabularies: [Vocabulary]) {
        self.parentName = parentName
        self.vocabularies = vocabularies.shuffled()
    }

    let synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        Group {
            if #available(iOS 26.0, *) {
                main
                    .navigationSubtitle(parentName)
            } else {
                main
            }
        }
        .navigationTitle("Spelling")
        .navigationBarTitleDisplayMode(.inline)
    }

    var main: some View {
        VStack {
            Gauge(value: Double(currentIndex + 1) / Double(max(1, vocabularies.count))) {
                EmptyView()
            }
            .tint(.accent)
            .animation(.bouncy, value: currentIndex)
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: playSound) {
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 110))
                    .foregroundStyle(.accent)
            }
            
            Button {
                withAnimation {
                    showingAnswer.toggle()
                }
            } label: {
                if showingAnswer {
                    Text(vocabularies[currentIndex].word)
                        .font(.largeTitle)
                        .padding()
                } else {
                    VStack {
                        Text(vocabularies[currentIndex].word)
                            .font(.largeTitle)
                            .redacted(reason: .placeholder)
                        Text("Tap to reveal the word!")
                    }
                    .padding()
                }
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            HStack {
                previousButton
                Spacer()
                nextButton
            }
            .padding()
        }
    }
    
    var previousButton: some View {
        Group {
            if #available(iOS 26.0, *) {
                Button(action: previousWord) {
                    Image(systemName: "chevron.left")
                        .padding(8)
                }
                .disabled(currentIndex == 0)
                .buttonBorderShape(.circle)
                .buttonStyle(.glass)
            } else {
                Button(action: previousWord) {
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
                Button(action: nextWord) {
                    Image(systemName: "chevron.right")
                        .padding(8)
                }
                .disabled(currentIndex == vocabularies.count - 1)
                .buttonBorderShape(.circle)
                .buttonStyle(.glass)
            } else {
                Button(action: nextWord) {
                    Image(systemName: "chevron.right")
                        .padding(8)
                }
                .disabled(currentIndex == vocabularies.count - 1)
            }
        }
    }

    private func playSound() {
        guard !vocabularies.isEmpty else { return }

        let utterance = AVSpeechUtterance(string: vocabularies[currentIndex].word)

        if let voice = AVSpeechSynthesisVoice.speechVoices().first(where: {
            $0.language == "zh-CN" && $0.gender == .female
        }) {
            utterance.voice = voice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        }

        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }

    private func nextWord() {
        if currentIndex < vocabularies.count - 1 {
            withAnimation {
                currentIndex += 1
                showingAnswer = false
            }
        }
    }
    
    private func previousWord() {
        if currentIndex > 0 {
            withAnimation {
                currentIndex -= 1
                showingAnswer = false
            }
        }
    }
}
