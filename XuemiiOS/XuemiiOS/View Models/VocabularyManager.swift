//
//  VocabularyManager.swift
//  Xuemi
//
//  Created by Tristan Chay on 14/6/26.
//

import Foundation

@Observable
final class VocabularyManager {

    private let settingsManager: SettingsManager

    private let fileNames = ["中一", "中一HCL", "中二", "中二HCL", "中三", "中三HCL", "中四", "中四HCL"]
    private var vocabularies: [Vocabulary] = []

    var allVocabularies: [Vocabulary] { vocabularies }
    var levels: [String] {
        OrderedSet(vocabularies.map(\.level)).elements
    }
    
    init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
        do {
            try load()
        } catch {
            assertionFailure("VocabularyManager failed to load: \(error.localizedDescription)")
        }
    }
    
    func chapters(for secondary: String) -> [String] {
        OrderedSet(
            vocabularies
                .filter { $0.level == secondary && $0.chineseLevel == settingsManager.chineseLevel }
                .map(\.chapterName)
        ).elements
    }
    
    func topics(for secondary: String, chapter: String) -> [String] {
        OrderedSet(
            vocabularies
                .filter {
                    $0.level == secondary && $0.chapterName == chapter && $0.chineseLevel == settingsManager.chineseLevel
                }
                .map(\.topicName)
        ).elements
    }
    
    func vocabularies(for secondary: String, chapter: String, topic: String) -> [Vocabulary] {
        vocabularies.filter {
            $0.level == secondary &&
            $0.chapterName == chapter &&
            $0.topicName == topic &&
            $0.chineseLevel == settingsManager.chineseLevel
        }
    }
    
    func vocabularies(for secondary: String) -> [Vocabulary] {
        vocabularies.filter {
            $0.level == secondary && $0.chineseLevel == settingsManager.chineseLevel
        }
    }
    
    func mapVocabIdsToVocabs(for ids: [String]) -> [Vocabulary] {
        ids.compactMap { id in
            allVocabularies.first(where: {
                $0.id == id && $0.chineseLevel == settingsManager.chineseLevel
            })
        }
    }

    func load() throws {
        var result: [Vocabulary] = []

        for name in fileNames {
            guard let url = Bundle.main.url(forResource: name, withExtension: "json") else {
                throw VocabularyError.fileNotFound(name)
            }
            let entries = try parseFile(at: url, level: name)
            result.append(contentsOf: entries)
        }

        vocabularies = result
    }

    private func loadFromBundle() throws -> [Vocabulary] {
        var result: [Vocabulary] = []
        for name in fileNames {
            guard let url = Bundle.main.url(forResource: name, withExtension: "json") else {
                throw VocabularyError.fileNotFound(name)
            }
            try result.append(contentsOf: parseFile(at: url, level: name))
        }
        return result
    }

    private func parseFile(at url: URL, level: String) throws -> [Vocabulary] {
        let data = try Data(contentsOf: url)

        // Decode as a two-level dictionary: chapterName → topicName → [RawEntry]
        let chaptersDict: [String: [String: [RawVocabEntry]]]
        do {
            chaptersDict = try JSONDecoder().decode([String: [String: [RawVocabEntry]]].self, from: data)
        } catch {
            throw VocabularyError.decodingFailed(url.lastPathComponent, underlying: error)
        }

        var result: [Vocabulary] = []
        let chapterOrder = try JSONObjectKeyParser.orderedKeys(in: data)

        for chapterName in chapterOrder {
            guard let topics = chaptersDict[chapterName] else { continue }
            guard let chapterData = try JSONObjectKeyParser.objectValue(forKey: chapterName, in: data) else {
                continue
            }
            let topicOrder = try JSONObjectKeyParser.orderedKeys(in: chapterData)

            for topicName in topicOrder {
                guard let rawEntries = topics[topicName] else { continue }
                for raw in rawEntries.sorted(by: { $0.index < $1.index }) {
                    result.append(
                        Vocabulary(
                            level: level.replacingOccurrences(of: "HCL", with: ""),
                            chapterName: chapterName,
                            topicName: topicName,
                            index: raw.index,
                            word: raw.word,
                            pinyin: raw.pinyin,
                            englishDefinition: raw.englishDefinition,
                            chineseDefinition: raw.chineseDefinition,
                            example: raw.example,
                            questions: raw.questions,
                            chineseLevel: Vocabulary.ChineseLevel.from(level: level)
                        )
                    )
                }
            }
        }

        return result
    }
}
