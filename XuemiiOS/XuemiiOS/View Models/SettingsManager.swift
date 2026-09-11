//
//  SettingsManager.swift
//  Xuemi
//
//  Created by Tristan Chay on 18/8/26.
//

import Foundation
import FirebaseFirestore

@Observable
class SettingsManager {
    var chineseLevel: Vocabulary.ChineseLevel? {
        didSet {
            if let chineseLevel {
                persistLocally(chineseLevel)
            }
        }
    }

    private let authManager: AuthManager

    init(authManager: AuthManager) {
        self.authManager = authManager

        if let uid = authManager.uid {
            self.chineseLevel = self.getCachedChineseLevel(for: uid)
        }

        load()
    }

    func load() {
        guard let uid = authManager.uid else {
            chineseLevel = nil
            return
        }

        chineseLevel = self.getCachedChineseLevel(for: uid)

        Task {
            do {
                let document = try await Firestore.firestore()
                    .collection("users")
                    .document(uid)
                    .getDocument()

                if let rawValue = document.data()?["chineseLevel"] as? String,
                   let level = Vocabulary.ChineseLevel(rawValue: rawValue) {
                    self.chineseLevel = level
                } else {
                    self.chineseLevel = .express
                    save()
                }
            } catch {
                print(error.localizedDescription)
                if self.chineseLevel == nil {
                    self.chineseLevel = .express
                }
            }
        }
    }

    func save() {
        guard let uid = authManager.uid, let chineseLevel else { return }

        Task {
            do {
                try await Firestore.firestore()
                    .collection("users")
                    .document(uid)
                    .setData([
                        "chineseLevel": chineseLevel.rawValue
                    ], merge: true)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    private func persistLocally(_ level: Vocabulary.ChineseLevel) {
        guard let uid = authManager.uid else { return }
        UserDefaults.standard.set(level.rawValue, forKey: "chineseLevel-\(uid)")
    }

    private func getCachedChineseLevel(for uid: String) -> Vocabulary.ChineseLevel? {
        guard let rawValue = UserDefaults.standard.string(forKey: "chineseLevel-\(uid)") else {
            return nil
        }
        return Vocabulary.ChineseLevel(rawValue: rawValue)
    }
}
