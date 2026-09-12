//
//  AuthError.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 14/6/26.
//

import Foundation

enum AuthError: LocalizedError {
    case invalidCredential
    case missingNonce
    case invalidToken
    case invalidAuthCode

    var errorDescription: String? {
        switch self {
        case .invalidCredential: return "Invalid Apple ID credential."
        case .missingNonce: return "Missing nonce."
        case .invalidToken: return "Could not read Apple identity token."
        case .invalidAuthCode: return "Could not read Apple authorization code."
        }
    }
}
