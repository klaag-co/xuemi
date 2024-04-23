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
                Text("Secondary")
                    .padding(EdgeInsets(top:15, leading: 0, bottom:0, trailing: 0))
                Text("1")
                    .padding(EdgeInsets(top:0, leading: 0, bottom:15, trailing: 0))
                    .font(.system(size:55))
                    
            }
        }
        .buttonStyle(.bordered)
        .font(.system(size: 40))
        .foregroundStyle(.white)
        .background(.blue)
        .padding(2)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 10)))
        .position(x: 150, y: -40)
    }
}

#Preview {
    HomeView()
}
