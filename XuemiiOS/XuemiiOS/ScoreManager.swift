import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

// MARK: - Lightweight vocab snapshot (so we can reopen past results)

public struct VocabLite: Identifiable, Codable, Hashable {
    public let id: Int            // original Vocabulary.index
    public let word: String
    public let pinyin: String

    public init(id: Int, word: String, pinyin: String) {
        self.id = id
        self.word = word
        self.pinyin = pinyin
    }
}

// MARK: - Stored quiz result

public struct QuizResult: Identifiable, Codable, Hashable {
    public let id: UUID
    public let date: Date
    public let correct: Int
    public let total: Int

    // For Recent list + deep-link
    public let contextTitle: String          // e.g. "中三 · 第二章 · 家庭"
    public let levelRaw: Int?                // SecondaryNumber.rawValue (optional)
    public let chapterRaw: Int?              // Chapter rawValue if Int-backed (optional)
    public let topicRaw: Int?                // Topic rawValue if Int-backed (optional)
    public let folderName: String?

    // Snapshot to rebuild results view
    public let vocab: [VocabLite]
    public let userAnswers: [String?]

    public var percent: Double {
        guard total > 0 else { return 0 }
        return (Double(correct) / Double(total)) * 100.0
    }

    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        correct: Int,
        total: Int,
        contextTitle: String = "",
        levelRaw: Int? = nil,
        chapterRaw: Int? = nil,
        topicRaw: Int? = nil,
        folderName: String? = nil,
        vocab: [VocabLite] = [],
        userAnswers: [String?] = []
    ) {
        self.id = id
        self.date = date
        self.correct = correct
        self.total = total
        self.contextTitle = contextTitle
        self.levelRaw = levelRaw
        self.chapterRaw = chapterRaw
        self.topicRaw = topicRaw
        self.folderName = folderName
        self.vocab = vocab
        self.userAnswers = userAnswers
    }

    // Hashable & Equatable via id only (stable for NavigationLink)
    public static func == (lhs: QuizResult, rhs: QuizResult) -> Bool { lhs.id == rhs.id }
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Ranges & Buckets

public enum ScoreRange: String, CaseIterable, Identifiable {
    case day = "D"
    case week = "W"
    case month = "M"
    public var id: String { rawValue }
}

public struct ScoreBucket: Identifiable {
    public let id = UUID()
    public let label: String      // "1PM", "Mon"
    public let date: Date         // bucket start
    public let averagePercent: Double
}

// MARK: - Manager

public final class ScoreManager: ObservableObject {
    public static let shared = ScoreManager()

    @Published public private(set) var results: [QuizResult] = []

