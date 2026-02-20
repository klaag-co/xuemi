//
//  ProfileRemoteStorage.swift
//  XuemiiOS
//
//  Created by Kmy Er on 1/9/25.
//

import Foundation
import FirebaseFirestore

enum ProfileRemoteStorage {
    private static var db: Firestore { Firestore.firestore() }
    private static var col: CollectionReference { db.collection("users") }

    /// Fetch a profile once by email. Returns nil if not found.
    static func fetch(id: String) async throws -> UserProfile? {
        guard id != "local" else { return nil }
        
        let ref = col.document(id)
        let snap = try await ref.getDocument()
        guard snap.exists else { return nil }
        do {
            // Decode directly into your model
            return try snap.data(as: UserProfile.self)
        } catch {
            // If you prefer manual decoding, fall back here:
            // let data = snap.data() ?? [:]
            // ... map fields manually ...
            throw error
        }
    }

    /// Create or update the user profile (merge).
    static func update(profile: UserProfile) async throws {
        guard profile.id != "local" else { return }
        
        let enc = JSONEncoder()
        enc.dateEncodingStrategy = .iso8601

        // FirestoreSwift can encode Codable structs for you:
        try col.document(profile.id).setData(from: profile, merge: true)

        // If you want full control, use a dictionary instead:
        // let data: [String: Any] = [
        //   "id": profile.id.uuidString,
        //   "displayName": profile.displayName,
        //   "bio": profile.bio as Any,
        //   "email": profile.email as Any,
        //   "updatedAt": Timestamp(date: profile.updatedAt)
        // ]
        // try await col.document(profile.id.uuidString).setData(data, merge: true)
    }

    /// Optional: delete remote profile (not required by your flow).
    static func delete(id: String) async throws {
        guard id != "local" else { return }
        try await col.document(id).delete()
    }
}
