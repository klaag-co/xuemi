import SwiftUI

struct MCQResultsView: View {
    // MARK: - Inputs (score)
    let correctAnswers: Int
    let wrongAnswers: Int
    let improvements: [(vocab: Vocabulary, index: Int)]
    let totalQuestions: Int

    // MARK: - Inputs (data needed for lists & flashcard nav)
    let vocabularies: [Vocabulary]
    let userAnswers: [String?]

    // MARK: - Context (either enums for course path OR folder name)
    let level: SecondaryNumber?
    let chapter: Chapter?
    let topic: Topic?
    let folderName: String?

    // MARK: - Behavior flags
    var isReplay: Bool = false
    var recordToHistory: Bool = true
    var onDone: (() -> Void)? = nil
    
    // MARK: - Env / State
    @ObservedObject private var pathManager: PathManager = .global
    @Environment(\.dismiss) private var dismiss
    @State private var didRecord = false

    // MARK: - Derived
    private var percent: Double {
        guard totalQuestions > 0 else { return 0 }
        return (Double(correctAnswers) / Double(totalQuestions)) * 100.0
    }

    private var grade: String {
        switch percent {
        case 75...:      return "A1"
        case 70..<75:    return "A2"
        case 65..<70:    return "B3"
        case 60..<65:    return "B4"
        case 55..<60:    return "C5"
        case 50..<55:    return "C6"
        case 45..<50:    return "D7"
        case 40..<45:    return "E8"
        default:         return "F9"
        }
    }

    private var correctList: [Vocabulary] {
        zip(vocabularies, userAnswers).compactMap { v, ans in
            (ans == v.word) ? v : nil
        }
    }

    private struct WrongItem: Identifiable {
        let id = UUID()
        let correct: Vocabulary
        let chosen: Vocabulary?
    }

    private var wrongList: [WrongItem] {
        zip(vocabularies, userAnswers).compactMap { v, ans in
            guard let ans, ans != v.word else { return nil }
            let chosenV = vocabularies.first(where: { $0.word == ans })
            return WrongItem(correct: v, chosen: chosenV)
        }
    }

    // MARK: - UI
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ResultRing(percent: percent, correct: correctAnswers, total: totalQuestions, grade: grade)
                    .padding(.top, 8)

