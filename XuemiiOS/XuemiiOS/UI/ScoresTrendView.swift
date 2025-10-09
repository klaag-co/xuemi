import SwiftUI
import Charts

struct ScoresTrendView: View {
    @EnvironmentObject private var scores: ScoreManager
    @State private var range: ScoreManager.TrendRange = .daily

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Picker("", selection: $range) {
                    Text("Day").tag(ScoreManager.TrendRange.daily)
                    Text("Week").tag(ScoreManager.TrendRange.weekly)
                    Text("Month").tag(ScoreManager.TrendRange.monthly)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                let buckets = scores.buckets(range: range)

                HStack(spacing: 12) {
                    SummaryCard(title: "Score",
                                value: "\(buckets.reduce(0) { $0 + $1.score })",
                                sub: "of \(buckets.reduce(0) { $0 + $1.outOf })")
                    SummaryCard(title: "Avg",
                                value: String(format: "%.0f%%", avgPercent(buckets)),
                                sub: label(for: range))
                }
                .padding(.horizontal)

                Chart(buckets) { b in
                    BarMark(
                        x: .value("Period", b.label),
                        y: .value("Percent", b.percent)
                    )
                    .annotation(position: .top) {
                        if b.outOf > 0 { Text("\(Int(round(b.percent)))%").font(.caption2) }
                    }
                }
                .chartYScale(domain: 0...100)
                .frame(height: 260)
                .padding(.horizontal)

                Spacer(minLength: 12)
            }
            .navigationTitle("Trends")
        }
    }

    private func avgPercent(_ buckets: [ScoreManager.ScoreBucket]) -> Double {
        let s = buckets.reduce(0) { $0 + $1.score }
        let o = buckets.reduce(0) { $0 + $1.outOf }
        return o > 0 ? Double(s) / Double(o) * 100.0 : 0
    }

    private func label(for range: ScoreManager.TrendRange) -> String {
        switch range {
        case .daily:   return "Last 14 days"
        case .weekly:  return "Last 12 wks"
        case .monthly: return "Last 12 mos"
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let sub: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundColor(.secondary)
            Text(value).font(.title2).fontWeight(.semibold)
            Text(sub).font(.caption2).foregroundColor(.secondary)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

