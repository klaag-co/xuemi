import SwiftUI

enum SecondaryNumber: Codable, CaseIterable {
    case one, two, three, four
    var string: String {
        switch self { case .one: "一"; case .two: "二"; case .three: "三"; case .four: "四" }
    }
    var filename: String {
        switch self { case .one: "中一"; case .two: "中二"; case .three: "中三"; case .four: "中四" }
    }
}

class PathManager: ObservableObject {
    @Published var path: NavigationPath = .init()
    @Published var folderPath: NavigationPath = .init()
    static var global: PathManager = .init()
    private init() {}
    func popToRoot() { while !path.isEmpty { path.removeLast() } }
    func popFolderPathToRoot() { while !folderPath.isEmpty { folderPath.removeLast() } }
}

struct HomeView: View {
    @State var vocabsToPass: [Vocabulary]? = nil
    @State var showingOLevelsSelectorView = false
    @State var practiceTypeSelected: OLevels? = nil

    @ObservedObject var pathManager: PathManager = .global
    @ObservedObject var progressManager = ProgressManager.shared

    @EnvironmentObject private var scores: ScoreManager
    @State private var showCelebration = false

    var body: some View {
        NavigationStack(path: $pathManager.path) {
            VStack {
                Button {
                    if let progress = progressManager.currentProgress {
                        pathManager.path.append(progress)
                    }
                } label: {
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

                NavigationLink(value: true) {
                    VStack {
                        Text("O 水准备考").padding(.top, 40)
                        Text("").padding(.bottom, 30)
                    }
                    .bold().font(.system(size: 50))
                }
                .font(.system(size: 40))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
                .background(Color.customteal)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(20)
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    StreakChip() // 🔥 streak + today's goal
                    ScoreChip()  // today’s marks
                    NavigationLink(destination: SettingsView()) { Image(systemName: "gear") }
                }
            }
            .navigationDestination(for: SecondaryNumber.self) { level in
                ChapterView(level: level)
            }
            .navigationDestination(for: ProgressState.self) { progress in
                let level = progress.level, chapter = progress.chapter, topic = progress.topic
                FlashcardView(
                    vocabularies: loadVocabulariesFromJSON(
                        fileName: "中\(level.string)",
                        chapter: chapter.string,
                        topic: topic.string(level: level, chapter: chapter)
                    ),
                    level: level, chapter: chapter, topic: topic,
                    currentIndex: progress.currentIndex
                )
            }
            .navigationDestination(for: Bool.self) { _ in
                VStack {
                    NavigationLink(value: OLevels.midyear) {
                        Text(OLevels.midyear.string)
                    }
                    .font(.title)
                    .padding()
                    .frame(height: 65)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.black)
                    .background(.customgray)
                    .mask(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)

                    NavigationLink(value: OLevels.endofyear) {
                        Text(OLevels.endofyear.string)
                    }
                    .font(.title)
                    .padding()
                    .frame(height: 65)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.black)
                    .background(.customgray)
                    .mask(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                }
                .navigationTitle("O 水准备考")
                .navigationDestination(for: OLevels.self) { practice in
                    Group {
                        if let vocabsToPass {
                            MCQView(
                                vocabularies: vocabsToPass,
                                level: "O 水准备考",
                                chapter: practice.string,
                                topic: "topic"
                            )
                            .navigationTitle(practice.string)
                            .navigationBarTitleDisplayMode(.inline)
                        }
                    }
                    .onAppear {
                        vocabsToPass = Array(allVocabularies(for: practice).shuffled().prefix(15))
                    }
                }
            }
            Spacer()
        }
        .onChange(of: scores.justHitStreakMilestoneID) { _ in
            guard scores.justHitStreakMilestoneID != nil else { return }
            withAnimation(.spring()) { showCelebration = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(.easeInOut) { showCelebration = false }
            }
        }
        .overlay { if showCelebration { CelebrationOverlay() } }
    }

    // MARK: Helpers

    func allVocabularies(for practicetype: OLevels) -> [Vocabulary] {
        var allVocabs: [Vocabulary] = []
        for level in SecondaryNumber.allCases {
            for chapter in Chapter.allCases {
                if level == .four && (chapter == .four || chapter == .five) && practicetype == .midyear {
                } else {
                    for topic in Topic.allCases {
                        allVocabs.append(
                            contentsOf: loadVocabulariesFromJSON(
                                fileName: "中\(level.string)",
                                chapter: chapter.string,
                                topic: topic.string(level: level, chapter: chapter)
                            )
                        )
                    }
                }
            }
        }
        return allVocabs
    }

    func navigationTile(level: SecondaryNumber) -> some View {
        NavigationLink(value: level) {
            HStack {
                Text("中\(level.string)")
                    .minimumScaleFactor(0.1)
                    .font(.system(size: 55))
                    .bold()
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
            }
            .padding(30)
            .background(Color.customteal)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

enum OLevels: Hashable {
    case midyear, endofyear
    var string: String { self == .midyear ? "Mid-Year Practice" : "End-Of-Year Practice" }
}

