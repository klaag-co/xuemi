import SwiftUI
import Charts

// MARK: - Level filter (folders)

private enum LevelFolder: String, CaseIterable, Identifiable {
    case all = "All", one = "中一", two = "中二", three = "中三", four = "中四"
    var id: String { rawValue }
    var level: SecondaryNumber? {
        switch self {
        case .all:   return nil
        case .one:   return .one
        case .two:   return .two
        case .three: return .three
        case .four:  return .four
        }
    }
}

// MCQ vs Memory selector
private enum DatasetType: String, CaseIterable, Identifiable {
    case mcq = "MCQ"
    case memory = "Memory"
    var id: String { rawValue }
}

// Simple chart datapoint
private struct BarPoint: Identifiable {
    let id = UUID()
    let xIndex: Int
    let value: Int
}

// MARK: - Progress Detail

struct ProgressDetailView: View {
    @StateObject private var scoreManager = ScoreManager.shared
    @StateObject private var memoryStats = MemoryStats.shared

    @State private var dataset: DatasetType = .mcq
    @State private var range: ScoreRange = .week
    @State private var folder: LevelFolder = .all
    @State private var isEditing = false

    // Delete confirmations
    @State private var pendingQuizToDelete: QuizResult?
    @State private var showDeleteQuiz = false

    @State private var pendingAttemptToDelete: MemoryAttempt?
    @State private var showDeleteAttempt = false

    // MARK: - Filtering

    private var mcqFiltered: [QuizResult] {
        if let lvl = folder.level { return scoreManager.results.filter { $0.levelRaw == lvl.rawValue } }
        return scoreManager.results
    }
    private var memFiltered: [MemoryAttempt] {
        if let lvl = folder.level { return memoryStats.attempts.filter { $0.levelRaw == lvl.rawValue } }
        return memoryStats.attempts
    }

    private var mcqInRange: [QuizResult] { mcqFiltered.filter { inRange($0.date) } }
    private var memInRange: [MemoryAttempt] { memFiltered.filter { inRange($0.date) } }

    // Stats
    private var mcqOverallAvg: Double {
        guard !mcqFiltered.isEmpty else { return 0 }
        return mcqFiltered.reduce(0.0) { $0 + $1.percent } / Double(mcqFiltered.count)
    }
    private var mcqBest: Double { mcqFiltered.map(\.percent).max() ?? 0 }

    private var memAvg: Double {
        guard !memFiltered.isEmpty else { return 0 }
        let s = memFiltered.reduce(0) { $0 + $1.tries }
        return Double(s) / Double(memFiltered.count)
    }
    private var memBest: Int { memFiltered.map(\.tries).min() ?? 0 }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Header (adaptive)
                HeaderView(
                    dataset: $dataset,
                    range: $range,
                    title: "Scores",
                    subtitle: subtitleForRange(range)
                )
                .padding(.top, 4)

                // Folders segmented (All / 中一 / 中二 / 中三 / 中四)
                Picker("", selection: $folder) {
                    ForEach(LevelFolder.allCases) { f in Text(f.rawValue).tag(f) }
                }
                .pickerStyle(.segmented)

                // ===== Chart =====
                ChartSection(
                    series: makeSeries(),
                    maxY: chartMaxY(),
                    range: range,
                    title: (dataset == .mcq ? "QUIZZES" : "ATTEMPTS")
                )

                // ===== Stats =====
                HStack(spacing: 12) {
                    if dataset == .mcq {
                        StatCard(title: "Quizzes", value: "\(mcqFiltered.count)")
                        StatCard(title: "Overall Avg", value: String(format: "%.0f%%", mcqOverallAvg))
                        StatCard(title: "Best", value: String(format: "%.0f%%", mcqBest))
                    } else {
                        StatCard(title: "Attempts", value: "\(memFiltered.count)")
                        StatCard(title: "Average Tries", value: String(format: "%.1f", memAvg))
                        StatCard(title: "Best (Least)", value: "\(memBest)")
                    }
                }

