import Foundation

struct LeaderboardEntry: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var username: String

    // streak data
    var streak: Int
    var updatedAt: Date = Date()

    // profile snapshot
    var favoriteAnimal: String?
    var favoriteColor: String?
    var country: String?
    var school: String?
    var bioLine: String?
    var ageDescription: String?   // ← add age as string (e.g., "15")

    // avatar snapshot as JPEG bytes (thumbnail)
    var avatarJPEGData: Data? = nil
}

