import SwiftUI
import Charts

// =====================================
// MARK: - Core enums / managers
// =====================================

enum SecondaryNumber: Int, Codable, CaseIterable, Hashable {
    case one = 1, two, three, four

    var string: String {
        switch self {
        case .one:   return "一"
        case .two:   return "二"
        case .three: return "三"
        case .four:  return "四"
        }
    }

    var filename: String {
        switch self {
        case .one:   return "中一"
        case .two:   return "中二"
        case .three: return "中三"
        case .four:  return "中四"
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

    func goHome() { popToRoot() }

    func goProgressDetail() {
        popToRoot()
        path.append(Route.progressDetail)
    }
}

enum Route: Hashable {
    case level(SecondaryNumber)
    case progress(ProgressState)
    case resume(SecondaryNumber, Chapter, Topic)
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

// =====================================
// MARK: - iPad root sections (Home / Notes / Folders / Settings)
// =====================================

private enum IPadRootSection: String, CaseIterable, Identifiable, Hashable {
    case home = "Home"
    case notes = "Notes"
    case folders = "Folders"
    case settings = "Settings"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .home:    return "house.fill"
        case .notes:   return "note.text"
        case .folders: return "folder"
        case .settings:return "gearshape.fill"
        }
    }

    var title: String { rawValue }
}

// =====================================
// MARK: - Continue Carousel
// =====================================

private struct ContinueCarouselView: View {
    @ObservedObject var pathManager: PathManager = .global
    @State private var allProgress: [LastProgressStore.Point] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Header
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [Color.customblue.opacity(0.9), Color.customteal.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text("继续学习")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text("从你上次停下的地方继续进步")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(.horizontal, 4)

            if allProgress.isEmpty {
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.customteal,
                                    Color.customblue
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    VStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.9))

                        Text("你还没有最近学习的章节")
                            .font(.headline)
                            .foregroundStyle(.white)

                        Text("从首页选择一个年级开始你的第一堂课吧")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 160)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.customblue.opacity(0.9),
                                    Color.customteal.opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    TabView {
                        ForEach(Array(allProgress.enumerated()), id: \.offset) { idx, point in
                            Button {
                                pathManager.path.append(
                                    Route.resume(point.level, point.chapter, point.topic)
                                )
                            } label: {
                                HStack(spacing: 20) {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(point.chapter.string)
                                            .font(.system(size: 34, weight: .bold))
                                            .foregroundStyle(.white)

                                        Text("继续学习：中\(point.level.string)、\(point.topic.string(level: point.level, chapter: point.chapter))")
                                            .font(.headline)
                                            .foregroundStyle(.white.opacity(0.9))

                                        HStack(spacing: 6) {
                                            Image(systemName: "arrow.uturn.forward.circle.fill")
                                                .font(.subheadline)
                                            Text("点这里继续")
                                                .font(.subheadline)
                                                .bold()
                                        }
                                        .foregroundStyle(.white.opacity(0.95))
                                        .padding(.top, 4)
                                    }

                                    Spacer()
                                }
                                .padding(24)
                            }
                            .buttonStyle(.plain)
                            .id(idx)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .automatic))
                    .indexViewStyle(.page(backgroundDisplayMode: .interactive))
                    .padding(.horizontal, 4)
                }
                .frame(height: 170)
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
        }
        .padding(.horizontal, 20)
        .onAppear {
            allProgress = LastProgressStore.getAll()
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: allProgress.count)
    }
}

// =====================================
// MARK: - Shared helpers
// =====================================

