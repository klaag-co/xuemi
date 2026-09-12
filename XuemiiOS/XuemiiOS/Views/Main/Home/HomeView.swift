//
//  HomeView.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 13/6/26.
//

import SwiftUI

struct HomeView: View {
    
    @Environment(VocabularyManager.self) private var vocabManager
    @Environment(ScoresManager.self) private var scoresManager
    @Environment(ProgressManager.self) private var progressManager
    @Environment(SettingsManager.self) private var settingsManager

    private var mcqTodayCount: Int {
        scoresManager.mcqCountToday()
    }
    
    private var mcqOverallAverage: Int {
        Int(scoresManager.mcqOverallAverage().rounded())
    }
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    var body: some View {
        NavigationStack {
            if #available(iOS 26.0, *) {
                main
                    .navigationTitle("Home")
                    .navigationSubtitle(settingsManager.chineseLevel?.name ?? "")
            } else {
                main
                    .navigationTitle("Home")
            }
        }
    }

    var main: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 16) {
                    CarouselView(width: geometry.size.width * 0.92, height: geometry.size.height * 0.26)

                    LazyVGrid(columns: columns) {
                        ForEach(vocabManager.levels, id: \.self) { level in
                            navigationTile(level: level)
                        }
                    }
                    .padding(.horizontal)

                    NavigationLink {
                        MCQView(
                            parentName: "SEC",
                            vocabularies: vocabManager.allVocabularies.filter({ $0.chineseLevel == settingsManager.chineseLevel }),
                            numberOfQuestions: 20
                        )
                    } label: {
                        VStack(alignment: .leading) {
                            Text("SEC")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            Text("专为SEC的强化练习")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .padding(24)
                        .frame(height: geometry.size.height * 0.22)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            LinearGradient(
                                colors: [Color.customTeal, Color.customBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .mask(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
                        .padding([.horizontal, .bottom])
                    }
                }
                .frame(maxHeight: .infinity, alignment: .center)
                .padding(.vertical)
            }
            .toolbar {
                if #unavailable(iOS 26.0) {
                    ToolbarItem(placement: .topBarLeading) {
                        Text(settingsManager.chineseLevel?.name ?? "")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        ScoresView()
                    } label: {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .font(.subheadline)
                            Text("\(mcqTodayCount)")
                                .font(.subheadline.weight(.semibold))
                            Text("• \(mcqOverallAverage)%")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .contentTransition(.numericText())
                        .padding(.horizontal)
                        .padding(.vertical)
                    }
                }
            }
            .refreshable {
                scoresManager.load()
                progressManager.load()
            }
        }
    }

    private func navigationTile(level: String) -> some View {
        NavigationLink(destination: ChapterView(level: level)) {
            VStack(alignment: .center, spacing: 10) {
                Text(level)
                    .font(.system(size: 45, weight: .bold))
            }
            .padding(24)
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
            .background(
                LinearGradient(
                    colors: [
                        Color.customTeal,
                        Color.customBlue
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundStyle(.white)
            .mask(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    HomeView()
}
