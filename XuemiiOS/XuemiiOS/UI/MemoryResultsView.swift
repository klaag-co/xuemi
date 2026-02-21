import SwiftUI

struct MemoryResultsView: View {
    // Score-ish
    let tries: Int

    // Context
    let vocabularies: [Vocabulary]
    let level: SecondaryNumber?
    let chapter: Chapter?
    let topic: Topic?
    let folderName: String?

    // History (for stats)
    let history: [MemoryAttempt]

    // Actions
    var onPlayAgain: (() -> Void)?

    @ObservedObject private var pathManager: PathManager = .global

    // Stats
    private var best: Int { history.map(\.tries).min() ?? tries }
    private var worst: Int { history.map(\.tries).max() ?? tries }
    private var avg: Double {
        guard !history.isEmpty else { return Double(tries) }
        let s = history.reduce(0) { $0 + $1.tries }
        return Double(s) / Double(history.count)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 6) {
                    Text("Memory Complete!")
                        .font(.largeTitle).bold()
                    Text(contextTitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 8)

                // Big tries ring/badge
                ZStack {
                    Circle().stroke(Color(.systemGray5), lineWidth: 22)
                    Circle().stroke(Color.blue.opacity(0.25), lineWidth: 22)
                    VStack(spacing: 4) {
                        Text("\(tries)")
                            .font(.system(size: 44, weight: .bold))
                        Text("Tries")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 220, height: 220)

                // Stats row
                HStack(spacing: 12) {
                    StatCard(title: "Best", value: "\(best)")
                    StatCard(title: "Average", value: String(format: "%.1f", avg))
                    StatCard(title: "Worst", value: "\(worst)")
                }
                .padding(.horizontal)

                // Buttons
                VStack(spacing: 10) {
                    if let onPlayAgain {
                        Button {
                            onPlayAgain()
                        } label: {
                            Text("Play Again")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(.systemGray5))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    Button {
                        withAnimation { PathManager.global.goProgressDetail() }
                    } label: {
                        Text("Back to Progress")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button {
                        withAnimation { PathManager.global.goHome() }
                    } label: {
                        Text("Go to Home")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)

                // 🔤 Vocab list
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("🃏 Cards  •  \(vocabularies.count)")
                            .font(.headline)
                        Spacer()
                    }

                    if vocabularies.isEmpty {
                        Text("No words captured.")
                            .foregroundStyle(.secondary)
                    } else {
                        Card {
                            LazyVStack(spacing: 0) {
                                ForEach(vocabularies, id: \.index) { v in
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
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }

    private var contextTitle: String {
        if let level, let chapter, let topic {
            return "中\(level.string) · \(chapter.string) · \(topic.string(level: level, chapter: chapter))"
        } else if let folderName {
            return folderName
        } else {
            return "Practice"
        }
    }

    // Flashcard destination
    @ViewBuilder
    private func flashcardDestination(for vocab: Vocabulary) -> some View {
        let idx = vocabularies.firstIndex(where: { $0.index == vocab.index && $0.word == vocab.word }) ?? 0
        if let level, let chapter, let topic {
            FlashcardView(
                vocabularies: vocabularies,
                level: level, chapter: chapter, topic: topic,
                currentIndex: idx
            )
        } else if let folderName {
            FlashcardView(vocabularies: vocabularies, folderName: folderName, currentIndex: idx)
        } else {
            FlashcardView(vocabularies: vocabularies, folderName: "Set", currentIndex: idx)
        }
    }
}

// Reuse small pieces

private struct StatCard: View {
    let title: String, value: String
    var body: some View {
        VStack(spacing: 6) {
            Text(value).font(.title3).bold()
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
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

