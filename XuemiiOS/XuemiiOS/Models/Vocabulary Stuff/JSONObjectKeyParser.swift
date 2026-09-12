//
//  JSONObjectKeyParser.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 14/6/26.
//

import Foundation

enum JSONObjectKeyParser {
    static func orderedKeys(in data: Data) throws -> [String] {
        guard let text = String(data: data, encoding: .utf8) else {
            throw VocabularyError.decodingFailed("JSON", underlying: DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: "Data is not valid UTF-8")
            ))
        }

        var index = text.startIndex
        try skipWhitespace(in: text, index: &index)
        guard index < text.endIndex, text[index] == "{" else {
            throw VocabularyError.decodingFailed("JSON", underlying: DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: "Expected root JSON object")
            ))
        }

        return try parseObjectKeys(in: text, index: &index)
    }

    static func objectValue(forKey key: String, in data: Data) throws -> Data? {
        guard let text = String(data: data, encoding: .utf8) else {
            return nil
        }

        var index = text.startIndex
        try skipWhitespace(in: text, index: &index)
        guard index < text.endIndex, text[index] == "{" else {
            return nil
        }
        index = text.index(after: index)

        while index < text.endIndex {
            try skipWhitespace(in: text, index: &index)
            if index >= text.endIndex { break }

            if text[index] == "}" {
                return nil
            }

            let parsedKey = try parseString(in: text, index: &index)
            try skipWhitespace(in: text, index: &index)
            guard index < text.endIndex, text[index] == ":" else {
                throw VocabularyError.decodingFailed("JSON", underlying: DecodingError.dataCorrupted(
                    .init(codingPath: [], debugDescription: "Expected ':' after object key")
                ))
            }
            index = text.index(after: index)
            try skipWhitespace(in: text, index: &index)

            if parsedKey == key {
                let valueStart = index
                try skipValue(in: text, index: &index)
                let valueText = String(text[valueStart..<index])
                return valueText.data(using: .utf8)
            }

            try skipValue(in: text, index: &index)
            try skipWhitespace(in: text, index: &index)
            if index < text.endIndex, text[index] == "," {
                index = text.index(after: index)
            }
        }

        return nil
    }

    private static func parseObjectKeys(in text: String, index: inout String.Index) throws -> [String] {
        index = text.index(after: index)
        var keys: [String] = []

        try skipWhitespace(in: text, index: &index)
        if index < text.endIndex, text[index] == "}" {
            index = text.index(after: index)
            return keys
        }

        while index < text.endIndex {
            try skipWhitespace(in: text, index: &index)
            keys.append(try parseString(in: text, index: &index))
            try skipWhitespace(in: text, index: &index)
            guard index < text.endIndex, text[index] == ":" else {
                throw VocabularyError.decodingFailed("JSON", underlying: DecodingError.dataCorrupted(
                    .init(codingPath: [], debugDescription: "Expected ':' after object key")
                ))
            }
            index = text.index(after: index)
            try skipValue(in: text, index: &index)
            try skipWhitespace(in: text, index: &index)

            if index < text.endIndex, text[index] == "}" {
                index = text.index(after: index)
                break
            }

            guard index < text.endIndex, text[index] == "," else {
                throw VocabularyError.decodingFailed("JSON", underlying: DecodingError.dataCorrupted(
                    .init(codingPath: [], debugDescription: "Expected ',' or '}' in object")
                ))
            }
            index = text.index(after: index)
        }

        return keys
    }

    private static func parseString(in text: String, index: inout String.Index) throws -> String {
        guard index < text.endIndex, text[index] == "\"" else {
            throw VocabularyError.decodingFailed("JSON", underlying: DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: "Expected string")
            ))
        }
        index = text.index(after: index)

        var characters: [Character] = []
        while index < text.endIndex {
            let character = text[index]
            if character == "\"" {
                index = text.index(after: index)
                return String(characters)
            }

            if character == "\\" {
                index = text.index(after: index)
                guard index < text.endIndex else { break }
                switch text[index] {
                case "\"": characters.append("\"")
                case "\\": characters.append("\\")
                case "/": characters.append("/")
                case "b": characters.append("\u{8}")
                case "f": characters.append("\u{c}")
                case "n": characters.append("\n")
                case "r": characters.append("\r")
                case "t": characters.append("\t")
                case "u":
                    let hexStart = text.index(after: index)
                    guard let hexEnd = text.index(hexStart, offsetBy: 4, limitedBy: text.endIndex),
                          let scalar = UInt32(text[hexStart..<hexEnd], radix: 16),
                          let unicode = UnicodeScalar(scalar) else {
                        throw VocabularyError.decodingFailed("JSON", underlying: DecodingError.dataCorrupted(
                            .init(codingPath: [], debugDescription: "Invalid unicode escape")
                        ))
                    }
                    characters.append(Character(unicode))
                    index = hexEnd
                default:
                    characters.append(character)
                }
            } else {
                characters.append(character)
            }

            index = text.index(after: index)
        }

        throw VocabularyError.decodingFailed("JSON", underlying: DecodingError.dataCorrupted(
            .init(codingPath: [], debugDescription: "Unterminated string")
        ))
    }

    private static func skipValue(in text: String, index: inout String.Index) throws {
        try skipWhitespace(in: text, index: &index)
        guard index < text.endIndex else { return }

        switch text[index] {
        case "{":
            var depth = 0
            repeat {
                let character = text[index]
                if character == "{" {
                    depth += 1
                } else if character == "}" {
                    depth -= 1
                } else if character == "\"" {
                    _ = try parseString(in: text, index: &index)
                    continue
                }
                index = text.index(after: index)
            } while depth > 0 && index < text.endIndex
        case "[":
            var depth = 0
            repeat {
                let character = text[index]
                if character == "[" {
                    depth += 1
                } else if character == "]" {
                    depth -= 1
                } else if character == "\"" {
                    _ = try parseString(in: text, index: &index)
                    continue
                }
                index = text.index(after: index)
            } while depth > 0 && index < text.endIndex
        case "\"":
            _ = try parseString(in: text, index: &index)
        default:
            while index < text.endIndex, !",}]".contains(text[index]) {
                index = text.index(after: index)
            }
        }
    }

    private static func skipWhitespace(in text: String, index: inout String.Index) throws {
        while index < text.endIndex, text[index].isWhitespace {
            index = text.index(after: index)
        }
    }
}
