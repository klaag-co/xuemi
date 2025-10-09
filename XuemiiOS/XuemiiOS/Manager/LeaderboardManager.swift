import SwiftUI

@MainActor
final class LeaderboardManager: ObservableObject {
    static let shared = LeaderboardManager()

    @Published private(set) var entries: [LeaderboardEntry] = []

    private init() { entries = LeaderboardStorage.load() }

    func update(entry incoming: LeaderboardEntry) {
        var list = entries
        if let idx = list.firstIndex(where: { $0.username == incoming.username }) {
            var e = list[idx]
            e.streak = incoming.streak
            e.updatedAt = Date()
            e.favoriteAnimal = incoming.favoriteAnimal
            e.favoriteColor  = incoming.favoriteColor
            e.country        = incoming.country
            e.school         = incoming.school
            e.bioLine        = incoming.bioLine
            e.avatarJPEGData = incoming.avatarJPEGData
            list[idx] = e
        } else {
            list.append(incoming)
        }
        list.sort { ($0.streak, $0.updatedAt) > ($1.streak, $1.updatedAt) }
        entries = list
        LeaderboardStorage.save(list)
    }

    func clearAll() {
        entries = []
        LeaderboardStorage.save([])
    }
}

