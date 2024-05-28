//
//  HomeView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 16/4/24.
//

import SwiftUI

struct HomeView: View {
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : UIFont(name: "HelveticaNeue-Bold", size: 50)!]
            
    }
    var body: some View {
        NavigationStack {
            VStack {
                Button {
                    print("whoa u clicked me")
                } label: {
                    Image("ContinueLearning")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                }
                .foregroundStyle(.white)
                .background(.customblue)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                
                HStack {
                    tile(level: "1")
                    tile(level: "2")
                }
                
                HStack {
                    tile(level: "3")
                    tile(level: "4")
                }
                
                
                Button {
                    print("eheh")
                } label: {
                    VStack{
                        Text("O-Level")
                            .padding(.top, 10)
                        Text("Practice")
                            .padding(.bottom, 10)
                    }
                    .bold()
                    .font(.system(size:50))
                }
                .font(.system(size: 40))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .background(.customteal)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(20)
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    func tile(level: String) -> some View {
        Button {
            print("are u s\(level)")
        } label: {
            VStack {
                Text("Secondary")
                    .font(.system(size: 30))
                Text(level)
                    .font(.system(size: 55))
            }
            .padding()
            .background(.customteal)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView()
}
