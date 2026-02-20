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
// MARK: - Continue Carousel
// =====================================

private struct ContinueCarouselView: View {
    @ObservedObject var pathManager: PathManager = .global
    @State private var allProgress: [LastProgressStore.Point] = []
    
    @EnvironmentObject private var deviceType: DeviceTypeManager

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
                                    Color.customteal,
                                    Color.customblue
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    TabView {
                        ForEach(Array(allProgress.enumerated()), id: \.offset) { idx, point in
                            if deviceType.isIPad {
                                NavigationLink {
                                    if let resume = LastProgressStore.getAll()
                                        .first(where: { $0.level == point.level && $0.chapter == point.chapter && $0.topic == point.topic }) {
                                        FlashcardView(
                                            vocabularies: loadVocabulariesFromJSON(
                                                fileName: "中\(resume.level.string)",
                                                chapter: resume.chapter.string,
                                                topic: resume.topic.string(level: resume.level, chapter: resume.chapter)
                                            ),
                                            level: resume.level,
                                            chapter: resume.chapter,
                                            topic: resume.topic,
                                            currentIndex: resume.currentIndex
                                        )
                                    }
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
                            } else {
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
                NavigationLink {
                    let practice = OLevels.midyear
                    let vocabs = Array(allVocabularies(for: practice).shuffled().prefix(15))
                    MCQView(
                        vocabularies: vocabs,
                        folderName: practice.string
                    )
                    .navigationTitle(practice.string)
                    .navigationBarTitleDisplayMode(.inline)
                } label: {
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
                            colors: [Color.white, Color.customgray.opacity(0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
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

                NavigationLink {
                    let practice = OLevels.endofyear
                    MCQView(
                        vocabularies:  Array(allVocabularies(for: practice).shuffled().prefix(15)),
                        folderName: practice.string
                    )
                    .navigationTitle(practice.string)
                    .navigationBarTitleDisplayMode(.inline)
                } label: {
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
                            colors: [Color.white, Color.customgray.opacity(0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
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
        Group {
            if #available(iOS 26.0, *) {
                main
                    .clipShape(Capsule())
                    .accessibilityLabel("Progress. Today \(todayCount) quizzes. Overall average \(overallAvg) percent.")
            } else {
                main
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
    }

    var main: some View {
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
                            .foregroundStyle(.accent)
                        Text("中\(level.string)")
                    }
                    .font(.body)
                }
                .buttonStyle(.plain)
            }
        }
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
    let xIndex: Int        // bucket index (hour / weekday / day)
    let value: Double      // 0–100 accuracy
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

    // Final series after bucketing + averaging (0–100%)
    private var series: [DashboardBarPoint] {
        switch dataset {
        case .mcq:    return seriesForQuiz(filteredMCQ)
        case .memory: return seriesForMemory(filteredMemory)
        }
    }

    // Filter raw data by selected levels first
    private var filteredMCQ: [QuizResult] {
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

    private var filteredMemory: [MemoryAttempt] {
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

    var body: some View {
        // ✅ Fixed width – DOESN'T change when you filter levels
        let barWidth = MarkDimension(integerLiteral: 18)

        Chart {
            ForEach(series) { point in
                BarMark(
                    x: .value("Time", point.xIndex),     // Int bucket index
                    y: .value("Accuracy", point.value),  // 0–100
                    width: barWidth
                )
                .position(by: .value("Level", levelLabel(point.level)))
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

        // MARK: X-Axis – D / W / M
        .chartXScale(domain: xAxisDomain())
        .chartXAxis {
            AxisMarks(values: xAxisTickValues()) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let intVal = value.as(Int.self) {
                        Text(xAxisLabel(for: intVal))
                    }
                }
            }
        }

        // MARK: Y-Axis: 0%, 50%, 100%
        .chartYScale(domain: 0...100)
        .chartYAxis {
            AxisMarks(values: [0, 50, 100]) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let intVal = value.as(Int.self) {
                        switch intVal {
                        case 0:   Text("0%")
                        case 50:  Text("50%")
                        case 100: Text("100%")
                        default:  Text("\(intVal)")
                        }
                    }
                }
            }
        }
        .chartScrollableAxes([.horizontal, .vertical])

        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }

    // MARK: - X-axis helpers (Int-based)

    private func xAxisDomain() -> ClosedRange<Int> {
        switch range {
        case .day:
            return 0...23               // hours
        case .week:
            return 1...7                // Mon–Sun
        case .month:
            return 1...31               // day-of-month
        }
    }

    private func xAxisTickValues() -> [Int] {
        switch range {
        case .day:
            return [0, 6, 12, 18]       // 12AM, 6AM, 12PM, 6PM
        case .week:
            return Array(1...7)         // Mon–Sun
        case .month:
            return [1, 8, 15, 22, 29]   // key dates
        }
    }

    private func xAxisLabel(for value: Int) -> String {
        switch range {
        case .day:
            switch value {
            case 0:  return "12AM"
            case 6:  return "6AM"
            case 12: return "12PM"
            case 18: return "6PM"
            default: return ""
            }
        case .week:
            switch value {
            case 1: return "Mon"
            case 2: return "Tue"
            case 3: return "Wed"
            case 4: return "Thu"
            case 5: return "Fri"
            case 6: return "Sat"
            case 7: return "Sun"
            default: return ""
            }
        case .month:
            return "\(value)"
        }
    }

    // MARK: - Date bucketing

    private func xIndex(for date: Date) -> Int {
        let cal = Calendar.current
        switch range {
        case .day:
            return cal.component(.hour, from: date)
        case .week:
            let wd = cal.component(.weekday, from: date)
            // Map to Mon=1 ... Sun=7
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

    // MARK: - MCQ series (average percent per bucket)

    private func seriesForQuiz(_ items: [QuizResult]) -> [DashboardBarPoint] {
        // bucket → (sum of percent, count)
        var bucket: [BucketKey: (sum: Double, count: Int)] = [:]

        for r in items where inRange(r.date) {
            guard let level = SecondaryNumber(rawValue: r.levelRaw ?? 0),
                  selectedLevels.contains(level) else { continue }

            let idx = xIndex(for: r.date)
            let key = BucketKey(index: idx, level: level)

            var entry = bucket[key] ?? (0, 0)
            entry.sum += r.percent
            entry.count += 1
            bucket[key] = entry
        }

        var result: [DashboardBarPoint] = []
        for (key, entry) in bucket {
            let avg = entry.count > 0 ? entry.sum / Double(entry.count) : 0
            result.append(DashboardBarPoint(
                xIndex: key.index,
                value: min(max(avg, 0), 100),
                level: key.level
            ))
        }

        result.sort {
            if $0.xIndex == $1.xIndex {
                return $0.level.rawValue < $1.level.rawValue
            }
            return $0.xIndex < $1.xIndex
        }
        return result
    }

    // MARK: - Memory series (convert tries → score out of 100)

    private func seriesForMemory(_ items: [MemoryAttempt]) -> [DashboardBarPoint] {
        // Simple mapping: 1 try = 100%, 2 tries = 50%, etc.
        var bucket: [BucketKey: (sum: Double, count: Int)] = [:]

        for a in items where inRange(a.date) {
            guard let level = SecondaryNumber(rawValue: a.levelRaw ?? 0),
                  selectedLevels.contains(level) else { continue }

            let idx = xIndex(for: a.date)
            let key = BucketKey(index: idx, level: level)

            let score: Double
            if a.tries <= 0 {
                score = 0
            } else {
                score = min(100, 100.0 / Double(a.tries))
            }

            var entry = bucket[key] ?? (0, 0)
            entry.sum += score
            entry.count += 1
            bucket[key] = entry
        }

        var result: [DashboardBarPoint] = []
        for (key, entry) in bucket {
            let avg = entry.count > 0 ? entry.sum / Double(entry.count) : 0
            result.append(DashboardBarPoint(
                xIndex: key.index,
                value: min(max(avg, 0), 100),
                level: key.level
            ))
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
                    .padding(.bottom, 20)

                // 2. MCQ row
                VStack(alignment: .leading, spacing: 8) {   // was 12
                    HStack(spacing: 8) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("MCQ 数据")
                                .font(.title3.weight(.bold))
                            Text("最近一段时间的练习情况")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
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

                // 3. Memory row
                VStack(alignment: .leading, spacing: 8) {   // was 12
                    VStack(alignment: .leading, spacing: 4) {
                        Text("记忆练习数据")
                            .font(.title3.weight(.bold))
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

    // MARK: - iPad root view

    private var iPadTabRootView: some View {
        Group {
            if #available(iOS 18.0, *) {
                TabView {
                    Tab("Home", systemImage: "house.fill") {
                        NavigationStack {
                            IPadHomeDashboard(selectedLevels: $selectedLevels)
                        }
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
                    // NOTES TAB
                    Tab("Notes", systemImage: "note.text") {
                        NotesView()
                    }

                    // FOLDERS TAB
                    Tab("Folders", systemImage: "folder.fill") {
                        FolderView(vocabManager: vocabManager)
                    }

                    // SETTINGS TAB
                    Tab("Settings", systemImage: "gearshape.fill") {
                        SettingsView()
                    }

                    TabSection("年级") {
                        Tab("中一", systemImage: "1.circle.fill") {
                            NavigationStack {
                                ChapterView(level: .one)
                            }
                        }

                        Tab("中二", systemImage: "2.circle.fill") {
                            NavigationStack {
                                ChapterView(level: .two)
                            }
                        }

                        Tab("中三", systemImage: "3.circle.fill") {
                            NavigationStack {
                                ChapterView(level: .three)
                            }
                        }

                        Tab("中四", systemImage: "4.circle.fill") {
                            NavigationStack {
                                ChapterView(level: .four)
                            }
                        }

                        Tab("O 水准备考", systemImage: "circle.circle.fill") {
                            NavigationStack {
                                OLevelsMenuView()
                            }
                        }
                    }
                    .defaultVisibility(.hidden, for: .tabBar)
                }
                .tabViewStyle(.sidebarAdaptable)
            } else {
                TabView {
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }

                    // NOTES TAB
                    NotesView()
                        .tabItem {
                            Label("Notes", systemImage: "note.text")
                        }

                    // FOLDERS TAB
                    FolderView(vocabManager: vocabManager)
                        .tabItem {
                            Label("Folders", systemImage: "folder.fill")
                        }

                    // SETTINGS TAB
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
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
                Label("Home", systemImage: "house.fill")
            }

            // NOTES TAB
            NotesView()
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }

            // FOLDERS TAB
            FolderView(vocabManager: vocabManager)
                .tabItem {
                    Label("Folders", systemImage: "folder.fill")
                }

            // SETTINGS TAB
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}

