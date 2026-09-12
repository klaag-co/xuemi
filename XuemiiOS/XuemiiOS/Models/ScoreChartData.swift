//
//  ScoreChartData.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 19/6/26.
//

import Foundation

struct ScoreChartData: Identifiable {
    var id: String { label }
    let label: String
    let value: Double
    let attemptCount: Int

    func chartDisplayValue(for type: ScoreData.ScoreType) -> Double {
        guard type == .mcq, attemptCount > 0, value == 0 else { return value }
        return 1
    }
}
