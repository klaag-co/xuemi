import SwiftUI

struct ScoreChip: View {
    @EnvironmentObject private var scores: ScoreManager
    @State private var showDetail = false

    var body: some View {
        Button { showDetail = true } label: {
            HStack(spacing: 6) {
                Text("\(scores.todayScore)").font(.headline).fontWeight(.semibold)
                Text("/\(scores.todayOutOf)").font(.subheadline).foregroundColor(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDetail) { ScoresDetailView() }
    }
}

