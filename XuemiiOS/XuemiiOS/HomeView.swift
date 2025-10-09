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

// MARK: - Continue Carousel (aligned + peek + edge-only-when-dragging)
private struct ContinueCarouselView: View {
    @ObservedObject var pathManager: PathManager = .global
    @State private var showDialogForLevel: SecondaryNumber? = nil
    @State private var selection: Int? = 0
    @State private var isDragging = false

    private let SIDE_PADDING: CGFloat = 8
    private let CARD_HEIGHT: CGFloat = 150
    private let PEEK: CGFloat = 16

    var body: some View {
        GeometryReader { geo in
            let visibleWidth = geo.size.width - (SIDE_PADDING * 2)
            let cardWidth = max(0, visibleWidth - PEEK)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: PEEK) {    
                    ForEach(Array(SecondaryNumber.allCases.enumerated()), id: \.offset) { idx, level in
                        let resume = LastProgressStore.get(level: level)

                        Button {
                            if resume != nil {
                                pathManager.path.append(Route.resume(level))
                            } else {
                                showDialogForLevel = level
                            }
                        } label: {
                            ZStack(alignment: .bottomLeading) {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(resume == nil ? Color.customgray : Color.customblue)
                                    .frame(width: cardWidth, height: CARD_HEIGHT)

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("中\(level.string)")
                                        .font(.system(size: 42, weight: .bold))
                                        .foregroundStyle(.white)

                                    if let resume {
                                        Text("继续学习：\(resume.chapter.string)、\(resume.topic.string(level: level, chapter: resume.chapter))")
                                            .font(.headline)
                                            .foregroundStyle(.white.opacity(0.9))
                                    } else {
                                        Text("还未开始学习")
                                            .font(.headline)
                                            .foregroundStyle(.white.opacity(0.9))
                                    }
                                }
                                .padding(20)
                            }
                            .frame(height: CARD_HEIGHT)
                        }
                        .buttonStyle(.plain)
                        .id(idx)
                    }
                }
                .scrollTargetLayout()
                // Leading/trailing insets so the first/last card align with the same 20pt
                .padding(.horizontal, SIDE_PADDING)
            }
            // let the content go full-bleed ONLY while dragging (compensate parent padding)
            .padding(.horizontal, isDragging ? -SIDE_PADDING : 0)
            .animation(.easeOut(duration: 0.15), value: isDragging)
            .scrollTargetBehavior(.viewAligned)  // snaps each card neatly with peek
            .scrollPosition(id: $selection)
            .scrollClipDisabled(true)
            .ignoresSafeArea(.container, edges: .horizontal)
            .frame(height: CARD_HEIGHT + 8)
            .simultaneousGesture(
                DragGesture(minimumDistance: 1)
                    .onChanged { _ in if !isDragging { isDragging = true } }
                    .onEnded { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) { isDragging = false }
                    }
            )
        }
        .frame(height: CARD_HEIGHT + 8)
        .confirmationDialog(
            "还没有学习这个年级的卡片，要开始吗？",
            isPresented: Binding(
                get: { showDialogForLevel != nil },
                set: { if !$0 { showDialogForLevel = nil } }
            ),
            actions: {
                if let level = showDialogForLevel {
                    Button("开始学习中\(level.string)") {
                        pathManager.path.append(Route.level(level))
                        showDialogForLevel = nil
                    }
                }
                Button("取消", role: .cancel) { showDialogForLevel = nil }
            }
        )
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
                HStack { navigationTile(level: .one);  navigationTile(level: .two) }
                HStack { navigationTile(level: .three); navigationTile(level: .four) }

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
            }
            .padding(20)
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
                    if let resume = LastProgressStore.get(level: level) {
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

