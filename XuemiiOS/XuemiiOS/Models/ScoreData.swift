//
//  ScoreData.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 17/6/26.
//

import Foundation

struct ScoreData: Identifiable, Hashable {
    static func == (lhs: ScoreData, rhs: ScoreData) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: String
    var date: Date
    var parentName: String
    var value: Double
    var type: ScoreType
    var mcqAnswers: [Answer]?
    var memoryCards: [Vocabulary]?

    var hasResultDetails: Bool {
        switch type {
        case .mcq:
            guard let mcqAnswers, !mcqAnswers.isEmpty else { return false }
            return true
        case .memory:
            guard let memoryCards, !memoryCards.isEmpty else { return false }
            return true
        }
    }


    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    enum ScoreType: String, CaseIterable {
        case mcq = "MCQ"
        case memory = "Memory"
    }
    
    enum Level: String, CaseIterable {
        case all = "All"
        case one = "中一"
        case two = "中二"
        case three = "中三"
        case four = "中四"
    }
    
    enum TimeInterval: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        
        var range: [String] {
            switch self {
            case .week: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            case .month: ["W1", "W2", "W3", "W4"]
            }
        }

        func periodTitle(for label: String) -> String {
            switch self {
            case .week:
                switch label {
                case "Sun": "Sunday"
                case "Mon": "Monday"
                case "Tue": "Tuesday"
                case "Wed": "Wednesday"
                case "Thu": "Thursday"
                case "Fri": "Friday"
                case "Sat": "Saturday"
                default: label
                }
            case .month:
                "Week \(label.dropFirst())"
            }
        }
    }
}
