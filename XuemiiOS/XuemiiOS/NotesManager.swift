//
//  NotesManager.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 30/5/24.
//

import Foundation

struct Note: Codable, Identifiable {
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
        let encodedNotes = try? propertyListEncoder.encode(notes)
        try? encodedNotes?.write(to: archiveURL, options: .noFileProtection)
    }
    
    func load() {
        let archiveURL = getArchiveURL()
        let propertyListDecoder = PropertyListDecoder()
                
        if let retrievedNoteData = try? Data(contentsOf: archiveURL),
           let notesDecoded = try? propertyListDecoder.decode([Note].self, from: retrievedNoteData) {
            notes = notesDecoded
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
}
