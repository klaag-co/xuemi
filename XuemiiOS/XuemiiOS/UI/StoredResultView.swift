import SwiftUI

struct StoredResultView: View {
    let quiz: QuizResult

    private var percent: Double {
        guard quiz.total > 0 else { return 0 }
        return (Double(quiz.correct) / Double(quiz.total)) * 100.0
    }
    private var grade: String {
        switch percent {
        case 75...: return "A1"
        case 70..<75: return "A2"
        case 65..<70: return "B3"
        case 60..<65: return "B4"
        case 55..<60: return "C5"
        case 50..<55: return "C6"
        case 45..<50: return "D7"
        case 40..<45: return "E8"
        default: return "F9"
        }
    }

    private var correctList: [VocabLite] {
        zip(quiz.vocab, quiz.userAnswers).compactMap { v, ans in
            (ans == v.word) ? v : nil
        }
    }
    private struct WrongItem: Identifiable {
        let id = UUID()
        let correct: VocabLite
        let chosen: VocabLite?
    }
    private var wrongList: [WrongItem] {
        zip(quiz.vocab, quiz.userAnswers).compactMap { v, ans in
            guard let ans, ans != v.word else { return nil }
            let chosen = quiz.vocab.first(where: { $0.word == ans })
            return WrongItem(correct: v, chosen: chosen)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Ring
                ZStack {
                    Circle().stroke(Color(.systemGray5), lineWidth: 22)
                    Circle().stroke(Color.red.opacity(0.75), lineWidth: 22)
                    Circle()
                        .trim(from: 0, to: CGFloat(percent / 100))
                        .stroke(Color.green, style: StrokeStyle(lineWidth: 22, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 6) {
                        Text("\(Int(round(percent)))%")
                            .font(.system(size: 44, weight: .bold))
                        Text("\(grade) • \(quiz.correct)/\(quiz.total)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 220, height: 220)
                .padding(.top, 8)

                // Context title
                if !quiz.contextTitle.isEmpty {
                    Text(quiz.contextTitle)
                        .font(.headline)
                        .padding(.horizontal)
                }

                // ✅
                section(title: "✅ 正确 (Correct)", count: correctList.count) {
                    LazyVStack(spacing: 0) {
                        ForEach(correctList, id: \.id) { v in
                            VocabRowCompactLite(v: v)
                                .rowSeparator(insets: EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                        }
                    }
                }

                // ❌ side-by-side
                section(title: "❌ 错误 (Wrong)", count: wrongList.count) {
                    LazyVStack(spacing: 0) {
                        ForEach(wrongList) { item in
                            HStack(spacing: 0) {
                                VocabRowCompactLite(v: item.correct)
                                    .frame(maxWidth: .infinity)
                                Rectangle().frame(width: 0.5).opacity(0.25)
                                if let c = item.chosen {
                                    VocabRowCompactLite(v: c, tint: .red)
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
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Saved Result")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: bits
    private func section<T: View>(title: String, count: Int, @ViewBuilder content: () -> T) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(title)  •  \(count)").font(.headline)
                Spacer()
            }
            content()
                .padding(.vertical, 4)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 0.5))
                .padding(.horizontal)
        }
    }
}

private extension View {
    @ViewBuilder
    func rowSeparator(insets: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)) -> some View {
        overlay(alignment: .bottomLeading) {
            Rectangle().frame(height: 0.5).opacity(0.25).padding(insets)
        }
    }
}

private struct VocabRowCompactLite: View {
    let v: VocabLite
    var tint: Color = .primary
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(v.word).font(.headline).foregroundStyle(tint)
                Text(v.pinyin).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .frame(minHeight: 52)
        .contentShape(Rectangle())
    }
}

