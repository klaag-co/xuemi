import Foundation
import Combine

public struct MemoryAttempt: Identifiable, Codable, Hashable {
    public let id: UUID
    public let date: Date
    public let tries: Int

    public let contextTitle: String
    public let levelRaw: Int?
    public let chapterRaw: Int?
    public let topicRaw: Int?
    public let folderName: String?

    public let vocab: [VocabLite]        // <- store the words used

    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        tries: Int,
        contextTitle: String,
        levelRaw: Int?,
        chapterRaw: Int?,
        topicRaw: Int?,
        folderName: String?,
        vocab: [VocabLite]
    ) {
        self.id = id
        self.date = date
        self.tries = tries
        self.contextTitle = contextTitle
        self.levelRaw = levelRaw
        self.chapterRaw = chapterRaw
        self.topicRaw = topicRaw
        self.folderName = folderName
        self.vocab = vocab
    }
}

public final class MemoryStats: ObservableObject {
    public static let shared = MemoryStats()

    @Published public private(set) var attempts: [MemoryAttempt] = []

    // bump key (schema now includes vocab)
    private let storeKey = "memory_attempts_v2"
    private var cancellables = Set<AnyCancellable>()

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

    // MARK: - Persistence

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storeKey) else { return }
        if let decoded = try? JSONDecoder().decode([MemoryAttempt].self, from: data) {
            self.attempts = decoded
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(attempts) {
            UserDefaults.standard.set(data, forKey: storeKey)
        }
    }
}

