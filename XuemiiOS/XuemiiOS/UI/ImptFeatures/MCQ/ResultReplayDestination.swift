import SwiftUI

/// Opens a read-only "replay" of a stored QuizResult inside MCQResultsView.
struct ResultReplayDestination: View {
    let quiz: QuizResult

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
        let vocabularies: [Vocabulary] = quiz.vocab.map(makeVocabulary(from:))
        let userAnswers: [String?] = quiz.userAnswers

        let correctCount: Int = zip(vocabularies, userAnswers).reduce(0) { sum, pair in
            let (v, ans) = pair
            return sum + ((ans == v.word) ? 1 : 0)
        }
        let total = max(quiz.total, vocabularies.count)

        let improvements: [(vocab: Vocabulary, index: Int)] =
            zip(vocabularies, userAnswers).compactMap { v, ans in
                (ans == v.word) ? nil : (v, v.index)
            }

        let level: SecondaryNumber? = quiz.levelRaw.flatMap(SecondaryNumber.init(rawValue:))

        MCQResultsView(
            correctAnswers: correctCount,
            wrongAnswers: max(0, total - correctCount),
            improvements: improvements,
            totalQuestions: total,
            vocabularies: vocabularies,
            userAnswers: userAnswers,
            level: level,
            chapter: nil,
            topic: nil,
            folderName: quiz.contextTitle,
            isReplay: true,
            recordToHistory: false
        )
        .navigationTitle("MCQ Replay")
    }
}

