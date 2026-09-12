//
//  ScoreSummary.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 19/6/26.
//

import Foundation

struct ScoreSummary {
    let totalCount: Int
    let overallAverage: Double
    let bestScore: Double?

    var hasAttempts: Bool {
        totalCount > 0
    }
}
