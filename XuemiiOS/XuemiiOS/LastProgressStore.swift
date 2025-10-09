import Foundation

enum LastProgressStore {
    // Nested model to avoid global name clashes
    struct Point: Codable, Hashable {
        let level: SecondaryNumber
        let chapter: Chapter
        let topic: Topic
        let currentIndex: Int
    }

    private static let key = "xuemi.lastProgressByLevel"

    private static func loadAll() -> [Int: Point] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [:] }
        return (try? JSONDecoder().decode([Int: Point].self, from: data)) ?? [:]
    }

    private static func saveAll(_ dict: [Int: Point]) {
        if let data = try? JSONEncoder().encode(dict) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func get(level: SecondaryNumber) -> Point? {
        loadAll()[level.rawValue]
    }

    static func set(level: SecondaryNumber, chapter: Chapter, topic: Topic, currentIndex: Int) {
        var dict = loadAll()
        dict[level.rawValue] = Point(level: level, chapter: chapter, topic: topic, currentIndex: currentIndex)
        saveAll(dict)
    }

    static func clear(level: SecondaryNumber) {
        var dict = loadAll()
        dict.removeValue(forKey: level.rawValue)
        saveAll(dict)
    }
}

