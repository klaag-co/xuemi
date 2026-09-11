//
//  MemoryCard.swift
//  Xuemi
//
//  Created by Tristan Chay on 15/6/26.
//

import Foundation

struct MemoryCard: Identifiable {
    let id = UUID()
    let vocab: Vocabulary
    var isFaceUp: Bool = true
    var isMatched: Bool = false
}
