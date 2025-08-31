import Foundation

struct ScoreEntry: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var timestamp: Date
    var score: Int
    var outOf: Int
}

