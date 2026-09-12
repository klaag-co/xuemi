//
//  iPadHomeView.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 13/6/26.
//

import SwiftUI

struct iPadHomeView: View {
    
    @Environment(VocabularyManager.self) private var vocabManager
    @Environment(ScoresManager.self) private var scoresManager
    @Environment(ProgressManager.self) private var progressManager
    @Environment(SettingsManager.self) private var settingsManager

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
                VStack(spacing: 24) {
                    CarouselView(width: geometry.size.width * 0.92, height: geometry.size.height * 0.26)
                    iPadScoresView()
                }
            }
        }
        .refreshable {
            scoresManager.load()
            progressManager.load()
        }
    }
}


#Preview {
    iPadHomeView()
}
