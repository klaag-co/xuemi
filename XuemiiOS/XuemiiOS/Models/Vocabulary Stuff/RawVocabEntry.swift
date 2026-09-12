//
//  RawVocabEntry.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 14/6/26.
//

import Foundation

struct RawVocabEntry: Decodable {
    let index: Int
    let word: String
    let pinyin: String
    let englishDefinition: String
    let chineseDefinition: String
    let example: String
    let questions: [String]
}
