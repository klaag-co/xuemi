//
//  SOneChapterView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 28/5/24.
//

import SwiftUI

enum Chapter: CaseIterable, Codable {
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
    
    var level: SecondaryNumber
    
    @State var vocabsToPass: [Vocabulary] = []
    
    var body: some View {
        ScrollView {
            Text("中 \(level.string)")
                .font(.largeTitle)
                .bold()
                .padding()
                .frame(height: 80)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
                .background(.customblue)
                .mask(RoundedRectangle(cornerRadius: 16))
                .padding([.horizontal, .bottom])
            VStack(spacing: 12) {
                ForEach(level == .four ? Chapter.allCases.filter({ $0 != .six }) : Chapter.allCases, id: \.hashValue) { chapter in
                    NavigationLink {
                        if chapter != .eoy {
                            TopicView(level: level, chapter: chapter)
                        } else {
                            Group {
                                MCQView(
                                    vocabularies: vocabsToPass,
                                    level: level.string,
                                    chapter: chapter.string,
                                    topic: Topic.eoy.string(level: level, chapter: chapter)
                                )
                            }
                            .onAppear {
                                vocabsToPass = Array(allVocabularies().shuffled().prefix(15))
                            }
                        }
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
        .navigationBarTitleDisplayMode(.inline)
        .padding(.vertical)
        .onAppear {
            self.vocabsToPass = Array(allVocabularies().shuffled().prefix(15))
        }
    }
    
    func allVocabularies() -> [Vocabulary] {
        var allVocabs: [Vocabulary] = []
        for chapter in Chapter.allCases {
            for topic in Topic.allCases {
                allVocabs.append(contentsOf: loadVocabulariesFromJSON(fileName: "中\(level.string)", chapter: chapter.string, topic: topic.string(level: level, chapter: chapter)))
            }
        }
        return allVocabs
    }
}

#Preview {
    ChapterView(level: .three)
}
