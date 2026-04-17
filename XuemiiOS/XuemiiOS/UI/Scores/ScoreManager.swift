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

// MARK: - Ranges & Buckets

public enum ScoreRange: String, CaseIterable, Identifiable {
    case day = "D"
    case week = "W"
    case month = "M"
    public var id: String { rawValue }
}

public struct ScoreBucket: Identifiable {
    public let id = UUID()
    public let label: String
    public let date: Date
    public let averagePercent: Double
    public let count: Int
}

private extension DateFormatter {
    static let shortDay: DateFormatter = {
        let f = DateFormatter()
        f.setLocalizedDateFormatFromTemplate("EE")
        return f
    }()

    static let shortMonth: DateFormatter = {
        let f = DateFormatter()
        f.setLocalizedDateFormatFromTemplate("MMM")
        return f
    }()

    static let mmmdd: DateFormatter = {
        let f = DateFormatter()
        f.setLocalizedDateFormatFromTemplate("MMM d")
        return f
    }()
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

// MARK: - Manager

public class ScoreManager: ObservableObject {
    public static let shared = ScoreManager()

    @Published public private(set) var results: [QuizResult] = [] {
        didSet {
            self.save()
        }
    }
    @Published var totalScore: Int = 0
    @Published var totalOutOf: Int = 0
    @Published var todayScore: Int = 0
    @Published var todayOutOf: Int = 0

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
    }

    // MARK: - Record

    public func record(correct: Int, total: Int, at date: Date = Date()) {
        let new = QuizResult(date: date, correct: correct, total: total)
        results.append(new)
        results.sort { $0.date > $1.date }
        //results.insert(new, at: 0)
    }
    
    public func clearAll() {
        results = []
        
        totalScore = 0
        totalOutOf = 0
        todayScore = 0
        todayOutOf = 0
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


    public enum TrendRange: String, CaseIterable, Identifiable {
        case daily, weekly, monthly
        public var id: String { rawValue }
    }

    
    public func buckets(range: TrendRange, now: Date = Date()) -> [ScoreBucket] {
        switch range {
        case .daily:   return bucketsDaily(now: now)
        case .weekly:  return bucketsWeekly(now: now)
        case .monthly: return bucketsMonthly(now: now)
        }
    }

    private func bucketsDaily(now: Date) -> [ScoreBucket] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: now)

        return (0..<14).reversed().map { offset in
            let day = cal.date(byAdding: .day, value: -offset, to: today)!
            let next = cal.date(byAdding: .day, value: 1, to: day)!

            let arr = results.filter { $0.date >= day && $0.date < next }

            return ScoreBucket(
                label: DateFormatter.shortDay.string(from: day),
                date: day,
                averagePercent: average(arr),
                count: arr.count
            )
        }
    }

    private func bucketsWeekly(now: Date) -> [ScoreBucket] {
        let cal = Calendar.current
        let startOfWeek = cal.dateInterval(of: .weekOfYear, for: now)!.start

        return (0..<12).reversed().map { offset in
            let start = cal.date(byAdding: .weekOfYear, value: -offset, to: startOfWeek)!
            let end = cal.date(byAdding: .day, value: 7, to: start)!

            let arr = results.filter { $0.date >= start && $0.date < end }

            return ScoreBucket(
                label: weekLabel(from: start),
                date: start,
                averagePercent: average(arr),
                count: arr.count
            )
        }
    }

    private func bucketsMonthly(now: Date) -> [ScoreBucket] {
        let cal = Calendar.current
        let startOfMonth = cal.dateInterval(of: .month, for: now)!.start

        return (0..<12).reversed().map { offset in
            let start = cal.date(byAdding: .month, value: -offset, to: startOfMonth)!
            let end = cal.date(byAdding: .month, value: 1, to: start)!

            let arr = results.filter { $0.date >= start && $0.date < end }

            return ScoreBucket(
                label: DateFormatter.shortMonth.string(from: start),
                date: start,
                averagePercent: average(arr),
                count: arr.count
            )
        }
    }

    public func averagePercent(_ arr: [QuizResult]) -> Double {
        guard !arr.isEmpty else { return 0 }
        let s = arr.reduce(0.0) { $0 + $1.percent }
        return s / Double(arr.count)
    }
    
    public var averagePercent: Double {
        guard !results.isEmpty else { return 0 }
        return results.reduce(0.0) { $0 + $1.percent } / Double(results.count)
    }

    private func average(_ arr: [QuizResult]) -> Double {
        guard !arr.isEmpty else { return 0 }
        return arr.reduce(0) { $0 + $1.percent } / Double(arr.count)
    }

    private func weekLabel(from start: Date) -> String {
        let end = Calendar.current.date(byAdding: .day, value: 6, to: start)!
        return "\(DateFormatter.mmmdd.string(from: start))–\(DateFormatter.mmmdd.string(from: end))"
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
                  let scores = try? JSONDecoder().decode([QuizResult].self, from: scoresData)
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

