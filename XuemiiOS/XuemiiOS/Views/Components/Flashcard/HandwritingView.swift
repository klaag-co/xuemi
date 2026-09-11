//
//  HandwritingView.swift
//  Xuemi
//
//  Created by Tristan Chay on 15/6/26.
//

import SwiftUI

struct HandwritingView: View {
    var word: String
    @Environment(\.dismiss) var dismiss
    
    init(word: String) {
        self.word = word
    }
    
    var body: some View {
        NavigationStack {
            TabView {
                ForEach(Array(word.enumerated()), id: \.offset) { (_, char) in
                    CanvasView(character: String(char))
                        .frame(width: 300, height: 300)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: Array(word).count > 1 ? .always : .never))
            .indexViewStyle(.page(backgroundDisplayMode: Array(word).count > 1 ? .always : .never))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

#Preview {
    HandwritingView(word: "你好")
}
