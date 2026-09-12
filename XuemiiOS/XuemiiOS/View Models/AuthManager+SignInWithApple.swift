//
//  AuthManager+SignInWithApple.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 14/6/26.
//

import Foundation
import FirebaseAuth
import AuthenticationServices
import CryptoKit

extension AuthManager: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func signInWithApple() async throws {
        try await authenticateWithApple()
        guard let siwaCredential else { return }
        try await Auth.auth().signIn(with: siwaCredential)
        checkAuthStatus()
    }
    
    func reauthenticateWithApple() async throws {
        try await authenticateWithApple()
        guard let siwaCredential else { return }
        try await Auth.auth().currentUser?.reauthenticate(with: siwaCredential)
        checkAuthStatus()
    }

    private func authenticateWithApple() async throws {
        let nonce = randomNonceString()
        siwaCurrentNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.email]
        request.nonce = sha256(nonce)

        try await withCheckedThrowingContinuation() { continuation in
            self.siwaAuthContinuation = continuation

            let controller = ASAuthorizationController(authorizationRequests: [request])
            self.siwaAuthController = controller
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }

    // MARK: - ASAuthorizationControllerDelegate

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            siwaAuthContinuation?.resume(throwing: AuthError.invalidCredential)
            siwaAuthContinuation = nil
            return
        }

        guard let nonce = siwaCurrentNonce else {
            siwaAuthContinuation?.resume(throwing: AuthError.missingNonce)
            siwaAuthContinuation = nil
            return
        }

        guard
            let appleIDToken = appleIDCredential.identityToken,
            let idTokenString = String(data: appleIDToken, encoding: .utf8)
        else {
            siwaAuthContinuation?.resume(throwing: AuthError.invalidToken)
            siwaAuthContinuation = nil
            return
        }

        guard let appleAuthCode = appleIDCredential.authorizationCode,
              let authCodeString = String(data: appleAuthCode, encoding: .utf8)
        else {
            siwaAuthContinuation?.resume(throwing: AuthError.invalidAuthCode)
            siwaAuthContinuation = nil
            return
        }

        siwaAuthCodeString = authCodeString

        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )

        siwaCredential = credential
        siwaAuthContinuation?.resume()
        siwaAuthContinuation = nil
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        siwaAuthContinuation?.resume(throwing: error)
        siwaAuthContinuation = nil
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = scene.windows.first(where: { $0.isKeyWindow })
        else {
            return ASPresentationAnchor()
        }
        return window
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    private func sha256(_ input: String) -> String {
        let hashedData = SHA256.hash(data: Data(input.utf8))
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}