private func navigationTile(level: SecondaryNumber) -> some View {
    NavigationLink(value: Route.level(level)) {
        VStack(alignment: .leading, spacing: 10) {
            Text("中\(level.string)")
                .font(.system(size: 30, weight: .bold))
            Text("进入全部章节")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(22)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    Color.customteal,
                    Color.customblue.opacity(0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        )
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 5)
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

// =====================================
// MARK: - O-Levels Menu
// =====================================

private struct OLevelsMenuView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("O 水准备考")
                        .font(.largeTitle.weight(.bold))
                    Text("选择练习模式，巩固你的词汇和理解。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                NavigationLink(value: Route.oPractice(.midyear)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(OLevels.midyear.string)
                            .font(.title3.weight(.semibold))
                        Text("适合期中复习，覆盖前半年的重点内容。")
                            .font(.subheadline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 70, alignment: .leading)
                    .background(
                        LinearGradient(
                            colors: [Color.customgray.opacity(0.9), Color.white],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal)

                NavigationLink(value: Route.oPractice(.endofyear)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(OLevels.endofyear.string)
                            .font(.title3.weight(.semibold))
                        Text("全面终考练习，检验一整年的学习成果。")
                            .font(.subheadline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 70, alignment: .leading)
                    .background(
                        LinearGradient(
                            colors: [Color.customgray.opacity(0.9), Color.white],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 16)
        }
        .background(
            LinearGradient(
                colors: [
                    Color(.systemGroupedBackground),
                    Color.customblue.opacity(0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationTitle("O 水准备考")
    }
}

// =====================================
// MARK: - Progress Chip
// =====================================

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
            Image(systemName: "chart.bar.fill")
                .font(.subheadline)
            Text("\(todayCount)")
                .font(.subheadline.weight(.semibold))
            Text("• \(overallAvg)%")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            LinearGradient(
                colors: [
                    Color.customblue.opacity(0.16),
                    Color.customteal.opacity(0.16)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            Capsule()
                .strokeBorder(Color.customblue.opacity(0.3), lineWidth: 0.8)
        )
        .clipShape(Capsule())
        .accessibilityLabel("Progress. Today \(todayCount) quizzes. Overall average \(overallAvg) percent.")
    }
}

// =====================================
// MARK: - iPad Sidebar
// =====================================

private struct LevelSidebar: View {
    @ObservedObject var pathManager: PathManager = .global
    @Binding var rootSection: IPadRootSection

    private func sidebarButton(_ section: IPadRootSection) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                rootSection = section
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: section.iconName)
                    .imageScale(.medium)
                Text(section.title)
                    .font(.body)
                Spacer()
                if rootSection == section {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(Color.customblue)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(
                Group {
                    if rootSection == section {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.customblue.opacity(0.12))
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.clear)
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            // Top branding
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [Color.customblue, Color.customteal],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text("学")
                        .font(.headline.weight(.black))
                        .foregroundStyle(.white)
                }
                .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Xuemi 学习中心")
                        .font(.subheadline.weight(.semibold))
                    Text("选择页面与年级")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 12)

            // Main section: Home / Notes / Folders / Settings
            VStack(alignment: .leading, spacing: 10) {
                Text("主页面")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .padding(.horizontal, 2)

                sidebarButton(.home)
                sidebarButton(.notes)
                sidebarButton(.folders)
                sidebarButton(.settings)
            }

            Divider()
                .padding(.vertical, 8)

            // Existing levels section
            VStack(alignment: .leading, spacing: 12) {
                Text("年级")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .padding(.horizontal, 2)

                ForEach(SecondaryNumber.allCases, id: \.self) { level in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            rootSection = .home  // ensure Home tab is active when going into levels
                            pathManager.path.append(Route.level(level))
                        }
                    } label: {
                        HStack {
                            Text("中\(level.string)")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6).opacity(0.8))
                        )
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        rootSection = .home
                        pathManager.path.append(Route.olevelsMenu)
                    }
                } label: {
                    HStack {
                        Text("O 水准备考")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 7)
                    .padding(.horizontal, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.customblue.opacity(0.12))
                    )
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color.customblue.opacity(0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .overlay(
                Rectangle()
                    .frame(width: 1)
                    .foregroundStyle(Color.black.opacity(0.05)),
                alignment: .trailing
            )
        )
    }
}

// =====================================
// MARK: - Level filter popover
// =====================================

private struct LevelChecklist: View {
    @Binding var selectedLevels: Set<SecondaryNumber>

    private func toggle(_ level: SecondaryNumber) {
        if selectedLevels.contains(level) {
            selectedLevels.remove(level)
        } else {
            selectedLevels.insert(level)
        }
        if selectedLevels.isEmpty {
            selectedLevels.insert(level)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("选择年级")
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            ForEach(SecondaryNumber.allCases, id: \.self) { level in
                let isOn = selectedLevels.contains(level)
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        toggle(level)
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                        Text("中\(level.string)")
                    }
                    .font(.body)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

// =====================================
// MARK: - Stats cards (left column)
// =====================================

private struct StatsCardBase<Content: View>: View {
    let title: String
    let subtitle: String
    let iconName: String
    let accentColor: Color
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header row: icon + title + subtitle
            HStack(alignment: .center, spacing: 10) {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.15))
                    Image(systemName: iconName)
                        .font(.caption)
                        .foregroundStyle(accentColor)
                }
                .frame(width: 26, height: 26)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            content
        }
        .padding(14)
        .frame(maxWidth: .infinity,
               minHeight: 150,
               alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(.systemBackground),
                            Color(.systemBackground).opacity(0.92)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
    }
}

// Small metric tile (used by both cards)
private func metricTile(label: String, value: String, systemImage: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.caption2)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }

        Text(value)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.primary)
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 6)
    .background(
        RoundedRectangle(cornerRadius: 10)
            .fill(Color(.systemGray6).opacity(0.95))
    )
}

