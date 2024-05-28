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
            BookmarkView()
                .tabItem {
                    Label("Bookmarks", systemImage: "bookmark")
                }
            NotesView()
                .tabItem {
                    Label("Notes", systemImage: "doc.text")
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
