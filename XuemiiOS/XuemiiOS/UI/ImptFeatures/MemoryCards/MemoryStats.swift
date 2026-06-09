//
//  MemoryStats 2.swift
//  XuemiiOS
//
//  Created by Kmy Er on 1/11/25.
//

import Foundation
import Combine

public final class MemoryStats: ObservableObject {
    public static let shared = MemoryStats()

    @Published public private(set) var attempts: [MemoryAttempt] = []

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
