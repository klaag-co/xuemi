//
//  NotesManager.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 14/6/26.
//

import SwiftUI
import FirebaseFirestore

@Observable
class NotesManager {
    private(set) var notes: [Note]
    private var authManager: AuthManager
    
    init(authManager: AuthManager) {
        self.authManager = authManager
        self.notes = []
        
        load()
    }
    
    func load() {
        guard let uid = authManager.uid else { return }
        var notes: [Note] = []
        
        Task {
            do {
                let snapshot = try await Firestore.firestore().collection("users").document(uid).collection("notes").order(by: "dateCreated", descending: true).getDocuments()
                if !snapshot.isEmpty {
                    snapshot.documents.forEach { document in
                        let title = document.data()["title"] as? String
                        let description = document.data()["description"] as? String
                        let noteTypeString = document.data()["noteType"] as? String
                        let noteType = Note.NoteType(rawValue: noteTypeString ?? "")
                        
                        if let title, let description, let noteType {
                                notes.append(
                                    Note(
                                        id: document.documentID,
                                        title: title,
                                        description: description,
                                        type: noteType
                                    )
                                )
                        }
                    }
                }
                withAnimation {
                    self.notes = notes
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func addNote(title: String, description: String, type: Note.NoteType) async {
        guard let uid = authManager.uid else { return }
        do {
            try await Firestore.firestore().collection("users").document(uid).collection("notes").addDocument(data: [
                "dateCreated" : Date(),
                "title" : title,
                "description" : description,
                "noteType": type.rawValue
            ])
            load()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateNote(note: Note) async {
        guard let uid = authManager.uid else { return }
        do {
            try await Firestore.firestore().collection("users").document(uid).collection("notes").document(note.id).updateData([
                "title" : note.title,
                "description" : note.description,
                "noteType" : note.type.rawValue,
            ])
            load()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func removeNote(forIds ids: [String]) {
        guard let uid = authManager.uid else { return }

        ids.forEach { id in
            Task {
                do {
                    try await Firestore.firestore().collection("users").document(uid).collection("notes").document(id).delete()
                    withAnimation {
                        notes.removeAll { ids.contains($0.id) }
                    }
                    load()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
