import SwiftUI
import UIKit
import GoogleSignIn

@MainActor
final class ScoreManager: ObservableObject {
    static let shared = ScoreManager()

    @Published private(set) var entries: [ScoreEntry] = []
    @Published private(set) var totalScore: Int = 0
    @Published private(set) var totalOutOf: Int = 0
    @Published private(set) var todayScore: Int = 0
    @Published private(set) var todayOutOf: Int = 0
    @Published private(set) var currentStreak: Int = 0
    @Published private(set) var bestStreak: Int = 0
    @Published private(set) var todayTarget: Int = 10
    @Published private(set) var hasMetTodayTarget: Bool = false
    @Published var justHitStreakMilestoneID: UUID? = nil

    private var midnightTimer: Timer?
    private var streakState: StreakState = .init()
    private let baseTarget = 10
    private let incrementPerDay = 5

    private var uid: String {
        if let id = GIDSignIn.sharedInstance.currentUser?.userID, !id.isEmpty {
            return "google:\(id)"
        }
        if let email = GIDSignIn.sharedInstance.currentUser?.profile?.email, !email.isEmpty {
            return "email:\(email.lowercased())"
        }
        let key = "anon_uid_v1"
        if let saved = UserDefaults.standard.string(forKey: key) { return saved }
        let fresh = "anon:\(UUID().uuidString)"
        UserDefaults.standard.set(fresh, forKey: key)
        return fresh
    }

    private init() {
        entries = ScoreStorage.load(uid: uid)
        streakState = StreakStorage.load()
        restoreStreakFromStorage()
        recalc()
        scheduleMidnightTick()
        pushLeaderboardSnapshot()
    }

    func record(score: Int, outOf: Int) {
        entries.append(ScoreEntry(timestamp: Date(), score: score, outOf: outOf))
        ScoreStorage.save(uid: uid, entries)
        recalc()
        evaluateStreakProgress()
        pushLeaderboardSnapshot()
    }

    func clearAll() {
        entries = []
        totalScore = 0
        totalOutOf = 0
        todayScore = 0
        todayOutOf = 0
        streakState = StreakState()
        applyStreak(streakState)
        ScoreStorage.clear(uid: uid)
        StreakStorage.clear()
        LeaderboardManager.shared.clearAll()
    }

    func resetStreakAndClearToday() {
        Task { @MainActor in
            clearTodayAttemptsInternal()
            resetStreakStateInternal()
            recalc()
            pushLeaderboardSnapshot()
        }
    }

    func resetStreakToDayOne() {
        Task { @MainActor in
            resetStreakStateInternal()
            recalc()
            pushLeaderboardSnapshot()
        }
    }

    func clearTodayAttempts() {
        Task { @MainActor in
            clearTodayAttemptsInternal()
            recalc()
        }
    }

    private func recalc() {
        totalScore = entries.reduce(0) { $0 + $1.score }
        totalOutOf = entries.reduce(0) { $0 + $1.outOf }
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end = cal.date(byAdding: .day, value: 1, to: start)!
        let todays = entries.filter { $0.timestamp >= start && $0.timestamp < end }
        todayScore = todays.reduce(0) { $0 + $1.score }
        todayOutOf = todays.reduce(0) { $0 + $1.outOf }
        hasMetTodayTarget = (streakState.lastSuccessDay == start)
    }

