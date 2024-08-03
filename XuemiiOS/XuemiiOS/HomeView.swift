//
//  HomeView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 16/4/24.
//

import SwiftUI

//use observableobject to store the thing for secondary chapter topic

enum SecondaryNumber: Codable, CaseIterable {
    case one, two, three, four

    var string: String {
        switch self {
        case .one:
            return "一"
        case .two:
            return "二"
        case .three:
            return "三"
        case .four:
            return "四"
        }
    }

    var filename: String {
        switch self {f
        case .one:
            return "中一"
        case .two:
            return "中二"
        case .three:
            return "中三"
        case .four:
            return "中四"
        }
    }
}

class PathManager: ObservableObject {
    @Published var path: NavigationPath = .init()
    
    static var global: PathManager = .init()
    
    private init() {}
    
    func popToRoot() {
        while !path.isEmpty {
            path.removeLast()
        }
    }
}

struct HomeView: View {
    
    @State var vocabsToPass: [Vocabulary]? = nil
    
    @ObservedObject var pathManager: PathManager = .global
    @ObservedObject var progressManager = ProgressManager.shared
    
    var allVocabularies: [Vocabulary] {
        var allVocabs: [Vocabulary] = []
        for level in SecondaryNumber.allCases {
            for chapter in Chapter.allCases {
                for topic in Topic.allCases {
                    allVocabs.append(contentsOf: loadVocabulariesFromJSON(fileName: "中\(level.string)", chapter: chapter.string, topic: topic.string(level: level, chapter: chapter)))
                }
            }
        }
        return allVocabs
    }

    var body: some View {
        NavigationStack(path: $pathManager.path) {
            VStack {
                Button(action: {
                    if let progress = progressManager.currentProgress {
                        pathManager.path.append(progress)
                    }
                }) {
                    Image("ContinueLearning")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                }
                .foregroundStyle(.white)
                .background(Color.customblue)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                HStack {
                    navigationTile(level: .one)
                    navigationTile(level: .two)
                }

                HStack {
                    navigationTile(level: .three)
                    navigationTile(level: .four)
                }

                NavigationLink(value: OLevels.oLevels) {
                    VStack {
                        Text("O 水准备考")
                            .padding(.top, 40)
                        Text("")
                            .padding(.bottom, 30)
                    }
                    .bold()
                    .font(.system(size: 50))
                }
                .font(.system(size: 40))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .background(Color.customteal)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(20)
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: SecondaryNumber.self) { level in
                ChapterView(level: level)
            }
            .navigationDestination(for: ProgressState.self) { progress in
                let level = progress.level
                let chapter = progress.chapter
                let topic = progress.topic
                FlashcardView(vocabularies: loadVocabulariesFromJSON(fileName: "中\(level.string)", chapter: chapter.string, topic: topic.string(level: level, chapter: chapter)), level: level, chapter: chapter, topic: topic, currentIndex: progress.currentIndex)
            }
            .navigationDestination(for: OLevels.self) { _ in
                Group {
                    if let vocabsToPass {
                        MCQView(
                            vocabularies: vocabsToPass,
                            level: "O 水准备考",
                            chapter: "chapter",
                            topic: "topic"
                        )
                    }
                }
                .onAppear {
                    vocabsToPass = Array(allVocabularies.shuffled().prefix(15))
                }
            }
            Spacer()
        }
    }

    func navigationTile(level: SecondaryNumber) -> some View {
        NavigationLink(value: level) {
            HStack {
                Text("中\(level.string)")
                    .minimumScaleFactor(0.1)
                    .font(.system(size: 55))
                    .bold()
            }
            .padding(30)
            .background(Color.customteal)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
    func loadVocabularies(for level: SecondaryNumber, chapter: String, topic: String) -> [Vocabulary] {
        //eee
        return []
    }
}

enum OLevels: Hashable {
    case oLevels
}

#Preview {
    HomeView()
}
