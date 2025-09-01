import Foundation

enum StreakStorage {
    private static let key = "streak_state_v2"

    static func load() -> StreakState {
        if let data = UserDefaults.standard.data(forKey: key),
           let s = try? JSONDecoder().decode(StreakState.self, from: data) {
            return s
        }
        return StreakState()
    }

    static func save(_ state: StreakState) {
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

