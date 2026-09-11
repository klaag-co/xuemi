//
//  NotesView.swift
//  Xuemi
//
//  Created by Tristan Chay on 13/6/26.
//

import SwiftUI

struct NotesView: View {
    
    @Namespace private var namespace
    
    @State private var searchText = ""
    @State private var showingNewNoteView = false
    
    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return notesManager.notes
        } else {
            return notesManager.notes.filter({ $0.title.localizedCaseInsensitiveContains(searchText) })
        }
    }
    @State private var notesManager: NotesManager
    init(authManager: AuthManager) {
        _notesManager = State(initialValue: NotesManager(authManager: authManager))
    }
    
    var body: some View {
        NavigationStack {
            List {
                if !searchText.isEmpty && filteredNotes.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else if !filteredNotes.isEmpty {
                    ForEach(Note.NoteType.allCases, id: \.hashValue) { noteType in
                        Section(noteType.rawValue) {
                            ForEach(filteredNotes.filter { $0.type == noteType }, id: \.id) { note in
                                if let index = notesManager.notes.firstIndex(where: { $0.id == note.id }) {
                                    NavigationLink {
                                        NotesDetailView(note: notesManager.notes[index])
                                            .environment(notesManager)
                                    } label: {
                                        VStack(alignment: .leading) {
                                            Text(notesManager.notes[index].title)
                                                .font(.headline)
                                            
                                            Text(notesManager.notes[index].description)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                                .lineLimit(2)
                                        }
                                    }
                                }
                            }
                            .onDelete { indexSet in
                                let ids = indexSet.map { filteredNotes.filter { $0.type == noteType }[$0].id }
                                notesManager.removeNote(forIds: ids)
                            }
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "No Notes",
                        systemImage: "note.text",
                        description: Text("Create a new note by pressing the + button.")
                    )
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("New Note", systemImage: "plus") {
                        showingNewNoteView.toggle()
                    }
                    .matchedTransitionSource(id: "addButton", in: namespace)
                }
            }
            .refreshable {
                notesManager.load()
            }
            .sheet(isPresented: $showingNewNoteView) {
                NewNoteView()
                    .presentationDetents([.medium, .large])
                    .presentationContentInteraction(.resizes)
                    .environment(notesManager)
                    .navigationTransition(.zoom(sourceID: "addButton", in: namespace))
            }
        }
    }
}

#Preview {
    @Previewable @State var authManager = AuthManager()
    NotesView(authManager: authManager)
}
