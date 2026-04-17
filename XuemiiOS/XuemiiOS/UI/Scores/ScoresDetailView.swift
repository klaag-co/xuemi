import SwiftUI

struct ScoresDetailView: View {
    @EnvironmentObject private var scores: ScoreManager
    @State var range: ScoreManager.TrendRange = .weekly
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
                        Text("\(scores.results.reduce(0) { $0 + $1.correct }) / \(scores.results.reduce(0) { $0 + $1.total })")
                            .font(.title3).fontWeight(.semibold)
                    }
                }

                Section("Attempts") {
                    ForEach(scores.results) { result in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(result.contextTitle.isEmpty ? "Quiz" : result.contextTitle)
                                    .font(.body).fontWeight(.medium)
                                Text(result.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption).foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(String(format: "%.0f%%", result.percent))
                                .foregroundColor(.secondary)
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
                ScoresTrendView(range: range).environmentObject(scores)
            }
        }
    }
}

