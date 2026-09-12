//
//  AuthManager+Firestore.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 14/6/26.
//

import Foundation
import FirebaseFirestore

extension AuthManager {
    func checkIfUserDocumentExists(for uid: String) async throws -> Bool {
        let document = try await Firestore.firestore().collection("users").document(uid).getDocument()
        return document.exists
    }
    
    func createUserDocument(for uid: String, email: String) async throws {
        try await Firestore.firestore().collection("users").document(uid).setData([
            "email": email,
            "profilePicture": "",
            "chineseLevel": Vocabulary.ChineseLevel.express.rawValue
        ])
    }
}
