import Foundation

enum LastProgressStore {
    struct Point: Codable, Hashable {
        let level: SecondaryNumber
        let chapter: Chapter
        let topic: Topic
        let currentIndex: Int
    }

    private static let key = "xuemi.lastProgressQueue"

    private static func loadAll() -> [Point] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([Point].self, from: data)) ?? []
    }

    private static func saveAll(_ points: [Point]) {
        if let data = try? JSONEncoder().encode(points) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func getAll() -> [Point] {
        loadAll()
    }

    static func set(level: SecondaryNumber, chapter: Chapter, topic: Topic, currentIndex: Int) {
        var points = loadAll()

        points.removeAll {
            $0.level == level && $0.chapter == chapter && $0.topic == topic
        }

        let newPoint = Point(level: level, chapter: chapter, topic: topic, currentIndex: currentIndex)
        points.insert(newPoint, at: 0)

        if points.count > 5 {
            points = Array(points.prefix(5))
        }

        saveAll(points)
    }

    static func clearAll() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
