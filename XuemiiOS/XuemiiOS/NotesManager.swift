//
//  NotesManager.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 30/5/24.
//

import SwiftUI

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
}

