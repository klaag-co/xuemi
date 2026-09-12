//
//  ScoresView.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 17/6/26.
//

import SwiftUI
import Charts

struct ScoresView: View {

    @State private var levelSelection: ScoreData.Level = .all
    @State private var typeSelection: ScoreData.ScoreType = .mcq
    @State private var timeIntervalSelection: ScoreData.TimeInterval = .week

    @State private var selectedBucket: ChartBucketSelection?
    @State private var selectedScoreData: ScoreData?

    @Environment(ScoresManager.self) private var scoresManager

    private var chartData: [ScoreChartData] {
        scoresManager.chartData(
            type: typeSelection,
            level: levelSelection,
            interval: timeIntervalSelection
        )
    }

    private var summary: ScoreSummary {
        scoresManager.summary(
            type: typeSelection,
            level: levelSelection,
            interval: timeIntervalSelection
        )
    }

    private var chartYMax: Double {
        switch typeSelection {
        case .mcq:
            return 100
        case .memory:
            let peak = chartData.map(\.value).max() ?? 0
            return max(10, ceil(peak / 5) * 5)
        }
    }

    var body: some View {
        main
            .navigationTitle("Scores")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Secondary Level", selection: Binding(get: {
                            levelSelection
                        }, set: { value in
                            withAnimation {
                                levelSelection = value
                            }
                        })) {
                            ForEach(ScoreData.Level.allCases, id: \.hashValue) { level in
                                Text(level.rawValue)
                                    .tag(level)
                            }
                        }
                        
                        Divider()
                        
                        Picker("Score Type", selection: Binding(get: {
                            typeSelection
                        }, set: { value in
                            withAnimation {
                                typeSelection = value
                            }
                        })) {
                            ForEach(ScoreData.ScoreType.allCases, id: \.hashValue) { type in
                                Text(type.rawValue)
                                    .tag(type)
                            }
                        }
                        
                        Divider()
                        
                        Picker("Time Interval", selection: Binding(get: {
                            timeIntervalSelection
                        }, set: { value in
                            withAnimation {
                                timeIntervalSelection = value
                            }
                        })) {
                            ForEach(ScoreData.TimeInterval.allCases, id: \.hashValue) { interval in
                                Text(interval.rawValue)
                                    .tag(interval)
                            }
                        }
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease")
                    }
                }
            }
            .onChange(of: levelSelection) { _, _ in
                withAnimation {
                    selectedBucket = nil
                }
            }
            .onChange(of: typeSelection) { _, _ in
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

    var main: some View {
        ScrollView {
            VStack {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(typeSelection.rawValue)
                                .font(.headline)
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
                                y: .value("Score", data.chartDisplayValue(for: typeSelection))
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
                    .sheet(item: Binding(get: {
                        selectedBucket
                    }, set: { value in
                        withAnimation {
                            selectedBucket = value
                        }
                    })) { bucket in
                        ChartDetailsView(
                            label: bucket.label,
                            type: typeSelection,
                            level: levelSelection,
                            interval: timeIntervalSelection,
                            selectedScoreData: $selectedScoreData
                        )
                        .presentationDetents([.medium, .large])
                        .presentationContentInteraction(.resizes)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .mask(RoundedRectangle(cornerRadius: 24))

                HStack {
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
            }
            .padding()
        }
        .refreshable {
            scoresManager.load()
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
    }

    private var countLabel: String {
        switch typeSelection {
        case .mcq: "Quizzes"
        case .memory: "Memory Cards"
        }
    }

    private func formattedAverage(_ value: Double) -> String {
        switch typeSelection {
        case .mcq:
            return "\(Int(value.rounded()))%"
        case .memory:
            return formattedTries(value)
        }
    }

    private func formattedBest(_ value: Double?) -> String {
        guard let value else { return "—" }
        switch typeSelection {
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
        switch typeSelection {
        case .mcq:
            return "\(Int(value))%"
        case .memory:
            return "\(Int(value))"
        }
    }
}
