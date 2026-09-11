//
//  VocabularyError.swift
//  Xuemi
//
//  Created by Tristan Chay on 14/6/26.
//

import Foundation

enum VocabularyError: LocalizedError {
    case fileNotFound(String)
    case decodingFailed(String, underlying: Error)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let name):
            return "Could not find \(name).json in the main bundle."
        case .decodingFailed(let file, let error):
            return "Failed to decode \(file): \(error.localizedDescription)"
        }
    }
}
