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
            FavouritesView()
                .tabItem {
                    Label("Favourites", systemImage: "star")
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