// MCQ 卡片
private struct MCQStatsCard: View {
    @Binding var selectedLevels: Set<SecondaryNumber>
    @ObservedObject private var scoreManager = ScoreManager.shared

    // Filtered by selected levels
    private var filtered: [QuizResult] {
        if selectedLevels.count == SecondaryNumber.allCases.count {
            return scoreManager.results
        }
        return scoreManager.results.filter { result in
            if let lvl = SecondaryNumber(rawValue: result.levelRaw ?? 0) {
                return selectedLevels.contains(lvl)
            }
            return false
        }
    }

    private var overallAvg: Double {
        guard !filtered.isEmpty else { return 0 }
        return filtered.reduce(0.0) { $0 + $1.percent } / Double(filtered.count)
    }

    private var best: Double {
        filtered.map(\.percent).max() ?? 0
    }

    private var todayCount: Int {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end = cal.date(byAdding: .day, value: 1, to: start)!
        return filtered.filter { $0.date >= start && $0.date < end }.count
    }

    private var distinctLevelsCount: Int {
        let levels = filtered.compactMap { SecondaryNumber(rawValue: $0.levelRaw ?? 0) }
        return Set(levels).count
    }

    var body: some View {
        StatsCardBase(
            title: "MCQ 数据",
            subtitle: "测验整体表现一目了然",
            iconName: "checklist",
            accentColor: Color.customblue
        ) {
            VStack(alignment: .leading, spacing: 12) {

                // Big average score
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(String(format: "%.0f", overallAvg))
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.customblue)
                    Text("% 平均得分")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }

                // 2×2 grid of metrics
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    metricTile(
                        label: "总测验次数",
                        value: "\(filtered.count)",
                        systemImage: "number.circle"
                    )
                    metricTile(
                        label: "今日测验",
                        value: "\(todayCount)",
                        systemImage: "sun.max.fill"
                    )
                    metricTile(
                        label: "最佳成绩",
                        value: String(format: "%.0f%%", best),
                        systemImage: "star.fill"
                    )
                    metricTile(
                        label: "涉及年级",
                        value: "\(distinctLevelsCount) 个",
                        systemImage: "person.3.fill"
                    )
                }
            }

        }
    }
}

// 记忆练习卡片
private struct MemoryStatsCard: View {
    @Binding var selectedLevels: Set<SecondaryNumber>
    @ObservedObject private var memoryStats = MemoryStats.shared

