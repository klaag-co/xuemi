import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import CryptoKit
import FirebaseFirestore

final class AuthenticationManager: NSObject, ObservableObject {
    static let shared = AuthenticationManager()

    @Published var isLoggedIn: Bool?
    @Published var isGuest: Bool = false
    @Published var givenName: String?
    @Published var familyName: String?
    @Published var fullName: String?
    @Published var email: String?
    @Published var profilePicUrl: String?
    @Published var errorMessage: String?

    private var currentNonce: String?
    private var appleController: ASAuthorizationController?

    private override init() {
        super.init()

        if let clientID = FirebaseApp.app()?.options.clientID {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        }

        if let email = UserDefaults.standard.string(forKey: "userEmail") {
            self.email = email
        }

        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                guard let self else { return }

                if self.isGuest {
                    self.isLoggedIn = true
                    return
                }

                if let user {
                    self.fullName = user.displayName
                    self.email = user.email
                    self.profilePicUrl = user.photoURL?.absoluteString
                    self.isLoggedIn = true

                    if let email = user.email {
                        UserDefaults.standard.set(email, forKey: "userEmail")
                    }
                } else {
                    self.isLoggedIn = false
                }
            }
        }

        restoreSignIn()
    }

    func continueAsGuest() {
        withAnimation {
            isGuest = true
            isLoggedIn = true
        }
    }

    @MainActor
    func checkStatus() {
        if isGuest {
            isLoggedIn = true
            return
        }

        if let user = GIDSignIn.sharedInstance.currentUser {
            givenName = user.profile?.givenName
            familyName = user.profile?.familyName
            fullName = user.profile?.name
            email = user.profile?.email
            profilePicUrl = user.profile?.imageURL(withDimension: 100)?.absoluteString
            isLoggedIn = true
            if let e = email { UserDefaults.standard.set(e, forKey: "userEmail") }
            return
        }

        if let fUser = Auth.auth().currentUser {
            fullName = fUser.displayName
            email = fUser.email
            profilePicUrl = fUser.photoURL?.absoluteString
            isLoggedIn = true
            if let e = fUser.email { UserDefaults.standard.set(e, forKey: "userEmail") }
            return
        }

        isLoggedIn = false
    }

    private func restoreSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] _, _ in
            Task { @MainActor in
                self?.checkStatus()
            }
        }
    }

    func signIn() {
        guard let presentingController = getPresenter() else { return }

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingController) { [weak self] result, error in
            guard let self else { return }

            if let error = error {
                Task { @MainActor in self.errorMessage = error.localizedDescription }
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                Task { @MainActor in self.errorMessage = "Google sign-in failed." }
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )

            Auth.auth().signIn(with: credential) { _, authError in
                if let authError = authError {
                    Task { @MainActor in self.errorMessage = authError.localizedDescription }
                    return
                }

                Task { @MainActor in
                    self.isGuest = false
                    self.isLoggedIn = true
                    self.checkStatus()
                }
            }
        }
    }

    func signInWithApple() {
        let nonce = randomNonceString()
        currentNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        appleController = controller
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    func deleteAccount(completion: @escaping (Bool, String?) -> Void) {
        guard !isGuest else {
            completion(false, "Guest users do not have an account to delete.")
            return
        }

        guard let user = Auth.auth().currentUser else {
            completion(false, "No user is currently signed in.")
            return
        }

        let uid = user.uid

        ScoreManager.shared.clearAll()
        MemoryStats.shared.clearAll()
        NotesManager.shared.clearAll()
        BookmarkManager.shared.clearAll()

        clearLocalFiles()
        clearLocalUserDefaults()

        Firestore.firestore()
            .collection("users")
            .document(uid)
            .delete { [weak self] firestoreError in
                if let firestoreError = firestoreError {
                    completion(false, firestoreError.localizedDescription)
                    return
                }

                user.delete { authError in
                    if let authError = authError {
                        completion(false, authError.localizedDescription)
                        return
                    }

                    self?.signOut()
                    completion(true, nil)
                }
            }
    }

    func signOut() {
        isGuest = false
        GIDSignIn.sharedInstance.signOut()

        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }

        UserDefaults.standard.removeObject(forKey: "userEmail")

        Task { @MainActor in
            self.checkStatus()
        }
    }

    private func clearLocalFiles() {
        let fileNames = [
            "notes.plist",
            "bookmarks.plist",
            "folders.plist",
            "scores.plist",
            "memoryAttempts.plist",
            "inkNotes.plist"
        ]

        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        for fileName in fileNames {
            let url = documents.appendingPathComponent(fileName)
            try? FileManager.default.removeItem(at: url)
        }
    }

    private func clearLocalUserDefaults() {
        let keys = [
            "profile_email",
            "profile_name",
            "profile_school",
            "profile_avatar_data",
            "userEmail",
            "appUpdateNotificationsEnabled",
            "quiz_results_v2",
            "customFolders"
        ]

        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
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

// MARK: - Apple Sign In Delegate

extension AuthenticationManager: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first(where: { $0.isKeyWindow }) else {
            return ASPresentationAnchor()
        }
        return window
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            errorMessage = "Apple Sign-In failed."
            return
        }

        guard let nonce = currentNonce else {
            errorMessage = "Invalid Apple Sign-In request."
            return
        }

        guard let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            errorMessage = "Unable to fetch Apple identity token."
            return
        }

        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )

        Auth.auth().signIn(with: credential) { [weak self] result, error in
            if let error = error {
                Task { @MainActor in
                    self?.errorMessage = error.localizedDescription
                    self?.isLoggedIn = false
                }
                return
            }

            Task { @MainActor in
                self?.isGuest = false
                self?.isLoggedIn = true
                self?.checkStatus()
                print("APPLE LOGIN SUCCESS:", result?.user.uid ?? "No UID")
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        errorMessage = error.localizedDescription
        print("APPLE LOGIN ERROR:", error.localizedDescription)
    }
}

// MARK: - Nonce Helpers

private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)

    let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

    var result = ""
    var remainingLength = length

    while remainingLength > 0 {
        var randoms = [UInt8](repeating: 0, count: 16)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randoms.count, &randoms)

        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce.")
        }

        randoms.forEach { random in
            if remainingLength == 0 { return }

            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }

    return result
}

private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)

    return hashedData.map {
        String(format: "%02x", $0)
    }.joined()
}
