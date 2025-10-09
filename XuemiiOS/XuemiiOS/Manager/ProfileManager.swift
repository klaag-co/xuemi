import SwiftUI

final class ProfileManager: ObservableObject {
    static let shared = ProfileManager()

    @Published var profile: UserProfile?
    @Published var avatarImage: UIImage?

    private init() { }

    func switchUser(id: String?) {          // call with nil for now
        profile = ProfileStorage.loadProfile(id: id)
        avatarImage = ProfileStorage.loadAvatar(id: id)
        
        if let id {
            Task {
                profile = (try await ProfileRemoteStorage.fetch(id: id)) ?? profile
            }
        }
    }

    func update(profile: UserProfile, avatar: UIImage?) {
        self.profile = profile
        self.avatarImage = avatar
        ProfileStorage.save(id: profile.id, profile: profile, avatar: avatar)
        Task {
            try await ProfileRemoteStorage.update(profile: profile)
        }
    }

    func clearLocal() {
        ProfileStorage.clear(id: profile?.id)
        profile = nil
        avatarImage = nil
    }
}

