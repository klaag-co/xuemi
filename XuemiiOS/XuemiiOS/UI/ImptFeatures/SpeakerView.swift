import SwiftUI
import AVFoundation

struct SpeakerView: View {
    var words: [Vocabulary]
    var folderName: String = "Spelling"
    var onBackToFolders: (() -> Void)? = nil

    @State private var shuffledWords: [Vocabulary] = []
    @State private var currentIndex: Int = 0
    @State private var revealAnswer: Bool = false
    @State private var isFinished: Bool = false

    let synthesizer = AVSpeechSynthesizer()

    var body: some View {
        VStack {
            if isFinished {
                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 90))
                    .foregroundStyle(.green)

                Text("Spelling Complete!")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                Text("You have gone through all the words.")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Button {
                    restart()
                } label: {
                    Text("Restart")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal)
                .padding(.top, 20)

                Button {
                    onBackToFolders?()
                } label: {
                    Text("Back to Custom Folders")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal)
                .padding(.top, 8)

                Spacer()

            } else if !shuffledWords.isEmpty {
                ProgressView(
                    value: Double(currentIndex + 1),
                    total: Double(shuffledWords.count)
                )
                .accentColor(.blue)
                .padding()
                .animation(.default, value: currentIndex)

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
                }
                .padding(25)

                Spacer()

                HStack {
                    Button(action: previousWord) {
                        Image(systemName: "chevron.left")
                            .padding(8)
                    }
                    .disabled(currentIndex == 0)
                    .buttonBorderShape(.circle)
                    .buttonStyle(.glass)

                    Spacer()

                    Button(action: nextWord) {
                        Image(systemName: currentIndex == shuffledWords.count - 1 ? "checkmark" : "chevron.right")
                            .padding(8)
                    }
                    .buttonBorderShape(.circle)
                    .buttonStyle(.glass)
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
        .navigationTitle("Spelling")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if shuffledWords.isEmpty {
                shuffledWords = words.shuffled()
                currentIndex = 0
                revealAnswer = false
                isFinished = false
            }
        }
    }

    private func playSound() {
        guard !shuffledWords.isEmpty else { return }

        let utterance = AVSpeechUtterance(string: shuffledWords[currentIndex].word)

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
        } else {
            isFinished = true
        }
    }

    private func previousWord() {
        if currentIndex > 0 {
            currentIndex -= 1
            revealAnswer = false
        }
    }

    private func restart() {
        currentIndex = 0
        revealAnswer = false
        isFinished = false
    }
}
