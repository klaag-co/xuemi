//
//  ContentView.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 13/6/26.
//

import SwiftUI

struct ContentView: View {
    
    @State private var authManager: AuthManager
    @State private var deviceTypeManager: DeviceTypeManager
    @State private var settingsManager: SettingsManager
    @State private var vocabManager: VocabularyManager
    @State private var scoresManager: ScoresManager
    @State private var foldersManager: FoldersManager
    @State private var progressManager: ProgressManager

    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    init() {
        let authManager = AuthManager()
        self.authManager = authManager

        self.deviceTypeManager = DeviceTypeManager()

        let settingsManager = SettingsManager(authManager: authManager)
        _settingsManager = State(initialValue: settingsManager)

        let vocabManager = VocabularyManager(settingsManager: settingsManager)
        _vocabManager = State(initialValue: vocabManager)

        _scoresManager = State(initialValue: ScoresManager(authManager: authManager, settingsManager: settingsManager))
        _foldersManager = State(initialValue: FoldersManager(authManager: authManager, vocabManager: vocabManager, settingsManager: settingsManager))
        _progressManager = State(initialValue: ProgressManager(authManager: authManager, settingsManager: settingsManager))
    }
    
    var body: some View {
        Group {
            if authManager.isLoggedIn == true, settingsManager.chineseLevel != nil {
                loggedIn
            } else if authManager.isLoggedIn == false {
                LoginView()
            } else {
                ProgressView()
                    .controlSize(.large)
            }
        }
        .environment(authManager)
        .environment(deviceTypeManager)
        .environment(settingsManager)
        .environment(vocabManager)
        .environment(scoresManager)
        .environment(foldersManager)
        .environment(progressManager)
        .onChange(of: horizontalSizeClass) {
            deviceTypeManager.updateHorizontalSizeClass(horizontalSizeClass)
        }
        .onChange(of: authManager.uid) {
            settingsManager.load()
        }
        .onChange(of: settingsManager.chineseLevel, initial: true) {
            guard settingsManager.chineseLevel != nil else { return }
            progressManager.load()
            scoresManager.load()
            foldersManager.load()
        }
    }
    
    var loggedIn: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                if deviceTypeManager.deviceType != .ipad(.regular) {
                    HomeView()
                } else {
                    iPadHomeView()
                }
            }
            Tab("Notes", systemImage: "note.text") {
                NotesView(authManager: authManager)
            }
            Tab("Folders", systemImage: "folder.fill") {
                FoldersView()
            }
            Tab("Settings", systemImage: "gearshape.fill") {
                SettingsView()
            }
            if deviceTypeManager.deviceType == .ipad(.regular) {
                TabSection("年级") {
                    Tab("中一", systemImage: "1.circle.fill") {
                        NavigationStack {
                            ChapterView(level: "中一")
                        }
                    }

                    Tab("中二", systemImage: "2.circle.fill") {
                        NavigationStack {
                            ChapterView(level: "中二")
                        }
                    }

                    Tab("中三", systemImage: "3.circle.fill") {
                        NavigationStack {
                            ChapterView(level: "中三")
                        }
                    }

                    Tab("中四", systemImage: "4.circle.fill") {
                        NavigationStack {
                            ChapterView(level: "中四")
                        }
                    }

                    Tab("SEC", systemImage: "s.circle.fill") {
                        MCQView(
                            parentName: "SEC",
                            vocabularies: vocabManager.allVocabularies,
                            numberOfQuestions: 20
                        )
                    }
                }
                .defaultVisibility(.hidden, for: .tabBar)
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}

#Preview {
    ContentView()
}
