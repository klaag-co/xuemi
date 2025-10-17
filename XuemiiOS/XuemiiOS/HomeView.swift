import SwiftUI

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

final class PathManager: ObservableObject {
    @Published var path: NavigationPath = .init()
    @Published var folderPath: NavigationPath = .init()
    static let global = PathManager()
    private init() {}
    func popToRoot() { while !path.isEmpty { path.removeLast() } }
    func popFolderPathToRoot() { while !folderPath.isEmpty { folderPath.removeLast() } }
}

enum Route: Hashable {
    case level(SecondaryNumber)
    case progress(ProgressState)      // existing
    case resume(SecondaryNumber)      // NEW: per-level continue
    case olevelsMenu
    case oPractice(OLevels)
    case progressDetail
    case replayMemory(MemoryAttempt)
    case replay(QuizResult)
    case settings
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
// ======================================================

// MARK: - Continue Carousel
private struct ContinueCarouselView: View {
    @ObservedObject var pathManager: PathManager = .global
    @State private var allProgress: [LastProgressStore.Point] = []

       var body: some View {
           Group {
               if allProgress.isEmpty {
                   VStack(spacing: 16) {
                       Text("你还没有最近学习的章节")
                           .font(.title2)
                           .foregroundStyle(.secondary)
                           .padding(.top, 80)
                   }
                   .frame(maxWidth: .infinity, maxHeight: .infinity)
               } else {
                   TabView {
                       ForEach(Array(allProgress.enumerated()), id: \.offset) { idx, point in
                           Button {
                               pathManager.path.append(Route.resume(point.level))

                           } label: {
                               VStack(alignment: .leading, spacing: 8) {
                                   Text(point.chapter.string)
                                       .font(.system(size: 42, weight: .bold))
                                       .foregroundStyle(.white)

                                   Text("继续学习：中\(point.level.string)、\(point.topic.string(level: point.level, chapter: point.chapter))")
                                       .font(.headline)
                                       .foregroundStyle(.white.opacity(0.9))
                               }
                               .padding(25)
                               .frame(maxWidth: .infinity)
                               .background(Color.customblue)
                               .mask(RoundedRectangle(cornerRadius: 16))
                               .padding(20)
                           }
                           .buttonStyle(.plain)
                           .id(idx)
                       }
                   }
                   .tabViewStyle(.page(indexDisplayMode: .always))
                   .indexViewStyle(.page(backgroundDisplayMode: .never))
               }
           }
           .onAppear {
               allProgress = LastProgressStore.getAll()
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


// MARK: - O-Levels Menu (unchanged)

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


// MARK: - Progress Chip (unchanged)

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
        Group {
            if #available(iOS 26.0, *) {
                HStack(spacing: 6) {
                    Image(systemName: "chart.bar.fill").font(.subheadline)
                    Text("\(todayCount)").font(.subheadline).bold()
                    Text("• \(overallAvg)%").font(.subheadline).foregroundStyle(.secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "chart.bar.fill").font(.subheadline)
                    Text("\(todayCount)").font(.subheadline).bold()
                    Text("• \(overallAvg)%").font(.subheadline).foregroundStyle(.secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
            }
        }
        .clipShape(Capsule())
        .accessibilityLabel("Progress. Today \(todayCount) quizzes. Overall average \(overallAvg) percent.")
    }
}

// =====================
// MARK: - HomeView
// =====================
struct HomeView: View {
    @ObservedObject var pathManager: PathManager = .global
    @ObservedObject var progressManager = ProgressManager.shared

    var body: some View {
        NavigationStack(path: $pathManager.path) {
            VStack(spacing: 16) {
                // Swipeable per-level Continue (aligned + peek + edge-only-when-dragging)
                ContinueCarouselView()

                // Your Sec 1/2/3/4 tiles (unchanged size)
                HStack {
                    navigationTile(level: .one)
                    navigationTile(level: .two)
                }
                .padding(.horizontal, 20)
                HStack {
                    navigationTile(level: .three)
                    navigationTile(level: .four)
                }
                .padding(.horizontal, 20)
                
                // O-Levels entry (unchanged)
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
                .padding([.horizontal, .bottom], 20)
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink(value: Route.progressDetail) { ProgressChip() }
                }
            }
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

                case .resume(let level):
                    if let resume = LastProgressStore.getAll().first(where: { $0.level == level }) {
                        FlashcardView(
                            vocabularies: loadVocabulariesFromJSON(
                                fileName: "中\(level.string)",
                                chapter: resume.chapter.string,
                                topic: resume.topic.string(level: level, chapter: resume.chapter)
                            ),
                            level: level,
                            chapter: resume.chapter,
                            topic: resume.topic,
                            currentIndex: resume.currentIndex
                        )
                    } else {
                        ChapterView(level: level)
                    }

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

                case .replayMemory(let attempt):
                    MemoryReplayDestination(attempt: attempt)
                }
            }
        }
    }

    // MARK: - Helpers (same as your existing ones; if you already
    // have global versions in this file, you can delete those to avoid dupes)

    private func navigationTile(level: SecondaryNumber) -> some View {
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

    private func allVocabularies(for practiceType: OLevels) -> [Vocabulary] {
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

