//
//  AuthManager.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 14/6/26.
//

import SwiftUI
import GoogleSignIn
import FirebaseAuth
import FirebaseCore
import AuthenticationServices
import CryptoKit
import FirebaseFirestore

@Observable
final class AuthManager: NSObject {
    // User Details
    private(set) var isLoggedIn: Bool?
    private(set) var email: String?
    private(set) var signInMethod: SignInMethod?
    private(set) var uid: String?
    
    // Sign in With Apple (SIWA)
    var siwaCurrentNonce: String?
    var siwaAuthController: ASAuthorizationController?
    var siwaCredential: OAuthCredential?
    var siwaAuthCodeString: String?
    var siwaAuthContinuation: CheckedContinuation<Void, any Error>?
    
    override init() {
        super.init()
        
        checkAuthStatus()
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
    }
    
    func checkAuthStatus() {
        if let fbUser = Auth.auth().currentUser {
            withAnimation {
                isLoggedIn = true
                email = fbUser.email
                uid = fbUser.uid
                signInMethod = SignInMethod(rawValue: fbUser.providerData.map({ $0.providerID }).first!)
            }
            
            Task {
                do {
                    let documentExists = try await checkIfUserDocumentExists(for: uid!)
                    if !documentExists {
                        try await createUserDocument(for: uid!, email: email!)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        } else {
            withAnimation {
                isLoggedIn = false
                email = nil
                uid = nil
                signInMethod = nil
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            if signInMethod == .google {
                GIDSignIn.sharedInstance.signOut()
            }
        } catch {
            print(error.localizedDescription)
        }
        self.checkAuthStatus()
    }
    
    func deleteAccount() {
        switch signInMethod {
        case .apple:
            Task {
                do {
                    try await self.reauthenticateWithApple()
//                    guard let siwaAuthCodeString = self.siwaAuthCodeString else { return }
//                    try await Auth.auth().revokeToken(withAuthorizationCode: siwaAuthCodeString)
                    self.firebaseAuthDelete()
                } catch {
                    print(error.localizedDescription)
                }
            }
        case .google:
            Task {
                do {
                    try await self.reauthenticateWithGoogle()
                    self.firebaseAuthDelete()
                } catch {
                    print(error.localizedDescription)
                }
            }
        case .none: break
        }
    }
    
    private func firebaseAuthDelete() {
        guard let user = Auth.auth().currentUser, let uid else { return }
        Task {
            do {
                try await Firestore.firestore().collection("users").document(uid).delete()
                try await user.delete()
                self.checkAuthStatus()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