    private var filtered: [MemoryAttempt] {
        if selectedLevels.count == SecondaryNumber.allCases.count {
            return memoryStats.attempts
        }
        return memoryStats.attempts.filter { attempt in
            if let lvl = SecondaryNumber(rawValue: attempt.levelRaw ?? 0) {
                return selectedLevels.contains(lvl)
            }
            return false
        }
    }

    private var avgTries: Double {
        guard !filtered.isEmpty else { return 0 }
        let s = filtered.reduce(0) { $0 + $1.tries }
        return Double(s) / Double(filtered.count)
    }

    private var best: Int {
        filtered.map(\.tries).min() ?? 0
    }

    private var todayCount: Int {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end = cal.date(byAdding: .day, value: 1, to: start)!
        return filtered.filter { $0.date >= start && $0.date < end }.count
    }

    private var recentTries: Int? {
        filtered.sorted(by: { $0.date < $1.date }).last?.tries
    }

    private var distinctLevelsCount: Int {
        let levels = filtered.compactMap { SecondaryNumber(rawValue: $0.levelRaw ?? 0) }
        return Set(levels).count
    }

    var body: some View {
        StatsCardBase(
            title: "记忆练习数据",
            subtitle: "了解你的记忆效率",
            iconName: "brain.head.profile",
            accentColor: Color.customteal
        ) {
            VStack(alignment: .leading, spacing: 12) {

                // Big average tries
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(String(format: "%.1f", avgTries))
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.customteal)
                    Text("次 平均用时")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }

                // 2×2 grid of metrics
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    metricTile(
                        label: "总练习次数",
                        value: "\(filtered.count)",
                        systemImage: "number.circle"
                    )
                    metricTile(
                        label: "今日练习",
                        value: "\(todayCount)",
                        systemImage: "sun.max.fill"
                    )
                    metricTile(
                        label: "最佳（最少）",
                        value: best == 0 ? "—" : "\(best)",
                        systemImage: "sparkles"
                    )
                    metricTile(
                        label: "涉及年级",
                        value: "\(distinctLevelsCount) 个",
                        systemImage: "person.3.fill"
                    )
                }

                // Small recent line (optional)
                if let recent = recentTries {
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text("最近一次用时：\(recent) 次")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 2)
                }
            }
        }
    }
}

// =====================================
// MARK: - Dashboard chart (Home-only, coloured per level)
// =====================================

private enum DashboardDataset {
    case mcq, memory
}

private struct BucketKey: Hashable {
    let index: Int
    let level: SecondaryNumber
}

private struct DashboardBarPoint: Identifiable {
    let id = UUID()
    let xIndex: Int
    let value: Int
    let level: SecondaryNumber
}

private func levelLabel(_ level: SecondaryNumber) -> String {
    switch level {
    case .one:   return "中一"
    case .two:   return "中二"
    case .three: return "中三"
    case .four:  return "中四"
    }
}

private func levelColor(_ level: SecondaryNumber) -> Color {
    switch level {
    case .one:   return .blue
    case .two:   return .orange
    case .three: return .pink
    case .four:  return .purple
    }
}

private struct DashboardChartView: View {
    let dataset: DashboardDataset
    @Binding var range: ScoreRange
    @Binding var selectedLevels: Set<SecondaryNumber>

    @ObservedObject private var scoreManager = ScoreManager.shared
    @ObservedObject private var memoryStats = MemoryStats.shared

    private var mcqFiltered: [QuizResult] {
        if selectedLevels.count == SecondaryNumber.allCases.count {
            return scoreManager.results
        }
        return scoreManager.results.filter { result in
            if let lvl = SecondaryNumber(rawValue: result.levelRaw ?? 0) {
                return selectedLevels.contains(lvl)
            }
            return false
        }
    }

