//
//  SOneChapterView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 28/5/24.
//

import SwiftUI

enum Chapter: CaseIterable {
    case one, two, three, four, five, six, eoy
    
    var string: String {
        switch self {
        case .one:
            return "Chapter 1"
        case .two:
            return "Chapter 2"
        case .three:
            return "Chapter 3"
        case .four:
            return "Chapter 4"
        case .five:
            return "Chapter 5"
        case .six:
            return "Chapter 6"
        case .eoy:
            return "EOY Practice"
        }
    }
}

struct ChapterView: View {
    
    var level: SecondaryNumber
    
    var body: some View {
        ScrollView {
            Text("Secondary \(level.string)")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .padding()
                .frame(height: 80)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
                .background(.customblue)
                .mask(RoundedRectangle(cornerRadius: 16))
                .padding([.horizontal, .bottom])
            VStack(spacing: 12) {
                ForEach(level == .four ? Chapter.allCases.filter({ $0 != .six }) : Chapter.allCases, id: \.hashValue) { chapter in
                    NavigationLink {
                        if chapter != .eoy {
                            TopicView(level: level, chapter: chapter)
                        } else {
                            
                        }
                    } label: {
                        Text(chapter.string)
                            .font(.title)
                            .padding()
                            .frame(height: 65)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.black)
                            .background(.customgray)
                            .mask(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .padding(.vertical)
    }
}

#Preview {
    ChapterView(level: .three)
}
