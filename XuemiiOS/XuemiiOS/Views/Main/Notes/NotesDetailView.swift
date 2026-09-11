//
//  NotesDetailView.swift
//  Xuemi
//
//  Created by Tristan Chay on 15/6/26.
//

import SwiftUI

struct NotesDetailView: View {
    
    @State var originalTitle: String
    @State var originalDescription: String
    @State var originalNoteType: Note.NoteType
    
    @State private var isLoading = false
    @State private var showingDeleteAlert = false
    
    @State var note: Note
    @Environment(\.dismiss) private var dismiss
    @Environment(NotesManager.self) private var notesManager
    
    init(note: Note) {
        self.originalTitle = note.title
        self.originalDescription = note.description
        self.originalNoteType = note.type
        self.note = note
    }
    
    var body: some View {
        VStack {
            TextField("Title", text: $note.title)
                .font(.title)
                .fontWeight(.bold)
            
            Divider()
            
            ScrollView {
                TextField("Type something...", text: $note.description, axis: .vertical)
            }
        }
        .padding(.horizontal)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Note Type", selection: $note.type) {
                        ForEach(Note.NoteType.allCases, id: \.hashValue) { noteType in
                            Text(noteType.rawValue)
                                .tag(noteType)
                        }
                    }
                    Divider()
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        showingDeleteAlert.toggle()
                    }
                } label: {
                    Label("Note Type", systemImage: "ellipsis")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                updateButton
            }
        }
        .onDisappear {
            updateNote()
        }
        .alert("Delete Note", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                dismiss()
                let id = notesManager.notes.first(where: { $0.id == note.id })!.id
                notesManager.removeNote(forIds: [id])
            }
        } message: {
            Text("Are you sure you want to delete this note? This action cannot be undone.")
        }
    }
    
    var updateButton: some View {
        Group {
            if #available(iOS 26.0, *) {
                Button {
                    updateNote()
                } label: {
                    if !isLoading {
                        Text("Save")
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                    } else {
                        ProgressView()
                    }
                }
                .buttonStyle(.glassProminent)
            } else {
                Button {
                    updateNote()
                } label: {
                    if !isLoading {
                        Text("Save")
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                    } else {
                        ProgressView()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .disabled(note.title.isEmpty || note.description.isEmpty || (note.title == originalTitle && note.description == originalDescription && note.type == originalNoteType))
    }
    
    func updateNote() {
        if !note.title.isEmpty && !note.description.isEmpty && (note.title != originalTitle || note.description != originalDescription || note.type != originalNoteType) {
            Task {
                isLoading = true
                await notesManager.updateNote(note: note)
                isLoading = false
                originalTitle = note.title
                originalDescription = note.description
                originalNoteType = note.type
            }
        }
    }
}

#Preview {
    @Previewable @State var note = Note(id: "123", title: "456", description: "678", type: .note)
    NotesDetailView(note: note)
}
