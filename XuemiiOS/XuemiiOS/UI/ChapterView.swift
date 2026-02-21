//
//  SOneChapterView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 28/5/24.
//

import SwiftUI

enum Chapter: CaseIterable, Codable, Hashable {
    case one, two, three, four, five, six, eoy
    
    var string: String {
        switch self {
        case .one:
            return "单元一"
        case .two:
            return "单元二"
        case .three:
            return "单元三"
        case .four:
            return "单元四"
        case .five:
            return "单元五"
        case .six:
            return "单元六"
        case .eoy:
            return "年终考试"
        }
    }
}

struct ChapterView: View {
    let level: SecondaryNumber
    @State private var vocabsToPass: [Vocabulary] = []

    private var chaptersForLevel: [Chapter] {
        level == .four
        ? Chapter.allCases.filter { $0 != .six } 
        : Chapter.allCases
    }

    var body: some View {
        ScrollView {
            Text("中\(level.string)")
                .font(.largeTitle).bold()
                .padding()
                .frame(height: 80)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
                .background(.customblue)
                .mask(RoundedRectangle(cornerRadius: 16))
                .padding([.horizontal, .bottom])

            VStack(spacing: 12) {
                ForEach(chaptersForLevel) { chapter in
                    NavigationLink {
                        destination(for: chapter)
                    } label: {
                        Text(chapter.string)
                            .font(.title)
                            .padding()
                            .frame(height: 65)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.black)
                            .background(.customgray)
                            .mask(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal)
                    }
                }
            }
        }
        .onAppear {
            vocabsToPass = Array(allVocabularies().shuffled().prefix(15))
        }
    }

    @ViewBuilder
    private func destination(for chapter: Chapter) -> some View {
        if chapter == .eoy {
            MCQView(
                vocabularies: vocabsToPass,
                level: level,
                chapter: chapter,
                topic: .eoy
            )
            .onAppear {
                vocabsToPass = Array(allVocabularies().shuffled().prefix(15))
            }
        } else {
            TopicView(level: level, chapter: chapter)
        }
    }

    private func allVocabularies() -> [Vocabulary] {
        var all: [Vocabulary] = []
        for ch in Chapter.allCases {
            for tp in Topic.allCases {
                all.append(contentsOf:
                    loadVocabulariesFromJSON(
                        fileName: "中\(level.string)",
                        chapter: ch.string,
                        topic: tp.string(level: level, chapter: ch)
                    )
                )
            }
        }
        return all
    }
}

#Preview {
    ChapterView(level: .three)
}