                // ===== Buttons =====
                if isReplay {
                    // ✅ Back to Progress — ONLY mutate path (no dismiss)
                    Button {
                        withAnimation {
                            if !pathManager.path.isEmpty {
                                pathManager.path.removeLast()
                            }
                        }
                    } label: {
                        Text("Back to Progress")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)

                    // ✅ Go to Home — ONLY popToRoot (no dismiss)
                    Button {
                        withAnimation {
                            PathManager.global.popToRoot()
                        }
                    } label: {
                        Text("Go to Home")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                } else {
                    // Fresh quiz flow
                    Button {
                        onDone?()
                        withAnimation { pathManager.popToRoot() }
                    } label: {
                        Text("Go to Home page")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)

                    NavigationLink {
                        ProgressDetailView()
                    } label: {
                        Text("View Progress")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                }

                // ✅ Correct
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "✅ 正确 (Correct)", count: correctList.count)

                    if correctList.isEmpty {
                        EmptyHint(text: "No correct answers yet.")
                    } else {
                        Card {
                            LazyVStack(spacing: 0) {
                                ForEach(correctList, id: \.index) { v in
                                    NavigationLink {
                                        flashcardDestination(for: v)
                                    } label: {
                                        VocabRowCompact(v: v)
                                    }
                                    .buttonStyle(.plain)
                                    .rowSeparator(insets: EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // ❌ Wrong — side-by-side (no labels), only word+pinyin
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "❌ 错误 (Wrong)", count: wrongList.count)

                    if wrongList.isEmpty {
                        EmptyHint(text: "No mistakes — nice!")
                    } else {
                        Card {
                            LazyVStack(spacing: 0) {
                                ForEach(wrongList) { item in
                                    HStack(spacing: 0) {
                                        // Left: correct vocab
                                        NavigationLink {
                                            flashcardDestination(for: item.correct)
                                        } label: {
                                            VocabRowCompact(v: item.correct, chevron: true)
                                        }
                                        .buttonStyle(.plain)
                                        .frame(maxWidth: .infinity)

                                        Rectangle().frame(width: 0.5).opacity(0.25)

                                        // Right: chosen vocab in red (or dash)
                                        if let chosen = item.chosen {
                                            NavigationLink {
                                                flashcardDestination(for: chosen)
                                            } label: {
                                                VocabRowCompact(v: chosen, tint: .red, chevron: true)
                                            }
                                            .buttonStyle(.plain)
                                            .frame(maxWidth: .infinity)
                                        } else {
                                            HStack {
                                                Text("—").foregroundStyle(.secondary)
                                                Spacer()
                                            }
                                            .frame(minHeight: 52)
                                            .frame(maxWidth: .infinity)
                                        }
                                    }
                                    .rowSeparator()
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Save once unless disabled (replay).
            guard recordToHistory, !didRecord else { return }

            let title: String
            if let level, let chapter, let topic {
                title = "中\(level.string) · \(chapter.string) · \(topic.string(level: level, chapter: chapter))"
            } else if let folderName {
                title = folderName
            } else {
                title = "Practice"
            }

            let minis: [VocabLite] = vocabularies.map { v in
                VocabLite(id: v.index, word: v.word, pinyin: v.pinyin)
            }

            ScoreManager.shared.recordSnapshot(
                correct: correctAnswers,
                total: vocabularies.count,
                contextTitle: title,
                levelRaw: level?.rawValue,
                chapterRaw: nil,   // fill if you store chapter raw value
                topicRaw: nil,     // fill if you store topic raw value
                folderName: folderName,
                vocab: minis,
                userAnswers: userAnswers
            )
            didRecord = true
        }
    }

    // MARK: - Destinations
    @ViewBuilder
    private func flashcardDestination(for vocab: Vocabulary) -> some View {
        let idx = indexFor(vocab: vocab)
        if let level, let chapter, let topic {
            FlashcardView(
                vocabularies: vocabularies,
                level: level,
                chapter: chapter,
                topic: topic,
                currentIndex: idx
            )
        } else if let folderName {
            FlashcardView(
                vocabularies: vocabularies,
                folderName: folderName,
                currentIndex: idx
            )
        } else {
            FlashcardView(
                vocabularies: vocabularies,
                folderName: "Set",
                currentIndex: idx
            )
        }
    }

    private func indexFor(vocab: Vocabulary) -> Int {
        vocabularies.firstIndex(where: { $0.index == vocab.index && $0.word == vocab.word }) ?? 0
    }
}

// MARK: - Small pieces

private struct SectionHeader: View {
    let title: String
    let count: Int
    var body: some View {
        HStack {
            Text("\(title)  •  \(count)")
                .font(.headline)
            Spacer()
        }
    }
}

private struct EmptyHint: View {
    let text: String
    var body: some View {
        Text(text)
            .foregroundColor(.secondary)
            .padding(.vertical, 8)
    }
}

private struct Card<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        content
            .padding(.vertical, 4)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.separator), lineWidth: 0.5)
            )
    }
}

private extension View {
    @ViewBuilder
    func rowSeparator(insets: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)) -> some View {
        overlay(alignment: .bottomLeading) {
            Rectangle()
                .frame(height: 0.5)
                .opacity(0.25)
                .padding(insets)
        }
    }
}

// Compact row: ONLY word + pinyin (no meaning)
private struct VocabRowCompact: View {
    let v: Vocabulary
    var tint: Color = .primary
    var chevron: Bool = true

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(v.word).font(.headline).foregroundStyle(tint)
                Text(v.pinyin).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            if chevron {
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(UIColor.tertiaryLabel))
            }
        }
        .padding(.horizontal, 12)
        .frame(minHeight: 52)
        .contentShape(Rectangle())
    }
}

// Ring without gaps: red full track + green correct arc
private struct ResultRing: View {
    let percent: Double
    let correct: Int
    let total: Int
    let grade: String

    var body: some View {
        ZStack {
            // subtle outer track
            Circle().stroke(Color(.systemGray5), lineWidth: 22)

            // red full background for "wrong"
            Circle().stroke(Color.red.opacity(0.75), lineWidth: 22)

            // green arc for "correct"
            Circle()
                .trim(from: 0, to: CGFloat(percent / 100))
                .stroke(Color.green, style: StrokeStyle(lineWidth: 22, lineCap: .round))
                .rotationEffect(.degrees(-90))

            VStack(spacing: 6) {
                Text("\(Int(round(percent)))%")
                    .font(.system(size: 44, weight: .bold))
                Text("\(grade) • \(correct)/\(total)")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 220, height: 220)
    }
}

