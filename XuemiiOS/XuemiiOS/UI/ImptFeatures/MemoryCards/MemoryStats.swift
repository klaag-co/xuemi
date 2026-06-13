import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

public final class MemoryStats: ObservableObject {
    public static let shared = MemoryStats()

    @Published public private(set) var attempts: [MemoryAttempt] = []

    private let storeKey = "memory_attempts_v2"
    private var cancellables = Set<AnyCancellable>()

    private var userDocId: String? {
        if let uid = Auth.auth().currentUser?.uid { return uid }
        if let email = AuthenticationManager.shared.email?
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return email
        }
        return nil
    }

    private init() {
        load()
        $attempts
            .sink { [weak self] _ in self?.save() }
            .store(in: &cancellables)
    }

    public func record(
        tries: Int,
        contextTitle: String,
        levelRaw: Int?,
        chapterRaw: Int?,
        topicRaw: Int?,
        folderName: String?,
        vocab: [VocabLite]
    ) {
        let a = MemoryAttempt(
            tries: tries,
            contextTitle: contextTitle,
            levelRaw: levelRaw,
            chapterRaw: chapterRaw,
            topicRaw: topicRaw,
            folderName: folderName,
            vocab: vocab
        )

        attempts.append(a)
        attempts.sort { $0.date > $1.date }
    }

    public func history(for contextTitle: String) -> [MemoryAttempt] {
        attempts.filter { $0.contextTitle == contextTitle }
    }

    public func delete(_ attempt: MemoryAttempt) {
        attempts.removeAll { $0.id == attempt.id }
    }

    func clearAll() {
        attempts.removeAll()
        UserDefaults.standard.removeObject(forKey: storeKey)
        UserDefaults.standard.removeObject(forKey: "memory_attempts_v1")
    }

    private func load() {
        Task {
            let remoteLoaded = await getMemoryFromFirebase()
            guard !remoteLoaded else { return }

            guard let data = UserDefaults.standard.data(forKey: storeKey) else { return }

            if let decoded = try? JSONDecoder().decode([MemoryAttempt].self, from: data) {
                await MainActor.run {
                    self.attempts = decoded
                }
            }
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(attempts) {
            UserDefaults.standard.set(data, forKey: storeKey)

            Task {
                await updateMemoryOnFirebase(newMemoryData: data)
            }
        }
    }

    private func getMemoryFromFirebase() async -> Bool {
        guard let uid = userDocId else { return false }

        do {
            let userDoc = try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .getDocument()

            guard let data = userDoc.data(),
                  let memoryDataString = data["memory"] as? String
            else {
                return false
            }

            guard let memoryData = Data(base64Encoded: memoryDataString),
                  let memoryAttempts = try? JSONDecoder().decode([MemoryAttempt].self, from: memoryData)
            else {
                return false
            }

            await MainActor.run {
                self.attempts = memoryAttempts
            }

            return true
        } catch {
            print("Error getting memory: \(error)")
            return false
        }
    }

    private func updateMemoryOnFirebase(newMemoryData: Data) async {
        guard let uid = userDocId else { return }

        do {
            try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .setData(
                    ["memory": newMemoryData.base64EncodedString()],
                    merge: true
                )

            print("Memory updated on firebase")
        } catch {
            print("Error updating memory: \(error)")
        }
    }
}
