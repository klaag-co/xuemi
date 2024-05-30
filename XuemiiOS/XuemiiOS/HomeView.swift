//
//  HomeView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 16/4/24.
//

import SwiftUI

enum SecondaryNumber {
    case one, two, three, four
    
    var string: String {
        switch self {
        case .one:
            return "1"
        case .two:
            return "2"
        case .three:
            return "3"
        case .four:
            return "4"
        }
    }
    
    func getData(chapter: Chapter, topic: Topic) -> [String] {
        switch self {
        case .one:
            switch chapter {
            case .one:
                switch topic {
                case .one:
                    return ["word 1", "word 2"]
                case .two:
                    return ["something 1", "something 2"]
                case .three:
                    return []
                }
            case .two:
                switch topic {
                case .one:
                    return []
                case .two:
                    return []
                case .three:
                    return []
                }
            case .three:
                switch topic {
                case .one:
                    return []
                case .two:
                    return []
                case .three:
                    return []
                }
            case .four:
                switch topic {
                case .one:
                    return []
                case .two:
                    return []
                case .three:
                    return []
                }
            case .five:
                switch topic {
                case .one:
                    return []
                case .two:
                    return []
                case .three:
                    return []
                }
            case .six:
                switch topic {
                case .one:
                    return []
                case .two:
                    return []
                case .three:
                    return []
                }
            case .eoy:
                return []
            }
        case .two:
            switch chapter {
            case .one:
                switch topic {
                case .one:
                    return ["word 1", "word 2"]
                case .two:
                    return ["something 1", "something 2"]
                case .three:
                    return []
                }
            case .two:
                switch topic {
                case .one:
                    return []
                case .two:
                    return []
                case .three:
                    return []
                }
            case .three:
                switch topic {
                case .one:
                    return []
                case .two:
                    return []
                case .three:
                    return []
                }
            case .four:
                switch topic {
                case .one:
                    return []
                case .two:
                    return []
                case .three:
                    return []
                }
            case .five:
                switch topic {
                case .one:
                    return []
                case .two:
                    return []
                case .three:
                    return []
                }
            case .six:
                switch topic {
                case .one:
                    return []
                case .two:
                    return []
                case .three:
                    return []
                }
            case .eoy:
                return []
            }
        case .three:
            switch chapter {
            case .one:
                switch topic {
                case .one:
                    return ["word 1", "word 2"]
                case .two:
                    return ["something 1", "something 2"]
                case .three:
                    return []
                }
            case .two:
                switch topic {
                case .one:
                    return []
                case .two:
                    return []
                case .three:
                    return []
                }
            case .three:
                switch topic {
                case .one:
                    return []
                case .two:
                    return []
                case .three:
                    return []
                }
            case .four:
                switch topic {
                case .one:
                    return []
                case .two:
                    return []
                case .three:
                    return []
                }
            case .five:
                switch topic {
                case .one:
                    return []
                case .two:
                    return []
                case .three:
                    return []
                }
            case .six:
                switch topic {
                case .one:
                    return []
                case .two:
                    return []
                case .three:
                    return []
                }
            case .eoy:
                return []
            }
        case .four:
            switch chapter {
            case .one:
                switch topic {
                case .one:
                    return ["word 1", "word 2"]
                case .two:
                    return ["something 1", "something 2"]
                case .three:
                    return []
                }
            case .two:
                switch topic {
                case .one:
                    return []
                case .two:
                    return []
                case .three:
                    return []
                }
            case .three:
                switch topic {
                case .one:
                    return []
                case .two:
                    return []
                case .three:
                    return []
                }
            case .four:
                switch topic {
                case .one:
                    return []
                case .two:
                    return []
                case .three:
                    return []
                }
            case .five:
                switch topic {
                case .one:
                    return []
                case .two:
                    return []
                case .three:
                    return []
                }
            case .six:
                switch topic {
                case .one:
                    return []
                case .two:
                    return []
                case .three:
                    return []
                }
            case .eoy:
                return []
            }
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
        }
    }

    func navigationTile(level: SecondaryNumber) -> some View {
        NavigationLink {
            ChapterView(level: level)
        } label: {
            VStack {
                Text("Secondary")
                    .font(.system(size: 30))
                Text(level.string)
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