                // ===== Recent =====
                RecentSection(
                    dataset: dataset,
                    isEditing: $isEditing,
                    mcqItems: mcqFiltered.sorted(by: { $0.date > $1.date }),
                    memItems: memFiltered.sorted(by: { $0.date > $1.date }),
                    onTapMCQ: { r in
                        withAnimation { PathManager.global.path.append(Route.replay(r)) }
                    },
                    onTapMem: { a in
                        withAnimation { PathManager.global.path.append(Route.replayMemory(a)) }
                    },
                    onDeleteMCQ: { r in
                        pendingQuizToDelete = r
                        showDeleteQuiz = true
                    },
                    onDeleteMem: { a in
                        pendingAttemptToDelete = a
                        showDeleteAttempt = true
                    }
                )
            }
            .padding()
        }
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.inline)

        // Delete confirmations (use confirmationDialog to avoid type-checker headaches)
        .confirmationDialog(
            "Delete this quiz?",
            isPresented: $showDeleteQuiz,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let q = pendingQuizToDelete {
                    withAnimation { ScoreManager.shared.delete(q) }
                }
                pendingQuizToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                pendingQuizToDelete = nil
            }
        }

        .confirmationDialog(
            "Delete this attempt?",
            isPresented: $showDeleteAttempt,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let a = pendingAttemptToDelete {
                    withAnimation { MemoryStats.shared.delete(a) }
                }
                pendingAttemptToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                pendingAttemptToDelete = nil
            }
        }
    }

    // MARK: - Chart builders

    private func chartMaxY() -> Int {
        switch dataset {
        case .mcq:    return series(for: mcqInRange).map(\.value).max() ?? 0
        case .memory: return series(for: memInRange).map(\.value).max() ?? 0
        }
    }

    private func makeSeries() -> [BarPoint] {
        dataset == .mcq ? series(for: mcqInRange) : series(for: memInRange)
    }

    private func series(for items: [QuizResult]) -> [BarPoint] {
        let cal = Calendar.current
        switch range {
        case .day:
            var b = Array(repeating: 0, count: 24)
            for r in items { b[cal.component(.hour, from: r.date)] += 1 }
            return (0..<24).map { BarPoint(xIndex: $0, value: b[$0]) }

        case .week:
            var b = Array(repeating: 0, count: 7)
            for r in items {
                let wd = cal.component(.weekday, from: r.date) // 1=Sun..7=Sat
                let idx = (wd + 5) % 7 // 0=Mon..6=Sun
                b[idx] += 1
            }
            return (0..<7).map { BarPoint(xIndex: $0 + 1, value: b[$0]) }

        case .month:
            let comps = cal.dateComponents([.year, .month], from: Date())
            let start = cal.date(from: comps)!
            let days = cal.range(of: .day, in: .month, for: start)!.count
            var b = Array(repeating: 0, count: days)
            for r in items {
                let d = cal.component(.day, from: r.date)
                if (1...days).contains(d) { b[d-1] += 1 }
            }
            return (1...days).map { BarPoint(xIndex: $0, value: b[$0-1]) }
        }
    }

    private func series(for items: [MemoryAttempt]) -> [BarPoint] {
        let cal = Calendar.current
        switch range {
        case .day:
            var b = Array(repeating: 0, count: 24)
            for a in items { b[cal.component(.hour, from: a.date)] += 1 }
            return (0..<24).map { BarPoint(xIndex: $0, value: b[$0]) }

        case .week:
            var b = Array(repeating: 0, count: 7)
            for a in items {
                let wd = cal.component(.weekday, from: a.date)
                let idx = (wd + 5) % 7
                b[idx] += 1
            }
            return (0..<7).map { BarPoint(xIndex: $0 + 1, value: b[$0]) }

        case .month:
            let comps = cal.dateComponents([.year, .month], from: Date())
            let start = cal.date(from: comps)!
            let days = cal.range(of: .day, in: .month, for: start)!.count
            var b = Array(repeating: 0, count: days)
            for a in items {
                let d = cal.component(.day, from: a.date)
                if (1...days).contains(d) { b[d-1] += 1 }
            }
            return (1...days).map { BarPoint(xIndex: $0, value: b[$0-1]) }
        }
    }

    // MARK: - Range helpers

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

    private func subtitleForRange(_ r: ScoreRange) -> String {
        switch r { case .day: return "Today"; case .week: return "This Week"; case .month: return "This Month" }
    }
}

// MARK: - Adaptive header

private struct HeaderView: View {
    @Binding var dataset: DatasetType
    @Binding var range: ScoreRange
    let title: String
    let subtitle: String

    var body: some View {
        ViewThatFits(in: .horizontal) {
            // Wide: title + pickers inline
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                TitleBlock()
                Spacer(minLength: 12)
                PickersRow()
            }
            // Compact: stack
            VStack(alignment: .leading, spacing: 12) {
                TitleBlock()
                PickersRow()
            }
        }
        .animation(.easeInOut, value: dataset)
        .animation(.easeInOut, value: range)
    }

    @ViewBuilder private func TitleBlock() -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.largeTitle).bold()
            Text(subtitle).foregroundStyle(.secondary)
        }
    }

    @ViewBuilder private func PickersRow() -> some View {
        HStack(spacing: 8) {
            Picker("", selection: $dataset) {
                ForEach(DatasetType.allCases) { t in Text(t.rawValue).tag(t) }
            }
            .pickerStyle(.segmented)
            .layoutPriority(1)

            Picker("", selection: $range) {
                ForEach(ScoreRange.allCases) { r in Text(r.rawValue).tag(r) }
            }
            .pickerStyle(.segmented)
            .layoutPriority(1)
        }
    }
}

