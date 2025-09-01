import Foundation

enum LeaderboardStorage {
    private static var docs: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    private static var url: URL { docs.appendingPathComponent("leaderboard.json") }

    static func load() -> [LeaderboardEntry] {
        guard let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([LeaderboardEntry].self, from: data)) ?? []
    }

    static func save(_ items: [LeaderboardEntry]) {
        DispatchQueue.global(qos: .background).async {
            guard let data = try? JSONEncoder().encode(items) else { return }
            try? data.write(to: url, options: .atomic)
        }
    }
}

