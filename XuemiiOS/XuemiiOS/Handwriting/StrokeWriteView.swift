//
//  StrokeWriteView.swift
//  XuemiiOS
//
//  Created by Kmy Er on 27/7/24.
//

import SwiftUI

struct StrokeWriteView: View {
    var word: String
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(Array(word.enumerated()), id: \.offset) { (index, char) in
                    VStack {
                        CanvasView(character: String(char))
                            .frame(width: 315, height: 315)
                    }
                }
            }
            .padding(.vertical, 20)
        }
    }
}

#Preview {
    StrokeWriteView(word: "你好")
}
