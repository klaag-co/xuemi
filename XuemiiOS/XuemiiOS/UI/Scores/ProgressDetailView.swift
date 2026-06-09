import SwiftUI
import Charts

// MARK: - Level filter (folders)

private enum LevelFolder: String, CaseIterable, Identifiable {
    case all = "All", one = "中一", two = "中二", three = "中三", four = "中四"
    var id: String { rawValue }

    var level: SecondaryNumber? {
        switch self {
        case .all: return nil
        case .one: return .one
        case .two: return .two
        case .three: return .three
        case .four: return .four
        }
    }
}

private enum DatasetType: String, CaseIterable, Identifiable {
    case mcq = "MCQ"
    case memory = "Memory"
    var id: String { rawValue }
}

private struct ChartDetailItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let percent: Double
}

private struct BarPoint: Identifiable {
    let id = UUID()
    let xIndex: Int
    let value: Double
    let details: [ChartDetailItem]
}

// MARK: - Progress Detail

struct ProgressDetailView: View {
    @StateObject private var scoreManager = ScoreManager.shared
    @StateObject private var memoryStats = MemoryStats.shared

    @State private var dataset: DatasetType = .mcq
    @State private var range: ScoreRange = .week
    @State private var folder: LevelFolder = .all

    private let availableRanges: [ScoreRange] = [.week, .month]

    private var mcqFiltered: [QuizResult] {
        if let lvl = folder.level {
            return scoreManager.results.filter { $0.levelRaw == lvl.rawValue }
        }
        return scoreManager.results
    }

    private var memFiltered: [MemoryAttempt] {
        if let lvl = folder.level {
            return memoryStats.attempts.filter { $0.levelRaw == lvl.rawValue }
        }
        return memoryStats.attempts
    }

    private var mcqInRange: [QuizResult] {
        mcqFiltered.filter { inRange($0.date) }
    }

    private var memInRange: [MemoryAttempt] {
        memFiltered.filter { inRange($0.date) }
    }

    private var mcqOverallAvg: Double {
        guard !mcqFiltered.isEmpty else { return 0 }
        return mcqFiltered.reduce(0.0) { $0 + $1.percent } / Double(mcqFiltered.count)
    }

    private var mcqBest: Double {
        mcqFiltered.map(\.percent).max() ?? 0
    }

    private var memAvg: Double {
        guard !memFiltered.isEmpty else { return 0 }
        let s = memFiltered.reduce(0) { $0 + $1.tries }
        return Double(s) / Double(memFiltered.count)
    }

