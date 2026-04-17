import SwiftUI

struct ScoreBadge: View {
    @EnvironmentObject private var scores: ScoreManager
    @State private var showDetail = false

    var body: some View {
        Button {
            showDetail = true
        } label: {
            VStack(alignment: .trailing, spacing: 4) {
                Text("My Marks").font(.caption).foregroundColor(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(scores.totalScore)")
                        .font(.title2).fontWeight(.semibold)
                    Text("/ \(scores.totalOutOf)")
                        .font(.subheadline).foregroundColor(.secondary)
                }
                Text(String(format: "%.0f%%", scores.averagePercent))
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDetail) { ScoresDetailView() }
    }
}

