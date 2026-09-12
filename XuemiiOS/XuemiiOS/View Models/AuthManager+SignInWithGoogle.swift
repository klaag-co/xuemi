//
//  AuthManager+SignInWithGoogle.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 14/6/26.
//

import Foundation
import GoogleSignIn
import FirebaseAuth

extension AuthManager {
    func signInWithGoogle() async throws {
        guard let credential = try await getGoogleCredentials() else { return }
        try await Auth.auth().signIn(with: credential)
        self.checkAuthStatus()
    }
    
    func reauthenticateWithGoogle() async throws {
        guard let credential = try await getGoogleCredentials() else { return }
        try await Auth.auth().currentUser?.reauthenticate(with: credential)
        self.checkAuthStatus()
    }
    
    private func getGoogleCredentials() async throws -> AuthCredential? {
        guard let presentingController = getPresenter() else { return nil }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingController)
        let user = result.user
        guard let idToken = user.idToken?.tokenString else { return nil }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: user.accessToken.tokenString
        )
        
        return credential
    }
    
    func getPresenter() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first?.rootViewController else {
            return nil
        }
        return root
    }
}
