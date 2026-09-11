//
//  ChartDetailsView.swift
//  Xuemi
//
//  Created by Tristan Chay on 19/6/26.
//

import SwiftUI

struct ChartDetailsView: View {
    let label: String
    let type: ScoreData.ScoreType
    let level: ScoreData.Level
    let interval: ScoreData.TimeInterval
    
    @Binding var selectedScoreData: ScoreData?

    @Environment(\.dismiss) private var dismiss
    @Environment(ScoresManager.self) private var scoresManager

    private var scores: [ScoreData] {
        scoresManager.scores(
            for: label,
            type: type,
            level: level,
            interval: interval
        )
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if #available(iOS 26.0, *) {
                    sheetContent
                        .navigationSubtitle(type.rawValue)
                } else {
                    sheetContent
                }
            }
            .navigationTitle(interval.periodTitle(for: label))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Dismiss", systemImage: "xmark")
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var sheetContent: some View {
        if scores.isEmpty {
            ContentUnavailableView(
                "No Attempts",
                systemImage: "chart.bar.fill",
                description: Text("No \(type.rawValue) attempts recorded for this period.")
            )
        } else {
            List(scores) { score in
                if score.hasResultDetails {
                    Button {
                        dismiss()
                        selectedScoreData = score
                    } label: {
                        scoreRow(for: score)
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                } else {
                    scoreRow(for: score)
                }
            }
        }
    }

    private func scoreRow(for score: ScoreData) -> some View {
        HStack {
            Image(systemName: type == .mcq ? "checklist" : "rectangle.portrait.on.rectangle.portrait.angled.fill")
                .font(.title3)
                .frame(width: 28)

            VStack(alignment: .leading) {
                Text(score.parentName)
                    .font(.headline)

                Text(score.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            Text(scoresManager.formattedValue(for: score))
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.accent)

            if score.hasResultDetails {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
                    .font(.caption.weight(.bold))
            }
        }
    }
}
