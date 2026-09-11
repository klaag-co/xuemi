//
//  NewNoteView.swift
//  Xuemi
//
//  Created by Tristan Chay on 15/6/26.
//

import SwiftUI

struct NewNoteView: View {
    
    @State private var isLoading = false
    
    @State private var title = ""
    @State private var description = ""
    @State private var noteType: Note.NoteType = .note
    
    @Environment(\.dismiss) private var dismiss
    @Environment(NotesManager.self) private var notesManager
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Title", text: $title)
                    Picker("Note Type", selection: $noteType) {
                        ForEach(Note.NoteType.allCases, id: \.hashValue) { noteType in
                            Text(noteType.rawValue)
                                .tag(noteType)
                        }
                    }
                }
                
                Section {
                    TextField("Description", text: $description, axis: .vertical)
                }
            }
            .navigationTitle("New Note")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    saveButton
                }
            }
        }
    }
    
    var saveButton: some View {
        Group {
            if #available(iOS 26.0, *) {
                Button {
                    save()
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
                    save()
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
        .disabled(title.isEmpty || description.isEmpty)
    }
    
    func save() {
        if !title.isEmpty && !description.isEmpty {
            Task {
                isLoading = true
                await notesManager.addNote(title: title, description: description, type: noteType)
                isLoading = false
                dismiss()
            }
        }
    }
}
