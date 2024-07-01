//
//  HomeView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 16/4/24.
//

import SwiftUI

//use observableobject to store the thing for secondary chapter topic

enum SecondaryNumber {
    case one, two, three, four
    
    var string: String {
        switch self {
        case .one:
            return "一"
        case .two:
            return "二"
        case .three:
            return "三"
        case .four:
            return "四"
        }
    }
}

struct HomeView: View {

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
                    navigationTile(level: .one)
                    navigationTile(level: .two)
                }

                HStack {
                    navigationTile(level: .three)
                    navigationTile(level: .four)
                }

                Button {
                    print("eheh")
                } label: {
                    VStack {
                        Text("O-Level")
                            .padding(.top, 10)
                        Text("Practice")
                            .padding(.bottom, 10)
                    }
                    .bold()
                    .font(.system(size: 50))
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
            
           Spacer()
        }
    }

    func navigationTile(level: SecondaryNumber) -> some View {
        NavigationLink {
            ChapterView(level: level)
        } label: {
            HStack {
                Text("中")
                    .font(.system(size: 55))
                    .bold()
                Text(level.string)
                    .font(.system(size: 55))
                    .bold()
            }
            .padding()
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
