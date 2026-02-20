//
//  CreateNoteView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 30/5/24.
//

import SwiftUI

struct CreateNoteView: View {
    @State private var newTitle: String = ""
    @State private var newContent: String = ""
    @State var newNoteType: NoteType = .note
    
    @ObservedObject var notesManager: NotesManager = .shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $newTitle)
                Picker("Note Type", selection: $newNoteType) {
                    ForEach(NoteType.allCases, id: \.hashValue) { noteType in
                        Text(noteType.string)
                            .tag(noteType)
                    }
                }
                TextField("Type something...", text: $newContent, axis: .vertical)
            }
            .navigationTitle("New Note")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        notesManager.notes.append(
                            Note(title: newTitle, noteType: newNoteType, content: newContent)
                        )
                        dismiss()
                    }
                }
            }
        }
    }
}

