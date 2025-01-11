//
//  SpeakerView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 27/11/24.
//

import SwiftUI
import AVFoundation

struct SpeakerView: View {
    var words: [Vocabulary]
    @State private var shuffledWords: [Vocabulary] = []
    @State private var currentIndex: Int = 0
    @State private var revealAnswer: Bool = false

    var body: some View {
        VStack {
            ProgressView(value: Double(currentIndex) / Double(max(shuffledWords.count - 1, 1)), total: 1)
                .accentColor(.blue)
                .padding()
                .animation(.default, value: currentIndex)
            
            if !shuffledWords.isEmpty {
                Spacer()

                Button(action: playSound) {
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 110))
                        .foregroundColor(.blue)
                }
                Spacer()

                DisclosureGroup(isExpanded: $revealAnswer) {
                                   Text(shuffledWords[currentIndex].word)
                                       .font(.title)
                                       .padding()
                               } label: {
                                   Text(revealAnswer ? "Hide Answer" : "Reveal Answer")
                                       .font(.headline)
                                       .padding()
                                       .foregroundStyle(Color.gray)
                                       .cornerRadius(8)
                               }
                               .padding(25)

                Spacer()

                HStack {
                    Button(action: previousWord) {
                        Image(systemName: "arrow.left")
                            .font(.largeTitle)
                            .padding()
                    }
                    .disabled(currentIndex == 0)

                    Spacer()

                    Button(action: nextWord) {
                        Image(systemName: "arrow.right")
                            .font(.largeTitle)
                            .padding()
                    }
                    .disabled(currentIndex == shuffledWords.count - 1)
                }
                .padding()
            } else {
                Spacer()
                Text("No words to read out.")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            }
        }
        .onAppear {
            shuffledWords = words.shuffled()
//            print("Words shuffled for SpeakerView: \(shuffledWords.map { $0.word })")
            if !shuffledWords.isEmpty {
                currentIndex = 0
                revealAnswer = false
            }
        }
    }

    private func playSound() {
        let utterance = AVSpeechUtterance(string: shuffledWords[currentIndex].word)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        let synthesizer = AVSpeechSynthesizer()
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
        if currentIndex < shuffledWords.count - 1 {
            currentIndex += 1
            revealAnswer = false
        }
    }

    private func previousWord() {
        if currentIndex > 0 {
            currentIndex -= 1
            revealAnswer = false
        }
    }
}

