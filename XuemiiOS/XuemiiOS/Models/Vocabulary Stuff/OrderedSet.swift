//
//  OrderedSet.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 14/6/26.
//

import Foundation

struct OrderedSet<T: Hashable> {
    private var set: Set<T> = []
    private(set) var elements: [T] = []

    mutating func insert(_ value: T) {
        if set.insert(value).inserted {
            elements.append(value)
        }
    }

    init<S: Sequence>(_ sequence: S) where S.Element == T {
        for value in sequence { insert(value) }
    }
}
