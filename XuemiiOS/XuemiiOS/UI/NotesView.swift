//
//  NotesView.swift
//  XuemiiOS
//

import SwiftUI

struct NotesView: View {
    @State private var searchText = ""
    @State private var isCreateNoteViewPresented = false

    // Creation chooser
    @State private var showAddMenu = false
    @State private var createdInkNote: InkNote? = nil   // navigate to editor after creating

    // ✅ Use the global navigation stack so Result screens can mutate it
    @ObservedObject private var pathManager = PathManager.global

    @ObservedObject var notesManager: NotesManager = .shared
    @ObservedObject private var inkManager = InkNotesManager.shared

    // Results managers
    @ObservedObject private var scoreManager = ScoreManager.shared
    @ObservedObject private var memoryStats = MemoryStats.shared

    // MARK: - Filtering (typed + ink)
    private var filteredNotes: [Note] {
        if searchText.isEmpty {
            return notesManager.notes
        } else {
            return notesManager.notes.filter { $0.title.uppercased().contains(searchText.uppercased()) }
        }
    }

    private var filteredInkNotes: [InkNote] {
        if searchText.isEmpty {
            return inkManager.notes
        } else {
            return inkManager.notes.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }

    // MARK: - Helpers (map level to sections)
    private func levelMatches(_ levelRaw: Int?, sec: NoteType) -> Bool {
        guard let lv = levelRaw else { return false }
        switch sec {
        case .sone:   return lv == SecondaryNumber.one.rawValue
        case .stwo:   return lv == SecondaryNumber.two.rawValue
        case .sthree: return lv == SecondaryNumber.three.rawValue
        case .sfour:  return lv == SecondaryNumber.four.rawValue
        default:      return false
        }
    }

    private func mcqFor(sec: NoteType) -> [QuizResult] {
        scoreManager.results
            .filter { levelMatches($0.levelRaw, sec: sec) }
            .sorted { $0.date > $1.date }
    }

    private func memoryFor(sec: NoteType) -> [MemoryAttempt] {
        memoryStats.attempts
            .filter { levelMatches($0.levelRaw, sec: sec) }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        // ✅ Bind to the global path
        NavigationStack {
            List {
                // ===== Ink Notes =====
                if !filteredInkNotes.isEmpty || UIDevice.current.userInterfaceIdiom == .pad {
                    Section(header: Text("Ink Notes")) {
                        ForEach(filteredInkNotes) { ink in
                            NavigationLink(destination: InkNoteDetailView(note: ink)) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(ink.title).font(.headline)
                                    Text(ink.updatedAt.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            let ids = indexSet.map { filteredInkNotes[$0].id }
                            ids.forEach { id in
                                if let item = inkManager.notes.first(where: { $0.id == id }) {
                                    inkManager.delete(item)
                                }
                            }
                        }
                    }
                }

                // ===== Typed notes (global categories) =====
                Section(header: Text("Exam")) {
                    ForEach(filteredNotes.filter { $0.noteType == .exam }, id: \.id) { note in
                        if let index = notesManager.notes.firstIndex(where: { $0.id == note.id }) {
                            NavigationLink(destination: NotesDetailView(note: $notesManager.notes[index])) {
                                Text(note.title)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        let idsToDelete = indexSet.map { filteredNotes.filter { $0.noteType == .exam }[$0].id }
                        notesManager.notes.removeAll { idsToDelete.contains($0.id) }
                    }
                }

                Section(header: Text("Notes")) {
                    ForEach(filteredNotes.filter { $0.noteType == .note }, id: \.id) { note in
                        if let index = notesManager.notes.firstIndex(where: { $0.id == note.id }) {
                            NavigationLink(destination: NotesDetailView(note: $notesManager.notes[index])) {
                                Text(note.title)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        let idsToDelete = indexSet.map { filteredNotes.filter { $0.noteType == .note }[$0].id }
                        notesManager.notes.removeAll { idsToDelete.contains($0.id) }
                    }
                }

                // ===== Secondary 1..4 with MCQ & Memory results embedded =====
                secondarySection(title: "Secondary 1", type: .sone)
                secondarySection(title: "Secondary 2", type: .stwo)
                secondarySection(title: "Secondary 3", type: .sthree)
                secondarySection(title: "Secondary 4", type: .sfour)
            }
            .navigationTitle("Notepad")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { EditButton() }

                // "+" offers Typed or Ink
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAddMenu = true } label: { Image(systemName: "plus") }
                }
            }
            .confirmationDialog("New Note", isPresented: $showAddMenu, titleVisibility: .visible) {
                Button("New Typed Note") { isCreateNoteViewPresented = true }
                Button("New Ink Note") {
                    let new = inkManager.add(title: "Untitled")
                    createdInkNote = new
                }
                Button("Cancel", role: .cancel) { }
            }
            .sheet(isPresented: $isCreateNoteViewPresented) {
                CreateNoteView()
            }
            // Navigate to Ink editor after creating one
            .navigationDestination(item: $createdInkNote) { note in
                InkNoteDetailView(note: note)
            }

            // ✅ Only need the two routes from here
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .replay(let quiz):
                    ResultReplayDestination(quiz: quiz)
                case .replayMemory(let attempt):
                    MemoryReplayDestination(attempt: attempt)
                default:
                    EmptyView() // other routes are handled elsewhere
                }
            }
        }
    }

    // MARK: - Secondary section builder

    @ViewBuilder
    private func secondarySection(title: String, type: NoteType) -> some View {
        Section(header: Text(title)) {
            // Original typed notes for that Secondary group
            ForEach(filteredNotes.filter { $0.noteType == type }, id: \.id) { note in
                if let index = notesManager.notes.firstIndex(where: { $0.id == note.id }) {
                    NavigationLink(destination: NotesDetailView(note: $notesManager.notes[index])) {
                        Text(note.title)
                    }
                }
            }
            .onDelete { indexSet in
                let idsToDelete = indexSet.map { filteredNotes.filter { $0.noteType == type }[$0].id }
                notesManager.notes.removeAll { idsToDelete.contains($0.id) }
            }

            // MCQ Results (tap -> ResultReplayDestination via typed route)
            let mcq = mcqFor(sec: type)
            if !mcq.isEmpty {
                LabeledContent { EmptyView() } label: {
                    Text("MCQ Results").font(.caption).foregroundStyle(.secondary)
                }
                ForEach(mcq.prefix(50)) { r in
                    NavigationLink(value: Route.replay(r)) {
                        RecentRowMCQ(quiz: r)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            withAnimation { ScoreManager.shared.delete(r) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }

            // Memory Results (tap -> MemoryReplayDestination via typed route)
            let mem = memoryFor(sec: type)
            if !mem.isEmpty {
                LabeledContent { EmptyView() } label: {
                    Text("Memory Results").font(.caption).foregroundStyle(.secondary)
                }
                ForEach(mem.prefix(50)) { a in
                    NavigationLink(value: Route.replayMemory(a)) {
                        RecentRowMemory(attempt: a)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            withAnimation { MemoryStats.shared.delete(a) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Reused rows (same look as before)

private struct RecentRowMCQ: View {
    let quiz: QuizResult
    private static let mdFormatter: DateFormatter = { let f = DateFormatter(); f.dateFormat = "M/d"; return f }()
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(quiz.contextTitle.isEmpty ? "Practice" : quiz.contextTitle)
                    .font(.subheadline).lineLimit(1)
                Text(quiz.date, formatter: Self.mdFormatter)
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(Int(round(quiz.percent)))%").font(.headline)
        }
        .padding(.vertical, 6)
    }
}

private struct RecentRowMemory: View {
    let attempt: MemoryAttempt
    private static let mdFormatter: DateFormatter = { let f = DateFormatter(); f.dateFormat = "M/d"; return f }()
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(attempt.contextTitle.isEmpty ? "Practice" : attempt.contextTitle)
                    .font(.subheadline).lineLimit(1)
                Text(attempt.date, formatter: Self.mdFormatter)
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(attempt.tries) tries").font(.headline)
        }
        .padding(.vertical, 6)
    }
}

// Preview
#Preview { NotesView() }

