import SwiftUI

struct ScoresDetailView: View {
    @EnvironmentObject private var scores: ScoreManager
    @State private var showTrends = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Total").font(.headline)
                            Text(String(format: "%.0f%%", scores.averagePercent))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("\(scores.totalScore) / \(scores.totalOutOf)")
                            .font(.title3).fontWeight(.semibold)
                    }
                }
                Section("Attempts") {
                    ForEach(scores.entries.sorted(by: { $0.timestamp > $1.timestamp })) { e in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(e.score) / \(e.outOf)")
                                    .font(.body).fontWeight(.medium)
                                Text(e.timestamp.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            let pct = e.outOf > 0 ? Int(Double(e.score) / Double(e.outOf) * 100) : 0
                            Text("\(pct)%").foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("My Marks")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button { showTrends = true } label: { Image(systemName: "chart.bar") }
                    Menu {
                        Button(role: .destructive) { scores.clearAll() } label: {
                            Label("Clear All", systemImage: "trash")
                        }
                    } label: { Image(systemName: "ellipsis.circle") }
                }
            }
            .sheet(isPresented: $showTrends) {
                ScoresTrendView().environmentObject(scores)
            }
        }
    }
}

