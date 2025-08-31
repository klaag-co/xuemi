import Foundation

enum ScoreStorage {
    private static var docs: URL { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] }

    private static func userDir(uid: String?) -> URL {
        let key = (uid?.isEmpty == false) ? "u_\(uid!)" : "u_local"
        let dir = docs.appendingPathComponent(key, isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private static func scoresURL(uid: String?) -> URL { userDir(uid: uid).appendingPathComponent("scores.json") }

    static func load(uid: String?) -> [ScoreEntry] {
        guard let data = try? Data(contentsOf: scoresURL(uid: uid)) else { return [] }
        return (try? JSONDecoder().decode([ScoreEntry].self, from: data)) ?? []
    }

    static func save(uid: String?, _ entries: [ScoreEntry]) {
        let url = scoresURL(uid: uid)
        DispatchQueue.global(qos: .background).async {
            guard let data = try? JSONEncoder().encode(entries) else { return }
            try? data.write(to: url, options: .atomic)
        }
    }

    static func clear(uid: String?) {
        try? FileManager.default.removeItem(at: scoresURL(uid: uid))
    }
}

