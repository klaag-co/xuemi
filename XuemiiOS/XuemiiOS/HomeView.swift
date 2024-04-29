//
//  HomeView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 16/4/24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        Text("Home")
            .font(.system(size: 55, weight: .bold))
            .position(x: 100, y: 50)
        Button() {
            print("eheh")
        } label: {
            VStack{
                Image("ContinueLearning")
                    .resizable()
            }
        }
        .buttonStyle(.bordered)
        .foregroundStyle(.white)
        .background(.blue)
        .padding(2)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 10)))
        .position(x: 195, y: 110)
        
        Button() {
            print("eheh")
        } label: {
            VStack{
                Text("Secondary")
                    .padding(EdgeInsets(top:10, leading: 2, bottom:0, trailing: 2))
                    .font(.system(size: 30))
                Text("1")
                    .padding(EdgeInsets(top:0, leading: 0, bottom:15, trailing: 0))
                    .bold()
                    .font(.system(size:65))
            }
        }
        .buttonStyle(.bordered)
        .font(.system(size: 40))
        .foregroundStyle(.white)
        .background(.blue)
        .padding(2)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 10)))
        .position(x: 105, y: 120)
        
        Button() {
            print("eheh")
        } label: {
            VStack{
                Text("Secondary")
                    .padding(EdgeInsets(top:10, leading: 2, bottom:0, trailing: 2))
                    .font(.system(size: 30))
                Text("2")
                    .padding(EdgeInsets(top:0, leading: 0, bottom:15, trailing: 0))
                    .bold()
                    .font(.system(size:65))
            }
        }
        .buttonStyle(.bordered)
        .font(.system(size: 40))
        .foregroundStyle(.white)
        .background(.blue)
        .padding(2)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 10)))
        .position(x: 286, y: -73)
        
        Button() {
            print("eheh")
        } label: {
            VStack{
                Text("Secondary")
                    .padding(EdgeInsets(top:10, leading: 2, bottom:0, trailing: 2))
                    .font(.system(size: 30))
                Text("3")
                    .padding(EdgeInsets(top:0, leading: 0, bottom:15, trailing: 0))
                    .bold()
                    .font(.system(size:65))
            }
        }
        .buttonStyle(.bordered)
        .font(.system(size: 40))
        .foregroundStyle(.white)
        .background(.blue)
        .padding(2)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 10)))
        .position(x: 105, y: -100)
    }
}

#Preview {
    HomeView()
}
