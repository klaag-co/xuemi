//
//  ProgressManager.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 30/7/24.
//

import Foundation

struct ProgressState: Codable, Identifiable, Hashable {
    var id = UUID()
    var level: SecondaryNumber
    var chapter: Chapter
    var topic: Topic
    var currentIndex: Int
}

class ProgressManager: ObservableObject {
    static let shared: ProgressManager = .init()
    
    @Published var currentProgress: ProgressState? {
        didSet {
            save()
        }
    }
    
    private func getArchiveURL() -> URL {
        let plistName = "progress.plist"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent(plistName)
    }
    
    private func save() {
        guard let currentProgress = currentProgress else { return }
        let archiveURL = getArchiveURL()
        let propertyListEncoder = PropertyListEncoder()
        if let encodedProgress = try? propertyListEncoder.encode(currentProgress) {
            try? encodedProgress.write(to: archiveURL, options: .noFileProtection)
        }
    }
    
    private func load() {
        let archiveURL = getArchiveURL()
        let propertyListDecoder = PropertyListDecoder()
        if let retrievedProgressData = try? Data(contentsOf: archiveURL),
           let decodedProgress = try? propertyListDecoder.decode(ProgressState.self, from: retrievedProgressData) {
            currentProgress = decodedProgress
        }
    }
    
    func updateProgress(level: SecondaryNumber, chapter: Chapter, topic: Topic, currentIndex: Int) {
        currentProgress = ProgressState(level: level, chapter: chapter, topic: topic, currentIndex: currentIndex)
    }
    
    init() {
        load()
    }
}
