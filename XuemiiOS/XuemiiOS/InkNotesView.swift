import SwiftUI

struct InkNotesView: View {
    @ObservedObject private var manager = InkNotesManager.shared
    @State private var search = ""
    @State private var showNew = false
    @State private var newTitle = ""

    private var filtered: [InkNote] {
        search.isEmpty ? manager.notes : manager.notes.filter { $0.title.localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filtered) { note in
                    NavigationLink {
                        InkNoteDetailView(note: note)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(note.title).font(.headline)
                            Text(note.updatedAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: manager.delete)
            }
            .navigationTitle("Ink Notes")
            .searchable(text: $search, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showNew = true } label: { Image(systemName: "plus") }
                }
            }
            .alert("New Ink Note", isPresented: $showNew) {
                TextField("Title", text: $newTitle)
                Button("Create") {
                    let created = manager.add(title: newTitle.isEmpty ? "Untitled" : newTitle)
                    newTitle = ""
                    // push to editor
                    // (NavigationLink handles push when user taps list; we keep UX simple)
                }
                Button("Cancel", role: .cancel) { newTitle = "" }
            }
        }
    }
}

