import Foundation

struct StreakState: Codable {
    var current: Int = 0
    var best: Int = 0
    var lastSuccessDay: Date? = nil
}

