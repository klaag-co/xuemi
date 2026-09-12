//
//  ScoresManager.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 17/6/26.
//

import SwiftUI
import FirebaseFirestore

@Observable
class ScoresManager {
    var scores: [ScoreData]
    
    private let authManager: AuthManager
    private let settingsManager: SettingsManager
    
    init(authManager: AuthManager, settingsManager: SettingsManager) {
        self.authManager = authManager
        self.settingsManager = settingsManager
        self.scores = []
    }
    
    func load() {
        guard let uid = authManager.uid, let chineseLevel = settingsManager.chineseLevel else { return }
        var scores: [ScoreData] = []
        
        Task {
            do {
                let snapshot = try await scoresCollection(uid: uid, chineseLevel: chineseLevel).getDocuments()
                if !snapshot.isEmpty {
                    snapshot.documents.forEach { document in
                        let date = (document.data()["date"] as? Timestamp)?.dateValue()
                        let parentName = document.data()["parentName"] as? String
                        let value = document.data()["value"] as? Double
                        
                        let scoreTypeString = document.data()["scoreType"] as? String
                        let scoreType = Self.parseScoreType(scoreTypeString)
                        
                        if let date, let parentName, let value, let scoreType {
                            let mcqAnswers = Self.parseAnswers(document.data()["answers"], fallbackChineseLevel: chineseLevel)
                            let memoryCards = Self.parseVocabularies(document.data()["cards"], fallbackChineseLevel: chineseLevel)

                            scores.append(
                                ScoreData(
                                    id: document.documentID,
                                    date: date,
                                    parentName: parentName,
                                    value: value,
                                    type: scoreType,
                                    mcqAnswers: mcqAnswers,
                                    memoryCards: memoryCards
                                )
                            )
                        }
                    }
                }

                guard settingsManager.chineseLevel == chineseLevel else { return }

                withAnimation {
                    self.scores = scores
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func logScore(
        parentName: String,
        value: Double,
        for type: ScoreData.ScoreType,
        mcqAnswers: [Answer]? = nil,
        memoryCards: [Vocabulary]? = nil
    ) async {
        guard let uid = authManager.uid, let chineseLevel = settingsManager.chineseLevel else { return }
        do {
            var data: [String: Any] = [
                "date": Date(),
                "parentName": parentName,
                "value": value,
                "scoreType": type.rawValue.lowercased()
            ]

            if let mcqAnswers {
                data["answers"] = mcqAnswers.map { Self.answerData($0) }
            }

            if let memoryCards {
                data["cards"] = memoryCards.map { Self.vocabularyData($0) }
            }

            try await scoresCollection(uid: uid, chineseLevel: chineseLevel).addDocument(data: data)
            load()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func chartData(
        type: ScoreData.ScoreType,
        level: ScoreData.Level,
        interval: ScoreData.TimeInterval
    ) -> [ScoreChartData] {
        let calendar = Calendar.current
        let labels = interval.range

        var buckets = Dictionary(uniqueKeysWithValues: labels.map { ($0, [Double]()) })

        for score in filteredScores(type: type, level: level, interval: interval, calendar: calendar) {
            guard let label = bucketLabel(for: score.date, interval: interval, calendar: calendar) else { continue }
            buckets[label, default: []].append(displayValue(for: score))
        }

        return labels.map { label in
            let values = buckets[label] ?? []
            let average = values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
            return ScoreChartData(label: label, value: average, attemptCount: values.count)
        }
    }

    func summary(
        type: ScoreData.ScoreType,
        level: ScoreData.Level,
        interval: ScoreData.TimeInterval
    ) -> ScoreSummary {
        let calendar = Calendar.current
        let filtered = filteredScores(type: type, level: level, interval: interval, calendar: calendar)
        let values = filtered.map { displayValue(for: $0) }

        guard !values.isEmpty else {
            return ScoreSummary(totalCount: 0, overallAverage: 0, bestScore: nil)
        }

        let average = values.reduce(0, +) / Double(values.count)
        let best: Double
        switch type {
        case .mcq:
            best = values.max() ?? 0
        case .memory:
            best = values.min() ?? 0
        }

        return ScoreSummary(totalCount: filtered.count, overallAverage: average, bestScore: best)
    }

    func scores(
        for label: String,
        type: ScoreData.ScoreType,
        level: ScoreData.Level,
        interval: ScoreData.TimeInterval
    ) -> [ScoreData] {
        let calendar = Calendar.current

        return filteredScores(type: type, level: level, interval: interval, calendar: calendar)
            .filter { score in
                bucketLabel(for: score.date, interval: interval, calendar: calendar) == label
            }
            .sorted { $0.date > $1.date }
    }

    func mcqCountToday() -> Int {
        let calendar = Calendar.current
        return scores.filter { score in
            score.type == .mcq && calendar.isDate(score.date, inSameDayAs: Date())
        }.count
    }

    func mcqOverallAverage() -> Double {
        let values = scores.filter { $0.type == .mcq }.map { displayValue(for: $0) }
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }

    func formattedValue(for score: ScoreData) -> String {
        switch score.type {
        case .mcq:
            let percentage = score.value <= 1 ? score.value * 100 : score.value
            return "\(Int(percentage.rounded()))%"
        case .memory:
            let tries = Int(score.value.rounded())
            return tries == 1 ? "1 try" : "\(tries) tries"
        }
    }

    private func filteredScores(
        type: ScoreData.ScoreType,
        level: ScoreData.Level,
        interval: ScoreData.TimeInterval,
        calendar: Calendar
    ) -> [ScoreData] {
        scores.filter { score in
            score.type == type &&
            matchesLevel(score, level: level) &&
            matchesInterval(score, interval: interval, calendar: calendar)
        }
    }

    private func displayValue(for score: ScoreData) -> Double {
        switch score.type {
        case .mcq:
            return score.value <= 1 ? score.value * 100 : score.value
        case .memory:
            return score.value
        }
    }

    private func matchesLevel(_ score: ScoreData, level: ScoreData.Level) -> Bool {
        guard level != .all else { return true }
        return score.parentName.hasPrefix(level.rawValue)
    }

    private func matchesInterval(
        _ score: ScoreData,
        interval: ScoreData.TimeInterval,
        calendar: Calendar
    ) -> Bool {
        switch interval {
        case .week:
            return calendar.isDate(score.date, equalTo: Date(), toGranularity: .weekOfYear)
        case .month:
            return calendar.isDate(score.date, equalTo: Date(), toGranularity: .month)
        }
    }

    private func bucketLabel(
        for date: Date,
        interval: ScoreData.TimeInterval,
        calendar: Calendar
    ) -> String? {
        let labels = interval.range

        switch interval {
        case .week:
            // Calendar weekday: 1 = Sunday … 7 = Saturday
            let weekday = calendar.component(.weekday, from: date)
            let index = weekday - 1
            guard labels.indices.contains(index) else { return nil }
            return labels[index]
        case .month:
            let weekOfMonth = calendar.component(.weekOfMonth, from: date)
            guard weekOfMonth >= 1, weekOfMonth <= labels.count else { return nil }
            return labels[weekOfMonth - 1]
        }
    }

    private static func parseScoreType(_ raw: String?) -> ScoreData.ScoreType? {
        switch raw?.lowercased() {
        case "mcq": .mcq
        case "memory": .memory
        default: nil
        }
    }

    private static func vocabularyData(_ vocabulary: Vocabulary) -> [String: Any] {
        [
            "level": vocabulary.level,
            "chapterName": vocabulary.chapterName,
            "topicName": vocabulary.topicName,
            "index": vocabulary.index,
            "word": vocabulary.word,
            "pinyin": vocabulary.pinyin,
            "englishDefinition": vocabulary.englishDefinition,
            "chineseDefinition": vocabulary.chineseDefinition,
            "example": vocabulary.example,
            "questions": vocabulary.questions,
            "chineseLevel": vocabulary.chineseLevel.rawValue
        ]
    }

    private static func parseVocabulary(_ data: [String: Any], fallbackChineseLevel: Vocabulary.ChineseLevel) -> Vocabulary? {
        guard
            let level = data["level"] as? String,
            let chapterName = data["chapterName"] as? String,
            let topicName = data["topicName"] as? String,
            let index = intValue(data["index"]),
            let word = data["word"] as? String,
            let pinyin = data["pinyin"] as? String,
            let englishDefinition = data["englishDefinition"] as? String,
            let chineseDefinition = data["chineseDefinition"] as? String,
            let example = data["example"] as? String
        else { return nil }

        let questions = stringArray(data["questions"]) ?? []

        let chineseLevel = (data["chineseLevel"] as? String).flatMap(Vocabulary.ChineseLevel.init(rawValue:))
            ?? fallbackChineseLevel

        return Vocabulary(
            level: level,
            chapterName: chapterName,
            topicName: topicName,
            index: index,
            word: word,
            pinyin: pinyin,
            englishDefinition: englishDefinition,
            chineseDefinition: chineseDefinition,
            example: example,
            questions: questions,
            chineseLevel: chineseLevel
        )
    }

    private static func parseVocabularies(_ raw: Any?, fallbackChineseLevel: Vocabulary.ChineseLevel) -> [Vocabulary]? {
        let vocabularies = dictionaryArray(raw).compactMap { parseVocabulary($0, fallbackChineseLevel: fallbackChineseLevel) }
        return vocabularies.isEmpty ? nil : vocabularies
    }

    private static func answerData(_ answer: Answer) -> [String: Any] {
        switch answer {
        case .correct(let vocabulary):
            return [
                "type": "correct",
                "vocabulary": vocabularyData(vocabulary)
            ]
        case .wrong(let selected, let correct):
            return [
                "type": "wrong",
                "selected": vocabularyData(selected),
                "correct": vocabularyData(correct)
            ]
        }
    }

    private static func parseAnswer(_ data: [String: Any], fallbackChineseLevel: Vocabulary.ChineseLevel) -> Answer? {
        switch data["type"] as? String {
        case "correct":
            guard
                let vocabularyData = data["vocabulary"] as? [String: Any],
                let vocabulary = parseVocabulary(vocabularyData, fallbackChineseLevel: fallbackChineseLevel)
            else { return nil }
            return .correct(vocabulary)
        case "wrong":
            guard
                let selectedData = data["selected"] as? [String: Any],
                let correctData = data["correct"] as? [String: Any],
                let selected = parseVocabulary(selectedData, fallbackChineseLevel: fallbackChineseLevel),
                let correct = parseVocabulary(correctData, fallbackChineseLevel: fallbackChineseLevel)
            else { return nil }
            return .wrong(selected, correct)
        default:
            return nil
        }
    }

    private static func parseAnswers(_ raw: Any?, fallbackChineseLevel: Vocabulary.ChineseLevel) -> [Answer]? {
        let answers = dictionaryArray(raw).compactMap { parseAnswer($0, fallbackChineseLevel: fallbackChineseLevel) }
        return answers.isEmpty ? nil : answers
    }

    private static func dictionaryArray(_ value: Any?) -> [[String: Any]] {
        guard let entries = value as? [Any] else { return [] }
        return entries.compactMap { $0 as? [String: Any] }
    }

    private static func stringArray(_ value: Any?) -> [String]? {
        if let strings = value as? [String] { return strings }
        guard let entries = value as? [Any] else { return nil }
        let strings = entries.compactMap { $0 as? String }
        return strings.count == entries.count ? strings : nil
    }

    private static func intValue(_ value: Any?) -> Int? {
        if let int = value as? Int { return int }
        if let int64 = value as? Int64 { return Int(int64) }
        if let number = value as? NSNumber { return number.intValue }
        return nil
    }

    private func scoresCollection(uid: String, chineseLevel: Vocabulary.ChineseLevel) -> CollectionReference {
        Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("scores-\(chineseLevel.rawValue)")
    }
}