    private var memBest: Int {
        memFiltered.map(\.tries).min() ?? 0
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                HeaderView(
                    dataset: $dataset,
                    range: $range,
                    availableRanges: availableRanges,
                    title: "Scores",
                    subtitle: subtitleForRange(range)
                )
                .padding(.top, 4)

                Picker("", selection: $folder) {
                    ForEach(LevelFolder.allCases) { f in
                        Text(f.rawValue).tag(f)
                    }
                }
                .pickerStyle(.segmented)

                ChartSection(
                    series: makeSeries(),
                    range: range,
                    title: dataset == .mcq ? "QUIZZES" : "MEMORY SCORE"
                )

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
            }
            .padding()
        }
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Chart builders

    private func makeSeries() -> [BarPoint] {
        dataset == .mcq ? series(for: mcqInRange) : series(for: memInRange)
    }

    private func series(for items: [QuizResult]) -> [BarPoint] {
        let cal = Calendar.current

        switch range {
        case .week:
            var sums = Array(repeating: 0.0, count: 7)
            var counts = Array(repeating: 0, count: 7)
            var details = Array(repeating: [ChartDetailItem](), count: 7)

            for r in items {
                let wd = cal.component(.weekday, from: r.date)
                let idx = (wd + 5) % 7

                sums[idx] += r.percent
                counts[idx] += 1

                details[idx].append(
                    ChartDetailItem(
                        title: r.contextTitle.isEmpty ? "MCQ Quiz" : r.contextTitle,
                        subtitle: formattedDate(r.date),
                        percent: r.percent
                    )
                )
            }

            return (0..<7).map {
                let avg = counts[$0] == 0 ? 0 : sums[$0] / Double(counts[$0])
                return BarPoint(xIndex: $0 + 1, value: avg, details: details[$0])
            }

        case .month:
            var sums = Array(repeating: 0.0, count: 5)
            var counts = Array(repeating: 0, count: 5)
            var details = Array(repeating: [ChartDetailItem](), count: 5)

            for r in items {
                let day = cal.component(.day, from: r.date)
                let weekIndex = min((day - 1) / 7, 4)

                sums[weekIndex] += r.percent
                counts[weekIndex] += 1

                details[weekIndex].append(
                    ChartDetailItem(
                        title: r.contextTitle.isEmpty ? "MCQ Quiz" : r.contextTitle,
                        subtitle: formattedDate(r.date),
                        percent: r.percent
                    )
                )
            }

            return (0..<5).map {
                let avg = counts[$0] == 0 ? 0 : sums[$0] / Double(counts[$0])
                return BarPoint(xIndex: $0 + 1, value: avg, details: details[$0])
            }

        case .day:
            return []
        }
    }

    private func series(for items: [MemoryAttempt]) -> [BarPoint] {
        let cal = Calendar.current

        switch range {
        case .week:
            var sums = Array(repeating: 0.0, count: 7)
            var counts = Array(repeating: 0, count: 7)
            var details = Array(repeating: [ChartDetailItem](), count: 7)

            for a in items {
                let wd = cal.component(.weekday, from: a.date)
                let idx = (wd + 5) % 7
                let score = memoryScorePercent(for: a)

                sums[idx] += score
                counts[idx] += 1

                details[idx].append(
                    ChartDetailItem(
                        title: a.contextTitle.isEmpty ? "Memory Attempt" : a.contextTitle,
                        subtitle: "\(a.tries) tries • \(formattedDate(a.date))",
                        percent: score
                    )
                )
            }

            return (0..<7).map {
                let avg = counts[$0] == 0 ? 0 : sums[$0] / Double(counts[$0])
                return BarPoint(xIndex: $0 + 1, value: avg, details: details[$0])
            }

        case .month:
            var sums = Array(repeating: 0.0, count: 5)
            var counts = Array(repeating: 0, count: 5)
            var details = Array(repeating: [ChartDetailItem](), count: 5)

            for a in items {
                let day = cal.component(.day, from: a.date)
                let weekIndex = min((day - 1) / 7, 4)
                let score = memoryScorePercent(for: a)

                sums[weekIndex] += score
                counts[weekIndex] += 1

                details[weekIndex].append(
                    ChartDetailItem(
                        title: a.contextTitle.isEmpty ? "Memory Attempt" : a.contextTitle,
                        subtitle: "\(a.tries) tries • \(formattedDate(a.date))",
                        percent: score
                    )
                )
            }

            return (0..<5).map {
                let avg = counts[$0] == 0 ? 0 : sums[$0] / Double(counts[$0])
                return BarPoint(xIndex: $0 + 1, value: avg, details: details[$0])
            }

        case .day:
            return []
        }
    }

    private func memoryScorePercent(for attempt: MemoryAttempt) -> Double {
        guard attempt.tries > 0 else { return 0 }
        return min(100, 100.0 / Double(attempt.tries))
    }

    private func inRange(_ date: Date) -> Bool {
        let cal = Calendar.current

        switch range {
        case .week:
            let start = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
            let end = cal.date(byAdding: .day, value: 7, to: start)!
            return date >= start && date < end

        case .month:
            let comps = cal.dateComponents([.year, .month], from: Date())
            let start = cal.date(from: comps)!
            let end = cal.date(byAdding: .month, value: 1, to: start)!
            return date >= start && date < end

        case .day:
            return false
        }
    }

    private func subtitleForRange(_ r: ScoreRange) -> String {
        switch r {
        case .week: return "This Week"
        case .month: return "This Month"
        case .day: return "Today"
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "d MMM, h:mm a"
        return f.string(from: date)
    }
}

// MARK: - Header

private struct HeaderView: View {
    @Binding var dataset: DatasetType
    @Binding var range: ScoreRange

    let availableRanges: [ScoreRange]
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.largeTitle)
                    .bold()

                Text(subtitle)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                Picker("", selection: $dataset) {
                    ForEach(DatasetType.allCases) { t in
                        Text(t.rawValue).tag(t)
                    }
                }
                .pickerStyle(.segmented)

                Picker("", selection: $range) {
                    ForEach(availableRanges, id: \.self) { r in
                        Text(r.rawValue).tag(r)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 120)
            }
        }
    }
}

// MARK: - Chart section

private struct ChartSection: View {
    let series: [BarPoint]
    let range: ScoreRange
    let title: String

    @State private var selectedX: Int?
    @State private var showDetails = false
    @State private var showHelp = false

