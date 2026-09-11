//
//  iPadChartView.swift
//  Xuemi
//
//  Created by Tristan Chay on 17/8/26.
//

import SwiftUI
import Charts

struct iPadChartView: View {

    var type: ScoreData.ScoreType

    @Binding var levelSelection: ScoreData.Level
    @Binding var timeIntervalSelection: ScoreData.TimeInterval

    @State private var selectedBucket: ChartBucketSelection?
    @State private var selectedScoreData: ScoreData?

    @Environment(ScoresManager.self) private var scoresManager

    private var chartData: [ScoreChartData] {
        scoresManager.chartData(
            type: type,
            level: levelSelection,
            interval: timeIntervalSelection
        )
    }

    private var summary: ScoreSummary {
        scoresManager.summary(
            type: type,
            level: levelSelection,
            interval: timeIntervalSelection
        )
    }

    private var countLabel: String {
        switch type {
        case .mcq: "Quizzes"
        case .memory: "Memory Cards"
        }
    }

    private var chartYMax: Double {
        switch type {
        case .mcq: return 100
        case .memory:
            let peak = chartData.map(\.value).max() ?? 0
            return max(10, ceil(peak / 5) * 5)
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(type.rawValue)
                            .font(.headline)
                            .fontWeight(.bold)
                        Text("\(levelSelection.rawValue) • This \(timeIntervalSelection.rawValue)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }

                Chart {
                    ForEach(chartData) { data in
                        BarMark(
                            x: .value("Period", data.label),
                            y: .value("Score", data.chartDisplayValue(for: type))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .foregroundStyle(
                            selectedBucket == nil || selectedBucket?.label == data.label
                            ? Color.accent
                            : Color.accent.opacity(0.25)
                        )
                    }
                }
                .chartLegend(.hidden)
                .chartXScale(domain: timeIntervalSelection.range)
                .chartYScale(domain: 0...chartYMax)
                .chartPlotStyle { plot in
                    plot
                        .frame(maxWidth: .infinity)
                }
                .chartXAxis {
                    AxisMarks(values: timeIntervalSelection.range) { value in
                        AxisGridLine().foregroundStyle(.clear)
                        AxisTick().foregroundStyle(.clear)
                        AxisValueLabel {
                            if let label = value.as(String.self) {
                                Text(label)
                                    .font(.caption)
                            }
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine().foregroundStyle(.gray.opacity(0.15))
                        AxisTick().foregroundStyle(.clear)
                        AxisValueLabel {
                            if let amount = value.as(Double.self) {
                                Text(yAxisLabel(for: amount))
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
                                if let cgRect = proxy.plotFrame {
                                    let plotFrame = geo[cgRect]
                                    let xPosition = location.x - plotFrame.origin.x

                                    if let tappedLabel: String = proxy.value(atX: xPosition) {
                                        withAnimation {
                                            selectedBucket = ChartBucketSelection(label: tappedLabel)
                                        }
                                    }
                                }
                            }
                    }
                }
                .frame(height: 210)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .mask(RoundedRectangle(cornerRadius: 24))

            VStack {
                ScoreStatCard(
                    value: "\(summary.totalCount)",
                    label: countLabel
                )
                ScoreStatCard(
                    value: formattedAverage(summary.overallAverage),
                    label: "Overall Avg"
                )
                ScoreStatCard(
                    value: formattedBest(summary.bestScore),
                    label: "Best"
                )
            }
            .frame(maxWidth: 120)
        }
        .sheet(item: Binding(get: {
            selectedBucket
        }, set: { value in
            withAnimation {
                selectedBucket = value
            }
        })) { bucket in
            ChartDetailsView(
                label: bucket.label,
                type: type,
                level: levelSelection,
                interval: timeIntervalSelection,
                selectedScoreData: $selectedScoreData
            )
        }
        .navigationDestination(item: $selectedScoreData) { score in
            switch score.type {
            case .mcq:
                MCQResultsView(
                    parentName: score.parentName,
                    answers: score.mcqAnswers ?? []
                )
            case .memory:
                MemoryCardsResultsView(
                    parentName: score.parentName,
                    tries: Int(score.value.rounded()),
                    cards: (score.memoryCards ?? []).map { MemoryCard(vocab: $0) }
                )
            }
        }
        .onChange(of: levelSelection) { _, _ in
            withAnimation {
                selectedBucket = nil
            }
        }
        .onChange(of: timeIntervalSelection) { _, _ in
            withAnimation {
                selectedBucket = nil
            }
        }
    }

    private func formattedAverage(_ value: Double) -> String {
        switch type {
        case .mcq:
            return "\(Int(value.rounded()))%"
        case .memory:
            return formattedTries(value)
        }
    }

    private func formattedBest(_ value: Double?) -> String {
        guard let value else { return "—" }
        switch type {
        case .mcq:
            return "\(Int(value.rounded()))%"
        case .memory:
            return formattedTries(value)
        }
    }

    private func formattedTries(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(value))"
        }
        return String(format: "%.1f", value)
    }

    private func yAxisLabel(for value: Double) -> String {
        switch type {
        case .mcq:
            return "\(Int(value))%"
        case .memory:
            return "\(Int(value))"
        }
    }
}
