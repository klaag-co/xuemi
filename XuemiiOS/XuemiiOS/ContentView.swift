//
//  ContentView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 16/4/24.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            TestView()
                .tabItem {
                    Label("Test", systemImage: "doc.questionmark")
                }
            NotesView()
                .tabItem {
                    Label("Notes", systemImage: "doc")
                }
            SettingsView()
                .tabItem{
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
#Preview {
    ContentView()
}
