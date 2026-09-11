//
//  Folder.swift
//  Xuemi
//
//  Created by Tristan Chay on 15/6/26.
//

import Foundation

struct Folder: Identifiable, Hashable {
    var id: String
    var title: String
    var vocabularies: [Vocabulary]
}
