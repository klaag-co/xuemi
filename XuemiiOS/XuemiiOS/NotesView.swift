//
//  NotesView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 30/5/24.
//

import SwiftUI

struct NotesView: View {
    @State private var searchText = ""
    @State private var isCreateNoteViewPresented = false
    @ObservedObject var notesManager: NotesManager = .shared
    @Binding var note: Note
    
    private var filteredNotes: [Note] {
        if searchText.isEmpty {
            return notesManager.notes
        } else {
            return notesManager.notes.filter { $0.title.contains(searchText) }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Exam")) {
                    ForEach(filteredNotes.filter { $0.noteType == .exam }, id: \.id) { note in
                        NavigationLink(destination: NotesDetailView(note: .constant(note))) {
                            Text(note.title)
                        }
                    }
                    .onDelete { indexSet in
                        let idsToDelete = indexSet.map { filteredNotes.filter { $0.noteType == .exam }[$0].id }
                        notesManager.notes.removeAll { idsToDelete.contains($0.id) }
                    }
                }
                
                Section(header: Text("Notes")) {
                    ForEach(filteredNotes.filter { $0.noteType == .note }, id: \.id) { note in
                        NavigationLink(destination: NotesDetailView(note: .constant(note))) {
                            Text(note.title)
                        }
                    }
                    .onDelete { indexSet in
                        let idsToDelete = indexSet.map { filteredNotes.filter { $0.noteType == .note }[$0].id }
                        notesManager.notes.removeAll { idsToDelete.contains($0.id) }
                    }
                }
            }
            .navigationTitle("Notepad")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isCreateNoteViewPresented.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isCreateNoteViewPresented) {
                CreateNoteView()
            }
        }
    }
}

#Preview {
    NotesView(note: .constant(Note(
        id: UUID(),
        title: "Sample Note",
        content: "This is a sample note.",
        noteType: .note
    )))
}
