//
//  FlashcardView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 19/6/24.
//

import SwiftUI

struct FlashcardView: View {
    @State private var currentSet: Int = 0
    @State var vocabularies: [Vocabulary]
    
    var body: some View {
        ZStack {
            Color(UIColor(red: 240/255, green: 248/255, blue: 255/255, alpha: 1))
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    
                    Spacer()
                    
                    ProgressView(value: Double(currentSet) / Double(vocabularies.count), total: 1)
                        .accentColor(.blue)
                        .padding(.trailing, 16)
                }
                .padding(.top, 16)
                
                Spacer()
                
                TabView {
                    ForEach($vocabularies, id: \.index) { vocab in
                        VStack(spacing: 0) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(UIColor(red: 240/255, green: 248/255, blue: 255/255, alpha: 1)))
                                    .shadow(radius: 4)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 50)
                                
                                VStack(spacing: 16) {
                                    HStack {
                                        Spacer()
                                        
                                        Text(vocab.word.wrappedValue)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "bookmark.fill")
                                            .font(.system(size: 20))
                                    }
                                    .padding(.horizontal, 16)
                                    .padding()
                                    
                                    Text(vocab.pinyin.wrappedValue)
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                    
                                    Text(vocab.example.wrappedValue)
                                        .font(.title2)
                                    
                                    Text(vocab.englishDefinition.wrappedValue)
                                        .font(.title2)
                                    
                                    Text(vocab.chineseDefinition.wrappedValue)
                                        .font(.title2)
                                }
                                .padding()
                            }
                        }
                        .padding()
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                
                Spacer()
            }
        }
    }
}

#Preview {
    FlashcardView(vocabularies: [
        Vocabulary(index: 1, word: "hi", pinyin: "hi", englishDefinition: "hi", chineseDefinition: "hi", example: "hi"),
        Vocabulary(index: 2, word: "hi2", pinyin: "hi2", englishDefinition: "hi2", chineseDefinition: "hi2", example: "hi2")
                                ])
}
