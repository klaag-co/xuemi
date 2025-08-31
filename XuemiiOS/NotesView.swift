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
    
    private var filteredNotes: [Note] {
        if searchText.isEmpty {
            return notesManager.notes
        } else {
            return notesManager.notes.filter { $0.title.uppercased().contains(searchText.uppercased()) }
        }
    }

    var body: some View {
        NavigationStack {
            List {
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
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                
                ToolbarItem(placement: .topBarTrailing) {
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
    NotesView()
}