    private func evaluateStreakProgress() {
        let cal = Calendar.current
        let todayStart = cal.startOfDay(for: Date())
        let yesterdayStart = cal.date(byAdding: .day, value: -1, to: todayStart)!
        if streakState.lastSuccessDay == todayStart {
            hasMetTodayTarget = true
            return
        }
        let targetForToday = baseTarget + (streakState.current * incrementPerDay)
        guard todayScore >= targetForToday else {
            hasMetTodayTarget = false
            return
        }
        if streakState.lastSuccessDay == yesterdayStart {
            streakState.current += 1
        } else {
            streakState.current = 1
        }
        streakState.best = max(streakState.best, streakState.current)
        streakState.lastSuccessDay = todayStart
        StreakStorage.save(streakState)
        applyStreak(streakState)
        hasMetTodayTarget = true
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.success)
        justHitStreakMilestoneID = UUID()
    }

    private func handleMidnightRollover() {
        let cal = Calendar.current
        let todayStart = cal.startOfDay(for: Date())
        let yesterdayStart = cal.date(byAdding: .day, value: -1, to: todayStart)!
        if streakState.lastSuccessDay != yesterdayStart {
            streakState.current = 0
        }
        StreakStorage.save(streakState)
        applyStreak(streakState)
        recalc()
        pushLeaderboardSnapshot()
    }

    private func applyStreak(_ s: StreakState) {
        currentStreak = s.current
        bestStreak = s.best
        todayTarget = baseTarget + (s.current * incrementPerDay)
        hasMetTodayTarget = (s.lastSuccessDay == Calendar.current.startOfDay(for: Date()))
    }

    private func restoreStreakFromStorage() {
        let cal = Calendar.current
        let todayStart = cal.startOfDay(for: Date())
        let yesterdayStart = cal.date(byAdding: .day, value: -1, to: todayStart)!
        if streakState.lastSuccessDay != todayStart && streakState.lastSuccessDay != yesterdayStart {
            streakState.current = 0
        }
        applyStreak(streakState)
    }

    private func scheduleMidnightTick() {
        midnightTimer?.invalidate()
        let cal = Calendar.current
        let startTomorrow = cal.startOfDay(for: cal.date(byAdding: .day, value: 1, to: Date())!)
        let interval = startTomorrow.timeIntervalSinceNow
        midnightTimer = Timer.scheduledTimer(withTimeInterval: max(1, interval), repeats: false) { [weak self] _ in
            Task { [weak self] in
                self?.handleMidnightRollover()
                self?.scheduleMidnightTick()
            }
        }
    }

    private func pushLeaderboardSnapshot() {
        let profile = ProfileManager.shared.profile
        let username = profile?.username.trimmingCharacters(in: .whitespacesAndNewlines)
        let name = (username?.isEmpty == false) ? username! : "Anonymous"
        var avatarData: Data? = nil
        if let img = ProfileManager.shared.avatarImage {
            let size = CGSize(width: 120, height: 120)
            let renderer = UIGraphicsImageRenderer(size: size)
            let thumb = renderer.image { _ in img.draw(in: CGRect(origin: .zero, size: size)) }
            avatarData = thumb.jpegData(compressionQuality: 0.7)
        }
        let entry = LeaderboardEntry(
            username: name,
            streak: currentStreak,
            updatedAt: Date(),
            favoriteAnimal: profile?.favoriteAnimal,
            favoriteColor: profile?.favoriteColor,
            country: profile?.country,
            school: profile?.school,
            bioLine: profile?.bioLine,
            ageDescription: (profile?.age).map { String($0) },
            avatarJPEGData: avatarData
        )
        LeaderboardManager.shared.update(entry: entry)
    }

    enum TrendRange: String, CaseIterable, Identifiable { case daily, weekly, monthly; var id: String { rawValue } }

    struct ScoreBucket: Identifiable, Hashable {
        var id: Date
        var label: String
        var score: Int
        var outOf: Int
        var percent: Double { outOf > 0 ? Double(score) / Double(outOf) * 100 : 0 }
    }

    func buckets(range: TrendRange) -> [ScoreBucket] {
        switch range {
        case .daily:   return bucketsDaily(days: 14)
        case .weekly:  return bucketsWeekly(weeks: 12)
        case .monthly: return bucketsMonthly(months: 12)
        }
    }

    private func bucketsDaily(days: Int) -> [ScoreBucket] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        var result: [ScoreBucket] = []
        for i in stride(from: days - 1, through: 0, by: -1) {
            let day = cal.date(byAdding: .day, value: -i, to: today)!
            let next = cal.date(byAdding: .day, value: 1, to: day)!
            let list = entries.filter { $0.timestamp >= day && $0.timestamp < next }
            result.append(.init(id: day,
                                label: DateFormatter.shortDay.string(from: day),
                                score: list.reduce(0){$0+$1.score},
                                outOf: list.reduce(0){$0+$1.outOf}))
        }
        return result
    }

    private func bucketsWeekly(weeks: Int) -> [ScoreBucket] {
        let cal = Calendar.current
        let startThisWeek = cal.dateInterval(of: .weekOfYear, for: Date())!.start
        var result: [ScoreBucket] = []
        for i in stride(from: weeks - 1, through: 0, by: -1) {
            let start = cal.date(byAdding: .weekOfYear, value: -i, to: startThisWeek)!
            let end   = cal.date(byAdding: .weekOfYear, value: 1, to: start)!
            let list = entries.filter { $0.timestamp >= start && $0.timestamp < end }
            result.append(.init(id: start,
                                label: weekLabel(from: start),
                                score: list.reduce(0){$0+$1.score},
                                outOf: list.reduce(0){$0+$1.outOf}))
        }
        return result
    }

    private func bucketsMonthly(months: Int) -> [ScoreBucket] {
        let cal = Calendar.current
        let startThisMonth = cal.dateInterval(of: .month, for: Date())!.start
        var result: [ScoreBucket] = []
        for i in stride(from: months - 1, through: 0, by: -1) {
            let start = cal.date(byAdding: .month, value: -i, to: startThisMonth)!
            let end   = cal.date(byAdding: .month, value: 1, to: start)!
            let list = entries.filter { $0.timestamp >= start && $0.timestamp < end }
            result.append(.init(id: start,
                                label: DateFormatter.shortMonth.string(from: start),
                                score: list.reduce(0){$0+$1.score},
                                outOf: list.reduce(0){$0+$1.outOf}))
        }
        return result
    }

    private func weekLabel(from start: Date) -> String {
        let end = Calendar.current.date(byAdding: .day, value: 6, to: start)!
        return "\(DateFormatter.mmmdd.string(from: start))–\(DateFormatter.mmmdd.string(from: end))"
    }

    var averagePercent: Double {
        guard totalOutOf > 0 else { return 0 }
        return Double(totalScore) / Double(totalOutOf) * 100.0
    }

    private func resetStreakStateInternal() {
        streakState.current = 0
        streakState.lastSuccessDay = nil
        StreakStorage.save(streakState)
        applyStreak(streakState)
        hasMetTodayTarget = false
        justHitStreakMilestoneID = nil
    }

    private func clearTodayAttemptsInternal() {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end   = cal.date(byAdding: .day, value: 1, to: start)!
        entries.removeAll { $0.timestamp >= start && $0.timestamp < end }
        ScoreStorage.save(uid: uid, entries)
    }
}

private extension DateFormatter {
    static let shortDay: DateFormatter = { let f = DateFormatter(); f.setLocalizedDateFormatFromTemplate("EE");  return f }()
    static let shortMonth: DateFormatter = { let f = DateFormatter(); f.setLocalizedDateFormatFromTemplate("MMM"); return f }()
    static let mmmdd: DateFormatter = { let f = DateFormatter(); f.setLocalizedDateFormatFromTemplate("MMM d"); return f }()
}

