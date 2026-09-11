//
//  ProgressState.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 19/6/26.
//

import Foundation

struct ProgressState: Codable, Identifiable, Hashable {
    var id: String {
        "\(level)_\(chapter)_\(topic)"
    }
    var level: String
    var chapter: String
    var topic: String
    var currentIndex: Int
}
