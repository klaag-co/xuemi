//
//  iPadScoresView.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 17/6/26.
//

import SwiftUI
import Charts

struct iPadScoresView: View {

    @State private var levelSelection: ScoreData.Level = .all
    @State private var timeIntervalSelection: ScoreData.TimeInterval = .week

    var body: some View {
        VStack {
            iPadChartView(
                type: .mcq,
                levelSelection: $levelSelection,
                timeIntervalSelection: $timeIntervalSelection,
            )

            iPadChartView(
                type: .memory,
                levelSelection: $levelSelection,
                timeIntervalSelection: $timeIntervalSelection,
            )
        }
        .padding()
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
    }
}
