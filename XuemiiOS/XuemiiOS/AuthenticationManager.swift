//
//  AuthenticationManager.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 8/7/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class AuthenticationManager: ObservableObject {
    static let shared: AuthenticationManager = .init()

    @Published var isLoggedIn: Bool?
    @Published var givenName: String?
    @Published var familyName: String?
    @Published var fullName: String?
    @Published var email: String?
    @Published var profilePicUrl: String?
    @Published var errorMessage: String?

    private init() {
        if let clientID = FirebaseApp.app()?.options.clientID {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        }

        if let email = UserDefaults.standard.string(forKey: "userEmail") {
            self.email = email
        }

        restoreSignIn()
    }

    @MainActor
    func checkStatus() {
        if let user = GIDSignIn.sharedInstance.currentUser {
            givenName      = user.profile?.givenName
            familyName     = user.profile?.familyName
            fullName       = user.profile?.name
            email          = user.profile?.email
            profilePicUrl  = user.profile?.imageURL(withDimension: 100)?.absoluteString
            withAnimation { isLoggedIn = true }
            if let e = email { UserDefaults.standard.set(e, forKey: "userEmail") }
            return
        }

        if let fUser = Auth.auth().currentUser {
            givenName      = nil
            familyName     = nil
            fullName       = fUser.displayName
            email          = fUser.email
            profilePicUrl  = fUser.photoURL?.absoluteString
            withAnimation { isLoggedIn = true }
            if let e = fUser.email { UserDefaults.standard.set(e, forKey: "userEmail") }
            return
        }

        givenName = nil
        familyName = nil
        fullName = nil
        email = nil
        profilePicUrl = nil
        withAnimation { isLoggedIn = false }
    }

    private func restoreSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] _, error in
            if let error = error {
                print("Restore error: \(error.localizedDescription)")
                Task { @MainActor in self?.errorMessage = "error: \(error.localizedDescription)" }
            }
            Task { @MainActor in self?.checkStatus() }
        }
    }

    func signIn() {
        guard let presentingController = getPresenter() else { return }

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingController) { [weak self] result, error in
            guard let self else { return }

            if let error = error {
                Task { @MainActor in self.errorMessage = "error: \(error.localizedDescription)" }
                return
            }

            guard
                let user = result?.user,
                let idToken = user.idToken?.tokenString
            else {
                Task { @MainActor in self.errorMessage = "Google sign-in failed." }
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { _, authError in
                if let authError = authError {
                    Task { @MainActor in self.errorMessage = authError.localizedDescription }
                }
                Task { @MainActor in self.checkStatus() }
            }
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        do { try Auth.auth().signOut() } catch { print(error.localizedDescription) }
        UserDefaults.standard.removeObject(forKey: "userEmail")
        Task { @MainActor in self.checkStatus() }
    }

    private func getPresenter() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return nil }
        let window = scene.windows.first { $0.isKeyWindow } ?? scene.windows.first
        guard let root = window?.rootViewController else { return nil }
        return topMost(from: root)
    }

    private func topMost(from root: UIViewController) -> UIViewController {
        if let presented = root.presentedViewController { return topMost(from: presented) }
        if let nav = root as? UINavigationController { return topMost(from: nav.visibleViewController ?? nav) }
        if let tab = root as? UITabBarController { return topMost(from: tab.selectedViewController ?? tab) }
        return root
    }
}

