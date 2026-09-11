//
//  Topic.swift
//  Xuemi
//
//  Created by Tristan Chay on 19/6/26.
//

import Foundation

struct Topic: Identifiable, Hashable {
    var id = UUID()
    var parentName: String
    var vocabularies: [Vocabulary]
}