    private var memFiltered: [MemoryAttempt] {
        if selectedLevels.count == SecondaryNumber.allCases.count {
            return memoryStats.attempts
        }
        return memoryStats.attempts.filter { attempt in
            if let lvl = SecondaryNumber(rawValue: attempt.levelRaw ?? 0) {
                return selectedLevels.contains(lvl)
            }
            return false
        }
    }

    private var series: [DashboardBarPoint] {
        switch dataset {
        case .mcq:    return seriesForQuiz(mcqFiltered)
        case .memory: return seriesForMemory(memFiltered)
        }
    }

    private var maxY: Int {
        [Int: [DashboardBarPoint]]
            .init(grouping: series, by: { $0.xIndex })
            .mapValues { $0.reduce(0) { $0 + $1.value } }
            .values
            .max() ?? 0
    }

    var body: some View {
        Chart {
            ForEach(series) { point in
                BarMark(
                    x: .value("Index", point.xIndex),
                    y: .value("Count", point.value)
                )
                .foregroundStyle(by: .value("Level", levelLabel(point.level)))
            }
        }
        .chartLegend(.visible)
        .chartForegroundStyleScale([
            levelLabel(.one):   levelColor(.one),
            levelLabel(.two):   levelColor(.two),
            levelLabel(.three): levelColor(.three),
            levelLabel(.four):  levelColor(.four)
        ])
        .chartYScale(domain: 0...max(1, maxY))
        .frame(height: 220)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }

    // MARK: - Helpers

    private func xIndex(for date: Date) -> Int {
        let cal = Calendar.current
        switch range {
        case .day:
            return cal.component(.hour, from: date)
        case .week:
            let wd = cal.component(.weekday, from: date)
            return (wd + 5) % 7 + 1
        case .month:
            return cal.component(.day, from: date)
        }
    }

    private func inRange(_ date: Date) -> Bool {
        let cal = Calendar.current
        switch range {
        case .day:
            let start = cal.startOfDay(for: Date())
            let end = cal.date(byAdding: .day, value: 1, to: start)!
            return date >= start && date < end
        case .week:
            let start = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
            let end = cal.date(byAdding: .day, value: 7, to: start)!
            return date >= start && date < end
        case .month:
            let comps = cal.dateComponents([.year, .month], from: Date())
            let start = cal.date(from: comps)!
            let end = cal.date(byAdding: .month, value: 1, to: start)!
            return date >= start && date < end
        }
    }

    private func seriesForQuiz(_ items: [QuizResult]) -> [DashboardBarPoint] {
        var dict: [BucketKey: Int] = [:]

        for r in items where inRange(r.date) {
            guard let level = SecondaryNumber(rawValue: r.levelRaw ?? 0),
                  selectedLevels.contains(level) else { continue }
            let idx = xIndex(for: r.date)
            let key = BucketKey(index: idx, level: level)
            dict[key, default: 0] += 1
        }

        var result: [DashboardBarPoint] = []
        for (key, value) in dict {
            result.append(DashboardBarPoint(xIndex: key.index, value: value, level: key.level))
        }

        result.sort {
            if $0.xIndex == $1.xIndex {
                return $0.level.rawValue < $1.level.rawValue
            }
            return $0.xIndex < $1.xIndex
        }
        return result
    }

    private func seriesForMemory(_ items: [MemoryAttempt]) -> [DashboardBarPoint] {
        var dict: [BucketKey: Int] = [:]

        for a in items where inRange(a.date) {
            guard let level = SecondaryNumber(rawValue: a.levelRaw ?? 0),
                  selectedLevels.contains(level) else { continue }
            let idx = xIndex(for: a.date)
            let key = BucketKey(index: idx, level: level)
            dict[key, default: 0] += 1
        }

        var result: [DashboardBarPoint] = []
        for (key, value) in dict {
            result.append(DashboardBarPoint(xIndex: key.index, value: value, level: key.level))
        }

        result.sort {
            if $0.xIndex == $1.xIndex {
                return $0.level.rawValue < $1.level.rawValue
            }
            return $0.xIndex < $1.xIndex
        }
        return result
    }
}

