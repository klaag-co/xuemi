//
//  StrokeWriteView.swift
//  XuemiiOS
//
//  Created by Kmy Er on 27/7/24.
//

import SwiftUI

struct StrokeWriteView: View {
    var word: String

    init(word: String) {
        self.word = word
    }

    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(Array(word.enumerated()), id: \.offset) { (index, char) in
                        VStack {
                            Spacer()
                            
                            HStack {
                                Spacer()
                                CanvasView(character: String(char))
                                    .frame(width: 315, height: 315)
                                Spacer()
                            }
                            
                            Spacer()

                            Text("Swipe left/right here to go to the next/previous word")
                                .font(.caption)
                                .foregroundStyle(.gray)
                                .containerRelativeFrame(.horizontal, count: 3, span: 2, spacing: 0)
                                .multilineTextAlignment(.center)
                            
                            Spacer()
                        }
                        .containerRelativeFrame(.horizontal)
                        .id(index)
                    }
                }
                .scrollTargetLayout()
                .padding(.vertical, 20)
            }
            .scrollTargetBehavior(.viewAligned)
        }
    }
}

#Preview {
    StrokeWriteView(word: "你好")
}
