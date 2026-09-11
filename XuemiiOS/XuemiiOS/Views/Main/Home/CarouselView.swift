//
//  CarouselView.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 19/6/26.
//

import SwiftUI

struct CarouselView: View {
    let width: CGFloat
    let height: CGFloat

    @Environment(ProgressManager.self) private var progressManager
    @Environment(VocabularyManager.self) private var vocabManager
    
    var body: some View {
        VStack {
            if let recentDecks = progressManager.recentDecks {
                if recentDecks.isEmpty {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.customTeal,
                                    Color.customBlue
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .overlay {
                            VStack(spacing: 16) {
                                Image(systemName: "sparkles")
                                    .font(.title)
                                    .foregroundStyle(.white.opacity(0.8))
                                
                                VStack(spacing: 4) {
                                    Text("你还没有最近学习的章节")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                    
                                    Text("从首页选择一个年级开始你的第一堂课吧")
                                        .font(.subheadline)
                                        .foregroundStyle(.white.opacity(0.8))
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: height)
                        .padding(.horizontal)
                } else if recentDecks.count == 1 {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.customTeal,
                                    Color.customBlue
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .overlay {
                            let progress = recentDecks[0]
                            let vocabularies = vocabManager.vocabularies(
                                for: progress.level,
                                chapter: progress.chapter,
                                topic: progress.topic
                            )
                            
                            progressCard(progress: progress, vocabularies: vocabularies)
                        }
                        .frame(height: height, alignment: .center)
                        .padding(.horizontal)
                } else {
                    ScrollView(.horizontal) {
                        LazyHStack {
                            ForEach(recentDecks) { progress in
                                let vocabularies = vocabManager.vocabularies(
                                    for: progress.level,
                                    chapter: progress.chapter,
                                    topic: progress.topic
                                )
                                
                                progressCard(progress: progress, vocabularies: vocabularies)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollIndicators(.hidden)
                    .scrollTargetBehavior(.viewAligned)
                    .safeAreaPadding(.horizontal)
                    .frame(height: height)
                }
            } else {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.customTeal,
                                Color.customBlue
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay {
                        ProgressView()
                            .controlSize(.extraLarge)
                            .tint(.white)
                    }
                    .frame(height: height)
                    .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    func progressCard(progress: ProgressState, vocabularies: [Vocabulary]) -> some View {
        NavigationLink {
            FlashcardsView(
                level: progress.level,
                chapter: progress.chapter,
                topic: progress.topic,
                parentName: "\(progress.level) • \(progress.chapter) • \(progress.topic)",
                vocabularies: vocabularies,
                initialIndex: progress.currentIndex
            )
        } label: {
            VStack {
                Spacer()
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(progress.level) • \(progress.chapter)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        
                        Text("继续学习：\(progress.topic)")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.8))
                        
                        Label("点这里继续", systemImage: "arrow.uturn.forward.circle.fill")
                            .fontWeight(.bold)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    
                    Spacer()
                }
                Spacer()
            }
            .padding()
            .padding()
            .frame(height: height)
            .frame(maxWidth: width)
            .background(
                LinearGradient(
                    colors: [
                        Color.customTeal,
                        Color.customBlue
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        }
        .buttonStyle(.plain)
        .mask(RoundedRectangle(cornerRadius: 24))
    }
}
