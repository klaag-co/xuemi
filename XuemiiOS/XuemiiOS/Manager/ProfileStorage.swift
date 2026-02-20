import UIKit

enum ProfileStorage {
    private static var docs: URL { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] }

    private static func userDir(id: String?) -> URL {
        let key = (id?.isEmpty == false) ? "u_\(id!)" : "u_local"
        let dir = docs.appendingPathComponent(key, isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    /// Information about the user's profile
    private static func profileURL(id: String?) -> URL { userDir(id: id).appendingPathComponent("profile.json") }
    /// The picture used for the user's profile picture
    private static func avatarURL(id: String?) -> URL { userDir(id: id).appendingPathComponent("avatar.jpg") }

    static func save(id: String?, profile: UserProfile, avatar: UIImage?) {
        let pURL = profileURL(id: id)
        let aURL = avatarURL(id: id)
        DispatchQueue.global(qos: .background).async {
            if let data = try? JSONEncoder().encode(profile) { try? data.write(to: pURL, options: .atomic) }
            if let avatar, let jpeg = avatar.jpegData(compressionQuality: 0.9) {
                try? jpeg.write(to: aURL, options: .atomic)
            } else {
                try? FileManager.default.removeItem(at: aURL)
            }
        }
    }

    static func loadProfile(id: String?) -> UserProfile? {
        guard let data = try? Data(contentsOf: profileURL(id: id)) else { return nil }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }

    static func loadAvatar(id: String?) -> UIImage? {
        guard let data = try? Data(contentsOf: avatarURL(id: id)) else { return nil }
        return UIImage(data: data)
    }

    static func clear(id: String?) {
        try? FileManager.default.removeItem(at: profileURL(id: id))
        try? FileManager.default.removeItem(at: avatarURL(id: id))
    }
}

