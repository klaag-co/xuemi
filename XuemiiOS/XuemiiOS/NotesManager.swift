//
//  NotesManager.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 30/5/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct Note: Codable, Hashable, Identifiable {
    var id = UUID()
    var title: String
    var content: String
    var noteType: NoteType
}

enum NoteType: Codable, CaseIterable {
    case exam, note, sone, stwo, sthree, sfour
    
    var string: String {
        switch self {
        case .exam:
            return "Exam"
        case .note:
            return "Note"
        case .sone:
            return "Secondary 1"
        case .stwo:
            return "Secondary 2"
        case .sthree:
            return "Secondary 3"
        case .sfour:
            return "Secondary 4"
        }
    }
}

class NotesManager: ObservableObject {
    static let shared: NotesManager = .init()
    
    @Published var notes: [Note] = [] {
        didSet {
            save()
        }
    }

    // MARK: - Current user document id (uid preferred, else email)
    private var userDocId: String? {
        if let uid = Auth.auth().currentUser?.uid { return uid }
        if let email = AuthenticationManager.shared.email?
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return email
        }
        return nil
    }

    init() {
        load()
    }
    
    func getArchiveURL() -> URL {
        let plistName = "notes.plist"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        return documentsDirectory.appendingPathComponent(plistName)
    }
    
    func save() {
        let archiveURL = getArchiveURL()
        let propertyListEncoder = PropertyListEncoder()
        if let encodedNotes = try? propertyListEncoder.encode(notes) {
            try? encodedNotes.write(to: archiveURL, options: .noFileProtection)
            Task { await updateNotesOnFirebase(newNotesData: encodedNotes) }
        }
    }
    
    func load() {
        Task {
            let remoteLoaded = await getNotesFromFirebase()
            guard !remoteLoaded else { return /* alr loaded */ }

            let archiveURL = getArchiveURL()
            let propertyListDecoder = PropertyListDecoder()

            if let retrievedNoteData = try? Data(contentsOf: archiveURL),
               let notesDecoded = try? propertyListDecoder.decode([Note].self, from: retrievedNoteData) {
                notes = notesDecoded
            }
        }
    }
    
    func addResult(level: String, chapter: String, topic: String, correctAnswers: Int, wrongAnswers: Int, totalQuestions: Int) {
        self.addNotesResult(
            level: level,
            chapter: chapter,
            topic: topic,
            folderName: nil,
            correctAnswers: correctAnswers,
            wrongAnswers: wrongAnswers,
            totalQuestions: totalQuestions
        )
    }

    func addResult(folderName: String, correctAnswers: Int, wrongAnswers: Int, totalQuestions: Int) {
        self.addNotesResult(
            level: nil,
            chapter: nil,
            topic: nil,
            folderName: folderName,
            correctAnswers: correctAnswers,
            wrongAnswers: wrongAnswers,
            totalQuestions: totalQuestions
        )
    }

    private func addNotesResult(level: String?, chapter: String?, topic: String?, folderName: String?, correctAnswers: Int, wrongAnswers: Int, totalQuestions: Int) {
        let noteType: NoteType

        switch level {
        case "一":
            noteType = .sone
        case "二":
            noteType = .stwo
        case "三":
            noteType = .sthree
        case "四", "O 水准备考":
            noteType = .sfour
        default:
            noteType = .note
        }

        var title = ""
        if let level, let chapter, let topic  {
            if chapter == "年终考试" {
                title = "中\(level) - \(chapter)"
            } else if level == "O 水准备考" {
                title = "\(level) - \(chapter)"
            } else {
                title = "中\(level) - \(chapter) - \(topic)"
            }
        } else if let folderName {
            title = "\(folderName) on \(Date().formatted(date: .numeric, time: .omitted)) at \(Date().formatted(date: .omitted, time: .shortened))"
        }
        let content = "Correct: \(correctAnswers)\nWrong: \(wrongAnswers)\nTotal: \(correctAnswers)/\(totalQuestions)"
        let newNote = Note(title: title, content: content, noteType: noteType)

        notes.append(newNote)
    }

    // MARK: firebase helpers

    private func getNotesFromFirebase() async -> Bool {
        guard let uid = userDocId else { return false }
        do {
            let userDoc = try await Firestore.firestore()
                .collection("users").document(uid)
                .getDocument()

            guard let data = userDoc.data(),
                  let notesDataString = data["notes"] as? String
            else {
                print("Could not read notes from firebase")
                return false
            }

            guard let notesData = Data(base64Encoded: notesDataString),
                  let notes = try? PropertyListDecoder().decode([Note].self, from: notesData)
            else {
                print("Could not decode notes data")
                return false
            }

            await MainActor.run { self.notes = notes }

            return true
        } catch {
            print("Error getting notes: \(error)")
            return false
        }
    }

    private func updateNotesOnFirebase(newNotesData: Data) async {
        guard let uid = userDocId else { return }

        do {
            try await Firestore.firestore()
                .collection("users").document(uid)
                .setData(["notes": newNotesData.base64EncodedString()], merge: true)
            print("Notes updated on firebase")
        } catch {
            print("Error updating notes: \(error)")
        }
    }
}
