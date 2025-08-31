import UIKit

enum ProfileStorage {
    private static var docs: URL { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] }

    private static func userDir(uid: String?) -> URL {
        let key = (uid?.isEmpty == false) ? "u_\(uid!)" : "u_local"
        let dir = docs.appendingPathComponent(key, isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private static func profileURL(uid: String?) -> URL { userDir(uid: uid).appendingPathComponent("profile.json") }
    private static func avatarURL(uid: String?) -> URL { userDir(uid: uid).appendingPathComponent("avatar.jpg") }

    static func save(uid: String?, profile: UserProfile, avatar: UIImage?) {
        let pURL = profileURL(uid: uid)
        let aURL = avatarURL(uid: uid)
        DispatchQueue.global(qos: .background).async {
            if let data = try? JSONEncoder().encode(profile) { try? data.write(to: pURL, options: .atomic) }
            if let avatar, let jpeg = avatar.jpegData(compressionQuality: 0.9) {
                try? jpeg.write(to: aURL, options: .atomic)
            } else {
                try? FileManager.default.removeItem(at: aURL)
            }
        }
    }

    static func loadProfile(uid: String?) -> UserProfile? {
        guard let data = try? Data(contentsOf: profileURL(uid: uid)) else { return nil }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }

    static func loadAvatar(uid: String?) -> UIImage? {
        guard let data = try? Data(contentsOf: avatarURL(uid: uid)) else { return nil }
        return UIImage(data: data)
    }

    static func clear(uid: String?) {
        try? FileManager.default.removeItem(at: profileURL(uid: uid))
        try? FileManager.default.removeItem(at: avatarURL(uid: uid))
    }
}

