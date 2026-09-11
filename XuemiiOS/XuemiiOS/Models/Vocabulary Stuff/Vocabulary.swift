//
//  Vocabulary.swift
//  Xuemi
//
//  Created by Tristan Chay on 14/6/26.
//

import Foundation

struct Vocabulary: Codable, Equatable, Hashable, Identifiable {
    var id: String {
        return "\(level)/\(chapterName)/\(topicName)/\(index)"
    }

    var level: String
    var chapterName: String
    var topicName: String

    var index: Int
    var word: String
    var pinyin: String
    var englishDefinition: String
    var chineseDefinition: String
    var example: String
    var questions: [String]

    var chineseLevel: ChineseLevel

    enum ChineseLevel: String, Codable, CaseIterable {
        case express, higher

        var name: String {
            switch self {
            case .express: "Express"
            case .higher: "Higher Chinese (Beta)"
            }
        }

        static func from(level: String) -> ChineseLevel {
            level.contains("HCL") ? .higher : .express
        }
    }

    enum CodingKeys: CodingKey {
        case level
        case chapterName
        case topicName
        case index
        case word
        case pinyin
        case englishDefinition
        case chineseDefinition
        case example
        case questions
        case chineseLevel
    }
}
