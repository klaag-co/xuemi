//
//  SignInMethod.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 14/6/26.
//

import Foundation

enum SignInMethod: String {
    case apple = "apple.com"
    case google = "google.com"
    
    var name: String {
        switch self {
        case .apple: "Apple"
        case .google: "Google"
        }
    }
}
