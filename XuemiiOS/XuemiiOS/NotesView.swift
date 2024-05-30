//
//  NotesView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 30/5/24.
//

import SwiftUI

struct NotesView: View {
    
    @State private var isCreateNoteViewPresented = false
    @ObservedObject var notesManager: NotesManager = .shared
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach($notesManager.notes.filter({$0.noteType.wrappedValue == NoteType.exam}), id: \.id) { $note in
                        NavigationLink {
                            NotesDetailView(note: $note)
                        } label: {
                            Text(note.title)
                        }
                    }
                    .onDelete { indexSet in
                        notesManager.notes.remove(atOffsets: indexSet)
                    }
                } header: {
                    Text("Exam")
                }
                
                Section {
                    ForEach($notesManager.notes.filter({$0.noteType.wrappedValue == NoteType.note}), id: \.id) { $note in
                        NavigationLink {
                            NotesDetailView(note: $note)
                        } label: {
                            Text(note.title)
                        }
                    }
                    .onDelete { indexSet in
                        notesManager.notes.remove(atOffsets: indexSet)
                    }
                } header: {
                    Text("Notes")
                }
            }
            .navigationTitle("Notepad")
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
