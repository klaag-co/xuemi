import SwiftUI

struct StreakChip: View {
    @EnvironmentObject private var scores: ScoreManager

    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle().fill(Color.orange.opacity(0.2)).frame(width: 22, height: 22)
                Text("🔥").font(.caption2)
            }
            Text("\(scores.currentStreak)")
                .font(.headline).fontWeight(.semibold)
            Text("day\(scores.currentStreak == 1 ? "" : "s")")
                .font(.subheadline).foregroundColor(.secondary)
            Text("• \(scores.todayScore)/\(scores.todayTarget)")
                .font(.subheadline).foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .accessibilityLabel("Streak \(scores.currentStreak) days. Today \(scores.todayScore) out of \(scores.todayTarget).")
    }
}