    private let storeKey = "quiz_results_v2"
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Current user document id (uid preferred, else email)
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
        $results
            .sink { [weak self] _ in self?.save() }
            .store(in: &cancellables)
    }

    // MARK: - Record

    public func record(correct: Int, total: Int, at date: Date = Date()) {
        let new = QuizResult(date: date, correct: correct, total: total)
        results.append(new)
        results.sort { $0.date > $1.date }
    }

    public func recordSnapshot(
        correct: Int,
        total: Int,
        contextTitle: String,
        levelRaw: Int?,
        chapterRaw: Int?,
        topicRaw: Int?,
        folderName: String?,
        vocab: [VocabLite],
        userAnswers: [String?],
        at date: Date = Date()
    ) {
        let new = QuizResult(
            date: date,
            correct: correct,
            total: total,
            contextTitle: contextTitle,
            levelRaw: levelRaw,
            chapterRaw: chapterRaw,
            topicRaw: topicRaw,
            folderName: folderName,
            vocab: vocab,
            userAnswers: userAnswers
        )
        results.append(new)
        results.sort { $0.date > $1.date }
    }

    // MARK: - Delete

    public func delete(_ result: QuizResult) {
        results.removeAll { $0.id == result.id }
    }

    public func delete(ids: [UUID]) {
        let set = Set(ids)
        results.removeAll { set.contains($0.id) }
    }

    // MARK: - Bucketing (D / W / M) — kept for possible reuse elsewhere

    public func buckets(for range: ScoreRange, now: Date = Date()) -> [ScoreBucket] {
        switch range {
        case .day:   return bucketsForDay(now: now)   // 24 hours
        case .week:  return bucketsForWeek(now: now)  // Mon–Sun
        case .month: return bucketsForMonthAvg(now: now) // Avg% per calendar day
        }
    }

    private func bucketsForDay(now: Date) -> [ScoreBucket] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: now)
        let end = cal.date(byAdding: .day, value: 1, to: start)!
        let todays = results.filter { $0.date >= start && $0.date < end }

        var map: [Int: [QuizResult]] = [:]
        for r in todays {
            let hour = cal.component(.hour, from: r.date)
            map[hour, default: []].append(r)
        }

        return (0..<24).map { hour in
            let bucketDate = cal.date(byAdding: .hour, value: hour, to: start)!
            let f = DateFormatter(); f.dateFormat = "ha"
            let label = f.string(from: bucketDate)
            let arr = map[hour] ?? []
            return ScoreBucket(label: label, date: bucketDate, averagePercent: averagePercent(arr))
        }
    }

    private func bucketsForWeek(now: Date) -> [ScoreBucket] {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: now) // 1=Sun … 7=Sat
        let daysFromMonday = (weekday + 5) % 7
        let monday = cal.date(byAdding: .day, value: -daysFromMonday, to: cal.startOfDay(for: now))!

        var out: [ScoreBucket] = []
        let f = DateFormatter(); f.dateFormat = "EEE"
        for i in 0..<7 {
            let day = cal.date(byAdding: .day, value: i, to: monday)!
            let next = cal.date(byAdding: .day, value: 1, to: day)!
            let arr = results.filter { $0.date >= day && $0.date < next }
            out.append(ScoreBucket(label: f.string(from: day), date: day, averagePercent: averagePercent(arr)))
        }
        return out
    }

    private func bucketsForMonthAvg(now: Date) -> [ScoreBucket] {
        let cal = Calendar.current
        let start = cal.date(from: cal.dateComponents([.year, .month], from: now))!
        let range = cal.range(of: .day, in: .month, for: start)! // 1..30/31

        var out: [ScoreBucket] = []
        for d in range {
            let day = cal.date(byAdding: .day, value: d - 1, to: start)!
            let next = cal.date(byAdding: .day, value: 1, to: day)!
            let arr = results.filter { $0.date >= day && $0.date < next }
            out.append(ScoreBucket(label: "\(d)", date: day, averagePercent: averagePercent(arr)))
        }
        return out
    }

    private func averagePercent(_ arr: [QuizResult]) -> Double {
        guard !arr.isEmpty else { return 0 }
        let s = arr.reduce(0.0) { $0 + $1.percent }
        return s / Double(arr.count)
    }

    // MARK: - Persistence

    private func load() {
        Task {
            let remoteLoaded = await getScoresFromFirebase()
            guard !remoteLoaded else { return /* alr loaded */ }
            guard let data = UserDefaults.standard.data(forKey: storeKey) else { return }
            if let decoded = try? JSONDecoder().decode([QuizResult].self, from: data) {
                self.results = decoded
            }
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(results) {
            UserDefaults.standard.set(data, forKey: storeKey)
            Task { await updateScoresOnFirebase(newScoresData: data) }
        }
    }

    private func getScoresFromFirebase() async -> Bool {
        guard let uid = userDocId else { return false }
        do {
            let userDoc = try await Firestore.firestore()
                .collection("users").document(uid)
                .getDocument()

            guard let data = userDoc.data(),
                  let notesDataString = data["scores"] as? String
            else {
                print("Could not read scores from firebase")
                return false
            }

            guard let scoresData = Data(base64Encoded: notesDataString),
                  let scores = try? PropertyListDecoder().decode([QuizResult].self, from: scoresData)
            else {
                print("Could not decode scores data")
                return false
            }

            await MainActor.run { self.results = scores }

            return true
        } catch {
            print("Error getting notes: \(error)")
            return false
        }
    }

    private func updateScoresOnFirebase(newScoresData: Data) async {
        guard let uid = userDocId else { return }

        do {
            try await Firestore.firestore()
                .collection("users").document(uid)
                .setData(["scores": newScoresData.base64EncodedString()], merge: true)
            print("Scores updated on firebase")
        } catch {
            print("Error updating scores: \(error)")
        }
    }
}

