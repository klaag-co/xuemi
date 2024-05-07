//
//  HomeView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 16/4/24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
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
            .background(.customblue)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 10)))
            .position(x: 175, y: 84)
            .padding(.vertical, -22).padding(.horizontal, 20)
            
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
                        .font(.system(size:55))
                }
            }
            .background(.customteal)
            .buttonStyle(.bordered)
            .font(.system(size: 40))
            .foregroundStyle(.white)
            .padding(2)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 10)))
            .position(x: 105, y: 112)
            
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
                        .font(.system(size:55))
                }
            }
            .buttonStyle(.bordered)
            .font(.system(size: 40))
            .foregroundStyle(.white)
            .background(.customteal)
            .padding(2)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 10)))
            .position(x: 286, y: 10)
            
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
                        .font(.system(size:55))
                }
            }
            .buttonStyle(.bordered)
            .font(.system(size: 40))
            .foregroundStyle(.white)
            .background(.customteal)
            .padding(2)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 10)))
            .position(x: 105, y: 57)
            
            Button() {
                print("eheh")
            } label: {
                VStack{
                    Text("Secondary")
                        .padding(EdgeInsets(top:10, leading: 2, bottom:0, trailing: 2))
                        .font(.system(size: 30))
                    Text("4")
                        .padding(EdgeInsets(top:0, leading: 0, bottom:15, trailing: 0))
                        .bold()
                        .font(.system(size:55))
                }
            }
            .buttonStyle(.bordered)
            .font(.system(size: 40))
            .foregroundStyle(.white)
            .background(.customteal)
            .padding(2)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 10)))
            .position(x: 286, y: -45)
            
            Button() {
                print("eheh")
            } label: {
                VStack{
                    Text("O-Level")
                        .padding(EdgeInsets(top:10, leading: 72, bottom:0, trailing: 72))
                        .bold()
                        .font(.system(size: 50))
                    Text("Practice")
                        .padding(EdgeInsets(top:0, leading: 72, bottom:12, trailing: 72))
                        .bold()
                        .font(.system(size:50))
                }
            }
            .buttonStyle(.bordered)
            .font(.system(size: 40))
            .foregroundStyle(.white)
            .background(.customteal)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 10)))
            .position(x: 287, y: 30)
            .padding(.vertical, -22).padding(.horizontal, -90)
        }
    }
}

#Preview {
    HomeView()
}