// MARK: - Chart section

private struct ChartSection: View {
    let series: [BarPoint]
    let maxY: Int
    let range: ScoreRange
    let title: String

    var body: some View {
        ChartCard(title: title) {
            Chart(series) { p in
                BarMark(x: .value("Index", p.xIndex), y: .value("Count", p.value))
            }
            .chartYAxis(.hidden) // hide Y-axis numbers
            .chartXAxis {
                AxisMarks(values: xTickValues(range: range)) { v in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let i = v.as(Int.self) { Text(xTickLabel(range: range, index: i)) }
                    }
                }
            }
            .chartYScale(domain: 0...max(1, maxY))
            .frame(height: 180)
        }
    }

    private func xTickValues(range: ScoreRange) -> [Int] {
        switch range {
        case .day:   return [0, 6, 12, 18, 23]
        case .week:  return [1, 2, 3, 4, 5, 6, 7]
        case .month:
            let cal = Calendar.current
            let comps = cal.dateComponents([.year, .month], from: Date())
            let start = cal.date(from: comps)!
            let days = cal.range(of: .day, in: .month, for: start)!.count
            return [1, 8, 15, 22, 29].filter { $0 <= days }
        }
    }

    private func xTickLabel(range: ScoreRange, index: Int) -> String {
        switch range {
        case .day:
            switch index {
            case 0:  return "12AM"
            case 6:  return "6AM"
            case 12: return "12PM"
            case 18: return "6PM"
            case 23: return "11PM"
            default: return ""
            }
        case .week:
            return ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"][max(1, min(index, 7)) - 1]
        case .month:
            return "\(index)"
        }
    }
}

// MARK: - Recent section (with fixed Edit disable)

private struct RecentSection: View {
    let dataset: DatasetType
    @Binding var isEditing: Bool

    let mcqItems: [QuizResult]
    let memItems: [MemoryAttempt]

    let onTapMCQ: (QuizResult) -> Void
    let onTapMem: (MemoryAttempt) -> Void
    let onDeleteMCQ: (QuizResult) -> Void
    let onDeleteMem: (MemoryAttempt) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Recent").font(.headline)
                Spacer()

                // Avoid ternary returning different array types — compute a Bool
                let nothingToEdit: Bool = {
                    switch dataset {
                    case .mcq:    return mcqItems.isEmpty
                    case .memory: return memItems.isEmpty
                    }
                }()

                Button(isEditing ? "Done" : "Edit") {
                    withAnimation { isEditing.toggle() }
                }
                .disabled(nothingToEdit)
            }

            if dataset == .mcq {
                ForEach(mcqItems.prefix(50)) { r in
                    HStack(spacing: 12) {
                        if isEditing {
                            Button { onDeleteMCQ(r) } label: {
                                Image(systemName: "trash.circle.fill")
                                    .foregroundStyle(.red)
                                    .font(.title3)
                            }
                            RecentRowMCQ(quiz: r)
                        } else {
                            Button { onTapMCQ(r) } label: {
                                RecentRowMCQ(quiz: r)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    Divider().opacity(0.25)
                }
            } else {
                ForEach(memItems.prefix(50)) { a in
                    HStack(spacing: 12) {
                        if isEditing {
                            Button { onDeleteMem(a) } label: {
                                Image(systemName: "trash.circle.fill")
                                    .foregroundStyle(.red)
                                    .font(.title3)
                            }
                            RecentRowMemory(attempt: a)
                        } else {
                            Button { onTapMem(a) } label: {
                                RecentRowMemory(attempt: a)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    Divider().opacity(0.25)
                }
            }
        }
    }
}

// MARK: - Small pieces

private struct ChartCard<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            content
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct StatCard: View {
    let title: String, value: String
    var body: some View {
        VStack(spacing: 6) {
            Text(value).font(.title3).bold()
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct RecentRowMCQ: View {
    let quiz: QuizResult
    private static let mdFormatter: DateFormatter = { let f = DateFormatter(); f.dateFormat = "M/d"; return f }()
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(quiz.contextTitle.isEmpty ? "Practice" : quiz.contextTitle)
                    .font(.subheadline).lineLimit(1)
                Text(quiz.date, formatter: Self.mdFormatter)
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(Int(round(quiz.percent)))%").font(.headline)
        }
        .padding(.vertical, 6)
    }
}

private struct RecentRowMemory: View {
    let attempt: MemoryAttempt
    private static let mdFormatter: DateFormatter = { let f = DateFormatter(); f.dateFormat = "M/d"; return f }()
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(attempt.contextTitle.isEmpty ? "Practice" : attempt.contextTitle)
                    .font(.subheadline).lineLimit(1)
                Text(attempt.date, formatter: Self.mdFormatter)
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(attempt.tries) tries").font(.headline)
        }
        .padding(.vertical, 6)
    }
}

