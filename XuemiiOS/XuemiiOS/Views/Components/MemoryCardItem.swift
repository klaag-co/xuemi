//
//  MemoryCardItem.swift
//  Xuemi
//
//  Created by Tristan Chay on 15/6/26.
//

import SwiftUI

struct MemoryCardItem: View {
    let index: Int
    let cards: [MemoryCard]
    let wrongCardIndex: Int?
    let wrongShakeTrigger: CGFloat
    
    var body: some View {
        let card = cards[index]

        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.customBlue)
                .overlay(
                    Text(card.vocab.word)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(8)
                )
                .opacity(card.isFaceUp ? 1 : 0)
                .rotation3DEffect(.degrees(card.isFaceUp ? 0 : -180), axis: (x: 0, y: 1, z: 0))
            
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.customBlue)
                .overlay(
                    Image(.xuemi)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64)
                        .mask {
                            Image(systemName: "app.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 64)
                        }
                )
                .opacity(card.isFaceUp ? 0 : 1)
                .rotation3DEffect(.degrees(card.isFaceUp ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        }
        .frame(height: 100)
        .modifier(wrongCardIndex == index ? ShakeEffect(shakes: wrongShakeTrigger) : ShakeEffect(shakes: 0))
        .animation(.default, value: card.isFaceUp)
        .animation(.default, value: wrongShakeTrigger)
    }
}
