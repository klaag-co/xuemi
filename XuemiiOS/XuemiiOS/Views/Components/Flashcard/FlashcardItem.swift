//
//  FlashcardItem.swift
//  Xuemi
//
//  Created by Tristan Chay on 14/6/26.
//

import SwiftUI
import AVFoundation

struct FlashcardItem: View {
    
    let vocabulary: Vocabulary
    var folder: Folder? = nil
    
    @Binding var handwritingWord: String?
    @Binding var selectedVocabularyToBookmark: Vocabulary?
    
    var synthesizer = AVSpeechSynthesizer()
    
    @Environment(FoldersManager.self) private var foldersManager
    
    var body: some View {
        Group {
            if #available(iOS 26.0, *) {
                main
                    .glassEffect(.regular.tint(.accent.opacity(0.15)).interactive(), in: .rect(cornerRadius: 24))
            } else {
                main
                    .background(.accent.opacity(0.3))
                    .mask(RoundedRectangle(cornerRadius: 24))
            }
        }
        .padding(.vertical, 32)

    }
    
    var main: some View {
        VStack {
            HStack {
                Spacer()
                if let folder {
                    Text(folder.title)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .font(.title3)
                        .fontWeight(.bold)
                } else {
                    Text("\(vocabulary.level) • \(vocabulary.chapterName)")
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .font(.title3)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                Button {
                    selectedVocabularyToBookmark = vocabulary
                } label: {
                    Image(systemName: foldersManager.isBookmarked(vocabulary: vocabulary) ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 20))
                }
            }
            .padding([.horizontal, .top], 32)
            Spacer()
            
            VStack(spacing: 16) {
                Text("Click the word to practice handwriting!")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                
                
                Button {
                    handwritingWord = vocabulary.word
                } label: {
                    Text(vocabulary.word)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .buttonStyle(.plain)
                
                HStack {
                    Text(vocabulary.pinyin)
                        .lineLimit(2)
                        .minimumScaleFactor(0.6)
                        .font(.title)
                    Button {
                        let utterance = AVSpeechUtterance(string: vocabulary.word)
                        if let voice = AVSpeechSynthesisVoice.speechVoices().first(where: { $0.language == "zh-CN" }) {
                            utterance.voice = voice
                        } else {
                            utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
                        }
                        utterance.rate = 0.5
                        synthesizer.speak(utterance)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title)
                            .foregroundStyle(.accent)
                    }
                }
            }
            
            VStack(spacing: 16) {
                Text(vocabulary.chineseDefinition)
                    .lineLimit(4)
                    .minimumScaleFactor(0.6)
                Text(vocabulary.englishDefinition)
                    .lineLimit(4)
                    .minimumScaleFactor(0.6)
            }
            .font(.title3)
            .padding(.top)
            .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
        .containerRelativeFrame(.horizontal)
    }
}
