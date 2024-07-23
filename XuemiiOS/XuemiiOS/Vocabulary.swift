//
//  Vocabulary.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 1/7/24.
//

import Foundation

struct Vocabulary: Codable, Equatable, Hashable {
    var index: Int
    var word: String
    var pinyin: String
    var englishDefinition: String
    var chineseDefinition: String
    var example: String
    var q1: String
    var q2: String
    
    enum CodingKeys: CodingKey {
        case index
        case word
        case pinyin
        case englishDefinition
        case chineseDefinition
        case example
        case q1
        case q2
    }
}

func loadVocabulariesFromJSON(fileName: String, chapter: String, topic: String) -> [Vocabulary] {
    guard let fileUrl = Bundle.main.url(forResource: fileName, withExtension: "json") else {
        print("JSON file not found")
        return []
    }
    
    do {
        let jsonData = try Data(contentsOf: fileUrl)
        let vocabularies = try JSONDecoder().decode([String: [String : [Vocabulary]]].self, from: jsonData)
        return vocabularies[chapter]?[topic] ?? []
    } catch {
        print("Error decoding JSON: \(error)")
        return []
    }
}