// =====================================
// MARK: - iPad Home dashboard (for Home section)
// =====================================

private struct IPadHomeDashboard: View {
    @Binding var selectedLevels: Set<SecondaryNumber>

    @State private var range: ScoreRange = .week
    @State private var showLevelFilter = false

    private func label(for range: ScoreRange) -> String {
        switch range {
        case .day:   return "D"
        case .week:  return "W"
        case .month: return "M"
        }
    }

    var body: some View {
        ScrollView {
            // ↓ reduce overall spacing between the big sections
            VStack(alignment: .leading, spacing: 20) {

                // 1. Continue bar
                ContinueCarouselView()
                    .frame(height: 190)
                    // ↓ just a small gap before the MCQ section
                    .padding(.bottom, 4)

                // 2. MCQ row
                VStack(alignment: .leading, spacing: 8) {   // was 12
                    HStack(spacing: 8) {
                        Spacer()
                        Text("最近一段时间的练习情况")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 8) {   // was 12
                        HStack(spacing: 8) {
                            Text("MCQ 数据")
                                .font(.title3.weight(.bold))
                                .frame(width: 260, alignment: .leading)
                            Spacer()
                            Picker("", selection: $range) {
                                ForEach(ScoreRange.allCases) { r in
                                    Text(label(for: r))
                                        .font(.subheadline.weight(.semibold))
                                        .tag(r)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(maxWidth: .infinity)

                            Button {
                                showLevelFilter.toggle()
                            } label: {
                                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                    .imageScale(.large)
                                    .padding(8)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                                    .shadow(radius: 1, y: 1)
                            }
                            .popover(isPresented: $showLevelFilter) {
                                LevelChecklist(selectedLevels: $selectedLevels)
                                    .padding()
                            }
                        }
                        .padding(.horizontal, 20)

                        HStack(alignment: .top, spacing: 18) {
                            MCQStatsCard(selectedLevels: $selectedLevels)
                                .frame(width: 260)

                            DashboardChartView(
                                dataset: .mcq,
                                range: $range,
                                selectedLevels: $selectedLevels
                            )
                            .frame(maxWidth: .infinity, minHeight: 220)
                        }
                        .padding(.horizontal, 20)
                    }
                }

                // 3. Memory row
                VStack(alignment: .leading, spacing: 8) {   // was 12
                    HStack(spacing: 8) {
                        Text("记忆练习数据")
                            .font(.title3.weight(.bold))
                        Spacer()
                        Text("查看你记忆练习的节奏和效率")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 20)

                    HStack(alignment: .top, spacing: 18) {
                        MemoryStatsCard(selectedLevels: $selectedLevels)
                            .frame(width: 260)

                        DashboardChartView(
                            dataset: .memory,
                            range: $range,
                            selectedLevels: $selectedLevels
                        )
                        .frame(maxWidth: .infinity, minHeight: 220)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.top, 18)
            .padding(.bottom, 72)
        }
        .background(
            LinearGradient(
                colors: [
                    Color(.systemGroupedBackground),
                    Color.customblue.opacity(0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

// =====================================
// MARK: - HomeView
// =====================================

struct HomeView: View {
    @ObservedObject var pathManager: PathManager = .global
    @ObservedObject var progressManager = ProgressManager.shared
    @EnvironmentObject var deviceTypeManager: DeviceTypeManager

    // iPad-only
    @State private var selectedLevels: Set<SecondaryNumber> =
        Set(SecondaryNumber.allCases)
    @State private var iPadRootSection: IPadRootSection = .home
    @State private var splitVisibility: NavigationSplitViewVisibility = .all

    // Folder manager for the Folders tab
    @StateObject private var vocabManager = VocabManager()

    // MARK: - Body

    @ViewBuilder
    var body: some View {
        if deviceTypeManager.deviceType == .ipad(.regular) {
            iPadTabRootView
        } else {
            iPhoneRootView
        }
    }

    // MARK: - iPad root view: TabView OUTSIDE navigation, sidebar collapsible via NavigationSplitView

    private var iPadTabRootView: some View {
        TabView(selection: $iPadRootSection) {

            // HOME TAB
            NavigationSplitView(
                columnVisibility: $splitVisibility.animation(.easeInOut(duration: 0.25))
            ) {
                LevelSidebar(rootSection: $iPadRootSection)
            } detail: {
                iPadHomeNavigation
                    .background(
                        LinearGradient(
                            colors: [
                                Color(.systemGroupedBackground),
                                Color.customblue.opacity(0.03)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea()
                    )
            }
            .tag(IPadRootSection.home)
            .tabItem {
                Label("Home", systemImage: IPadRootSection.home.iconName)
            }

            // NOTES TAB
            NotesView()
                .tag(IPadRootSection.notes)
                .tabItem {
                    Label("Notes", systemImage: IPadRootSection.notes.iconName)
                }

            // FOLDERS TAB
            FolderView(vocabManager: vocabManager)
                .tag(IPadRootSection.folders)
                .tabItem {
                    Label("Folders", systemImage: IPadRootSection.folders.iconName)
                }

            // SETTINGS TAB
            SettingsView()
                .tag(IPadRootSection.settings)
                .tabItem {
                    Label("Settings", systemImage: IPadRootSection.settings.iconName)
                }
        }
    }

    // Home section wrapped in NavigationStack for Route navigation (iPad)
    private var iPadHomeNavigation: some View {
        NavigationStack(path: $pathManager.path) {
            IPadHomeDashboard(selectedLevels: $selectedLevels)
                // Hide Home nav bar so it doesn’t push content down
                .toolbar(.hidden, for: .navigationBar)
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

                    case .resume(let level, let chapter, let topic):
                        if let resume = LastProgressStore.getAll()
                            .first(where: { $0.level == level && $0.chapter == chapter && $0.topic == topic }) {
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

    // MARK: - iPhone root view (unchanged layout)

    private var iPhoneRootView: some View {
        TabView {
            NavigationStack(path: $pathManager.path) {
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(.systemGroupedBackground),
                            Color.customblue.opacity(0.06)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()

                    VStack(spacing: 20) {
                        ContinueCarouselView()

                        VStack(spacing: 14) {
                            HStack(spacing: 14) {
                                navigationTile(level: .one)
                                navigationTile(level: .two)
                            }
                            .padding(.horizontal, 20)

                            HStack(spacing: 14) {
                                navigationTile(level: .three)
                                navigationTile(level: .four)
                            }
                            .padding(.horizontal, 20)
                        }

                        NavigationLink(value: Route.olevelsMenu) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("O 水准备考")
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundStyle(.white)
                                Text("专为终考准备的强化练习")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.9))
                            }
                            .padding(24)
                            .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
                            .background(
                                LinearGradient(
                                    colors: [Color.customteal, Color.customblue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .shadow(color: .black.opacity(0.18), radius: 12, x: 0, y: 6)
                            .padding([.horizontal, .bottom], 20)
                        }
                        .buttonStyle(.plain)
                    }
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

                    case .resume(let level, let chapter, let topic):
                        if let resume = LastProgressStore.getAll()
                            .first(where: { $0.level == level && $0.chapter == chapter && $0.topic == topic }) {
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
            .tabItem {
                Label("Home", systemImage: IPadRootSection.home.iconName)
            }

            // NOTES TAB
            NotesView()
                .tabItem {
                    Label("Notes", systemImage: IPadRootSection.notes.iconName)
                }

            // FOLDERS TAB
            FolderView(vocabManager: vocabManager)
                .tabItem {
                    Label("Folders", systemImage: IPadRootSection.folders.iconName)
                }

            // SETTINGS TAB
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: IPadRootSection.settings.iconName)
                }
        }
    }
}

