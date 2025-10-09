//
//  NotesView.swift
//  XuemiiOS
//

import SwiftUI

struct NotesView: View {
    @State private var searchText = ""
    @State private var isCreateNoteViewPresented = false

    // NEW: creation chooser
    @State private var showAddMenu = false
    @State private var createdInkNote: InkNote? = nil   // navigate to editor after creating

    @ObservedObject var notesManager: NotesManager = .shared
    @ObservedObject private var inkManager = InkNotesManager.shared

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

    var body: some View {
        NavigationStack {
            List {
                // ===== Ink Notes (NEW) =====
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

                // ===== Your existing typed note sections (UNCHANGED) =====
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

                Section(header: Text("Secondary 1")) {
                    ForEach(filteredNotes.filter { $0.noteType == .sone }, id: \.id) { note in
                        if let index = notesManager.notes.firstIndex(where: { $0.id == note.id }) {
                            NavigationLink(destination: NotesDetailView(note: $notesManager.notes[index])) {
                                Text(note.title)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        let idsToDelete = indexSet.map { filteredNotes.filter { $0.noteType == .sone }[$0].id }
                        notesManager.notes.removeAll { idsToDelete.contains($0.id) }
                    }
                }

                Section(header: Text("Secondary 2")) {
                    ForEach(filteredNotes.filter { $0.noteType == .stwo }, id: \.id) { note in
                        if let index = notesManager.notes.firstIndex(where: { $0.id == note.id }) {
                            NavigationLink(destination: NotesDetailView(note: $notesManager.notes[index])) {
                                Text(note.title)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        let idsToDelete = indexSet.map { filteredNotes.filter { $0.noteType == .stwo }[$0].id }
                        notesManager.notes.removeAll { idsToDelete.contains($0.id) }
                    }
                }

                Section(header: Text("Secondary 3")) {
                    ForEach(filteredNotes.filter { $0.noteType == .sthree }, id: \.id) { note in
                        if let index = notesManager.notes.firstIndex(where: { $0.id == note.id }) {
                            NavigationLink(destination: NotesDetailView(note: $notesManager.notes[index])) {
                                Text(note.title)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        let idsToDelete = indexSet.map { filteredNotes.filter { $0.noteType == .sthree }[$0].id }
                        notesManager.notes.removeAll { idsToDelete.contains($0.id) }
                    }
                }

                Section(header: Text("Secondary 4")) {
                    ForEach(filteredNotes.filter { $0.noteType == .sfour }, id: \.id) { note in
                        if let index = notesManager.notes.firstIndex(where: { $0.id == note.id }) {
                            NavigationLink(destination: NotesDetailView(note: $notesManager.notes[index])) {
                                Text(note.title)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        let idsToDelete = indexSet.map { filteredNotes.filter { $0.noteType == .sfour }[$0].id }
                        notesManager.notes.removeAll { idsToDelete.contains($0.id) }
                    }
                }
            }
            .navigationTitle("Notepad")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { EditButton() }

                // "+" now offers two choices: Typed or Ink
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAddMenu = true } label: { Image(systemName: "plus") }
                }
            }
            // action sheet to choose the new note type
            .confirmationDialog("New Note", isPresented: $showAddMenu, titleVisibility: .visible) {
                Button("New Typed Note") { isCreateNoteViewPresented = true }
                Button("New Ink Note") {
                    let new = inkManager.add(title: "Untitled")
                    createdInkNote = new
                }
                Button("Cancel", role: .cancel) { }
            }
            .sheet(isPresented: $isCreateNoteViewPresented) {
                CreateNoteView()   // your existing typed flow
            }
            // Navigate to Ink editor after creating one
            .navigationDestination(item: $createdInkNote) { note in
                InkNoteDetailView(note: note)
            }
        }
    }
}

#Preview { NotesView() }

