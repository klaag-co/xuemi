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



