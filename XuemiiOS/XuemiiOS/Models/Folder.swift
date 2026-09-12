//
//  Folder.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 15/6/26.
//

import Foundation

struct Folder: Identifiable, Hashable {
    var id: String
    var title: String
    var vocabularies: [Vocabulary]
}