    private var selectedPoint: BarPoint? {
        guard let selectedX else { return nil }
        return series.first { $0.xIndex == selectedX }
    }

    var body: some View {
        ChartCard(title: title, showHelp: $showHelp) {
            Chart {
                ForEach(series) { p in
                    BarMark(
                        x: .value("Index", p.xIndex),
                        y: .value("Score", p.value),
                        width: range == .week ? 28 : 34
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .foregroundStyle(
                        selectedX == nil || selectedX == p.xIndex
                        ? Color.blue
                        : Color.blue.opacity(0.25)
                    )
                }
            }
            .chartLegend(.hidden)
            .chartYScale(domain: 0...100)
            .chartXScale(domain: xAxisDomain(for: range))
            .chartPlotStyle { plot in
                plot
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
            }
            .chartXAxis {
                AxisMarks(values: axisTickValues(for: range)) { v in
                    AxisGridLine().foregroundStyle(.clear)
                    AxisTick().foregroundStyle(.clear)
                    AxisValueLabel {
                        if let value = v.as(Int.self) {
                            Text(axisLabel(for: value, in: range))
                                .font(.caption)
                        }
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: [0, 50, 100]) { v in
                    AxisGridLine().foregroundStyle(.gray.opacity(0.15))
                    AxisTick().foregroundStyle(.clear)
                    AxisValueLabel {
                        if let value = v.as(Int.self) {
                            Text("\(value)%")
                                .font(.caption)
                        }
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .onTapGesture { location in
                            let plotFrame = geo[proxy.plotAreaFrame]
                            let xPosition = location.x - plotFrame.origin.x

                            if let tappedX: Int = proxy.value(atX: xPosition) {
                                let validValues = axisTickValues(for: range)
                                let nearest = validValues.min {
                                    abs($0 - tappedX) < abs($1 - tappedX)
                                }

                                if let nearest {
                                    selectedX = nearest
                                    showDetails = true
                                }
                            }
                        }
                }
            }
            .frame(height: 190)
            .sheet(isPresented: $showDetails) {
                if let selectedPoint {
                    ChartDetailsSheet(
                        point: selectedPoint,
                        range: range
                    )
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                }
            }
            .sheet(isPresented: $showHelp) {
                ScoreHelpSheet()
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

private struct ChartDetailsSheet: View {
    let point: BarPoint
    let range: ScoreRange

    var body: some View {
        NavigationStack {
            List {
                if point.details.isEmpty {
                    Text("No quizzes done here.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(point.details) { item in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                Text(item.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(String(format: "%.0f%%", item.percent))
                                .font(.headline)
                                .foregroundStyle(.blue)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("\(axisLabel(for: point.xIndex, in: range)) Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct ScoreHelpSheet: View {
    var body: some View {
        NavigationStack {
            List {
                Section("MCQ percentage") {
                    Text("Each MCQ quiz percentage is calculated using:")
                    Text("Correct answers ÷ Total questions × 100")
                        .fontWeight(.semibold)
                    Text("Example: 8 correct out of 10 questions = 80%.")
                }

                Section("Memory percentage") {
                    Text("Memory score is based on how many tries you used.")
                    Text("100 ÷ Number of tries")
                        .fontWeight(.semibold)
                    Text("Example: 1 try = 100%, 2 tries = 50%, 4 tries = 25%.")
                }

                Section("Chart bars") {
                    Text("Each bar shows the average percentage for that day or week.")
                    Text("Tap a bar to see the quizzes or memory attempts inside it.")
                }
            }
            .navigationTitle("How scores work")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
// MARK: - Small pieces

private struct ChartCard<Content: View>: View {
    let title: String
    @Binding var showHelp: Bool
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    showHelp = true
                } label: {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            content
        }
        .padding(18)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }
}
private struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title3)
                .bold()

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - X-axis helpers

private func xAxisDomain(for range: ScoreRange) -> ClosedRange<Int> {
    switch range {
    case .week:
        return 1...7

    case .month:
        return 1...5

    case .day:
        return 1...7
    }
}

private func axisTickValues(for range: ScoreRange) -> [Int] {
    switch range {
    case .week:
        return Array(1...7)

    case .month:
        return Array(1...5)

    case .day:
        return Array(1...7)
    }
}

private func axisLabel(for value: Int, in range: ScoreRange) -> String {
    switch range {
    case .week:
        let names = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        let i = max(1, min(value, 7)) - 1
        return names[i]

    case .month:
        return "W\(value)"

    case .day:
        return ""
    }
}
