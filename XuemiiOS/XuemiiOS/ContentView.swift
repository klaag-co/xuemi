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
                    VStack {
                        Image(systemName: "house")
                        Text("Home")
                    }
                }
            FavouritesView()
                .tabItem {
                    VStack {
                        Image(systemName: "star")
                        Text("Favourites")
                    }
                }
            NotesView()
                .tabItem {
                    VStack {
                        Image(systemName: "doc")
                        Text("Notes")
                    }
                }
            SettingsView()
                .tabItem{
                    VStack{
                        Image(systemName: "gear")
                        Text("Settings")
                    }
        }
    }
}
}
#Preview {
    ContentView()
}
