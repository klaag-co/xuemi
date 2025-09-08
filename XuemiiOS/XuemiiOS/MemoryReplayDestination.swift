import SwiftUI

/// Replays a stored MemoryAttempt as a read-only MemoryResultsView.
struct MemoryReplayDestination: View {
    let attempt: MemoryAttempt

    private func makeVocabulary(from lite: VocabLite) -> Vocabulary {
        Vocabulary(
            index: lite.id,
            word: lite.word,
            pinyin: lite.pinyin,
            englishDefinition: "",
            chineseDefinition: "",
            example: "",
            questions: []
        )
    }

    var body: some View {
        let vocabularies = attempt.vocab.map(makeVocabulary(from:))
        let level = attempt.levelRaw.flatMap(SecondaryNumber.init(rawValue:))
        let history = MemoryStats.shared.history(for: attempt.contextTitle)

        MemoryResultsView(
            tries: attempt.tries,
            vocabularies: vocabularies,
            level: level,
            chapter: nil,
            topic: nil,
            folderName: attempt.contextTitle,   // acts as set title
            history: history,
            onPlayAgain: nil                    // no play-on replay
        )
    }
}

