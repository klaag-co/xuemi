import SwiftUI

// MARK: - Level enum

enum SecondaryNumber: Int, Codable, CaseIterable {
    case one = 1, two, three, four

    var string: String {
        switch self {
        case .one: return "一"
        case .two: return "二"
        case .three: return "三"
        case .four: return "四"
        }
    }

    var filename: String {
        switch self {
        case .one: return "中一"
        case .two: return "中二"
        case .three: return "中三"
        case .four: return "中四"
        }
    }
}

// MARK: - Global path manager

final class PathManager: ObservableObject {
    @Published var path: NavigationPath = .init()
    @Published var folderPath: NavigationPath = .init()

    static let global = PathManager()
    private init() {}

    func popToRoot() { while !path.isEmpty { path.removeLast() } }
    func popFolderPathToRoot() { while !folderPath.isEmpty { folderPath.removeLast() } }
}

// MARK: - Routes in the main stack (value navigation)

enum Route: Hashable {
    case level(SecondaryNumber)
    case progress(ProgressState)
    case olevelsMenu
    case oPractice(OLevels)

    case progressDetail
    case replayMemory(MemoryAttempt)// ProgressDetailView
    case replay(QuizResult)            // Results replay
    case settings                      // SettingsView
}

enum OLevels: Hashable {
    case midyear, endofyear
    var string: String {
        switch self {
        case .midyear:   return "Mid-Year Practice"
        case .endofyear: return "End-Of-Year Practice"
        }
    }
}

// MARK: - Home

struct HomeView: View {
    @ObservedObject var pathManager: PathManager = .global
    @ObservedObject var progressManager = ProgressManager.shared

    var body: some View {
        NavigationStack(path: $pathManager.path) {
            VStack {
                // Continue Learning card
                Button {
                    if let progress = progressManager.currentProgress {
                        pathManager.path.append(Route.progress(progress))
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

                // Level tiles
                HStack { navigationTile(level: .one);  navigationTile(level: .two) }
                HStack { navigationTile(level: .three); navigationTile(level: .four) }

                // O-Levels entry
                NavigationLink(value: Route.olevelsMenu) {
                    VStack {
                        Text("O 水准备考").padding(.top, 40)
                        Text("").padding(.bottom, 30)
                    }
                    .bold()
                    .font(.system(size: 50))
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
                    // Score chip → Progress (value-based)
                    NavigationLink(value: Route.progressDetail) {
                        ProgressChip()
                    }
                    // Settings (value-based)
                    NavigationLink(value: Route.settings) {
                        Image(systemName: "gear").foregroundStyle(.black)
                    }
                }
            }
            // ======= Route destinations (single place) =======
            .navigationDestination(for: Route.self) { route in
                switch route {

                case .level(let level):
                    ChapterView(level: level)

                case .progress(let progress):
                    let level = progress.level
                    let chapter = progress.chapter
                    let topic = progress.topic
                    FlashcardView(
                        vocabularies: loadVocabulariesFromJSON(
                            fileName: "中\(level.string)",
                            chapter: chapter.string,
                            topic: topic.string(level: level, chapter: chapter)
                        ),
                        level: level,
                        chapter: chapter,
                        topic: topic,
                        currentIndex: progress.currentIndex
                    )

                case .olevelsMenu:
                    OLevelsMenuView()

                case .oPractice(let practice):
                    let vocabs = Array(allVocabularies(for: practice).shuffled().prefix(15))
                    MCQView(vocabularies: vocabs, folderName: practice.string)
                        .navigationTitle(practice.string)
                        .navigationBarTitleDisplayMode(.inline)

                case .progressDetail:
                    ProgressDetailView()

                case .replay(let quiz):
                    ResultReplayDestination(quiz: quiz)

                case .settings:
                    SettingsView()
                    
                case .replayMemory(let attempt): MemoryReplayDestination(attempt: attempt)

                }
            }
        }
    }

    // MARK: - Helpers

    func navigationTile(level: SecondaryNumber) -> some View {
        NavigationLink(value: Route.level(level)) {
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

    func allVocabularies(for practiceType: OLevels) -> [Vocabulary] {
        var all: [Vocabulary] = []
        for level in SecondaryNumber.allCases {
            for chapter in Chapter.allCases {
                if practiceType == .midyear && level == .four && (chapter == .four || chapter == .five) {
                    // skip these for midyear
                } else {
                    for topic in Topic.allCases {
                        all.append(contentsOf: loadVocabulariesFromJSON(
                            fileName: "中\(level.string)",
                            chapter: chapter.string,
                            topic: topic.string(level: level, chapter: chapter)
                        ))
                    }
                }
            }
        }
        return all
    }
}

// Simple menu for O-Levels choices
private struct OLevelsMenuView: View {
    var body: some View {
        VStack {
            NavigationLink(value: Route.oPractice(.midyear)) { Text(OLevels.midyear.string) }
                .font(.title)
                .padding()
                .frame(height: 65)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.black)
                .background(Color.customgray)
                .mask(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

            NavigationLink(value: Route.oPractice(.endofyear)) { Text(OLevels.endofyear.string) }
                .font(.title)
                .padding()
                .frame(height: 65)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.black)
                .background(Color.customgray)
                .mask(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
        }
        .navigationTitle("O 水准备考")
    }
}

// MARK: - Tiny score chip beside the gear

private struct ProgressChip: View {
    @ObservedObject var score = ScoreManager.shared

    private var todayCount: Int {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end = cal.date(byAdding: .day, value: 1, to: start)!
        return score.results.filter { $0.date >= start && $0.date < end }.count
    }

    private var overallAvg: Int {
        guard !score.results.isEmpty else { return 0 }
        let sum = score.results.reduce(0.0) { $0 + $1.percent }
        return Int(round(sum / Double(score.results.count)))
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "chart.bar.fill").font(.subheadline)
            Text("\(todayCount)").font(.subheadline).bold()
            Text("• \(overallAvg)%").font(.subheadline).foregroundStyle(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .clipShape(Capsule())
        .accessibilityLabel("Progress. Today \(todayCount) quizzes. Overall average \(overallAvg) percent.")
    }
}

