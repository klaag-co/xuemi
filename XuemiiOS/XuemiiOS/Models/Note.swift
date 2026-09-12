//
//  Note.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 15/6/26.
//

import Foundation

struct Note: Identifiable {
    var id: String
    var title: String
    var description: String
    var type: Note.NoteType
    
    enum NoteType: String, CaseIterable {
        case exam = "Exam"
        case note = "Note"
        case secondary1 = "Secondary 1"
        case secondary2 = "Secondary 2"
        case secondary3 = "Secondary 3"
        case secondary4 = "Secondary 4"
    }
}
