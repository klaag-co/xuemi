//
//  String+Identifiable.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 15/6/26.
//

import Foundation

extension String: @retroactive Identifiable {
    public var id: String { self }
}
