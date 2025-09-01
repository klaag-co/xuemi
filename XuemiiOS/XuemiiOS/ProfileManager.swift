import SwiftUI

final class ProfileManager: ObservableObject {
    static let shared = ProfileManager()

    @Published var profile: UserProfile?
    @Published var avatarImage: UIImage?
    private var currentUID: String?

    private init() { switchUser(uid: currentUID) }

    func switchUser(uid: String?) {          // call with nil for now
        currentUID = uid
        profile = ProfileStorage.loadProfile(uid: uid)
        avatarImage = ProfileStorage.loadAvatar(uid: uid)
    }

    func update(profile: UserProfile, avatar: UIImage?) {
        self.profile = profile
        self.avatarImage = avatar
        ProfileStorage.save(uid: currentUID, profile: profile, avatar: avatar)
    }

    func clearLocal() {
        ProfileStorage.clear(uid: currentUID)
        profile = nil
        avatarImage = nil
    }
}

