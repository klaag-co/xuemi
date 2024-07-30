//
//  HomeView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 16/4/24.
//

import SwiftUI

//use observableobject to store the thing for secondary chapter topic

enum SecondaryNumber: Codable {
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

    var filename: String {
        switch self {
        case .one:
            return "中一"
        case .two:
            return "中二"
        case .three:
            return "中三"
        case .four:
            return "中四"
        }
    }
}

class PathManager: ObservableObject {
    @Published var path: NavigationPath = .init()
    
    static var global: PathManager = .init()
    
    private init() {}
    
    func popToRoot() {
        while !path.isEmpty {
            path.removeLast()
        }
    }
}

struct HomeView: View {
    @ObservedObject var pathManager: PathManager = .global

    var body: some View {
        NavigationStack(path: $pathManager.path) {
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
                        Text("O 水准备考")
                            .padding(.top, 40)
                        Text("")
                            .padding(.bottom, 30)
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
            .navigationDestination(for: SecondaryNumber.self) { level in
                ChapterView(level: level)
            }
            
            Spacer()
        }
    }

    func navigationTile(level: SecondaryNumber) -> some View {
        NavigationLink(value: level) {
            HStack {
                Text("中\(level.string)")
                    .minimumScaleFactor(0.1)
                    .font(.system(size: 55))
                    .bold()
            }
            .padding(30)
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
