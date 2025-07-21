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
    @Published var isGuest: Bool = false
    
    private init() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let signInConfig = GIDConfiguration(clientID: clientID)
        
        // load the email
        if let email = UserDefaults.standard.string(forKey: "userEmail") {
            self.email = email
        }
        
        GIDSignIn.sharedInstance.configuration = signInConfig
        restoreSignIn()
    }
    
    func checkStatus() {
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            self.givenName = nil
            self.familyName = nil
            self.fullName = nil
            self.email = nil
            self.profilePicUrl = nil
            withAnimation{
                self.isLoggedIn = false
            }
            return
        }
        
        let givenName = user.profile?.givenName
        let familyName = user.profile?.familyName
        let fullName = user.profile?.name
        let email = user.profile?.email
        let profilePicUrl = user.profile!.imageURL(withDimension: 100)!.absoluteString
        //        if let email, email.contains("@students.edu.sg") {
        self.givenName = givenName
        self.familyName = familyName
        self.fullName = fullName
        self.email = email
        self.profilePicUrl = profilePicUrl
        withAnimation{
            self.isLoggedIn = true
        }
        print(email)
        print(givenName)
        print(familyName)
        print(fullName)
        // save the email
        UserDefaults.standard.set(email, forKey: "userEmail")
        //        } else {
        //            signOut()
        //        }
    }
    
    private func restoreSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { _, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                self.errorMessage = "error: \(error.localizedDescription)"
            }
            
            self.checkStatus()
        }
    }
    
    func signIn() {
        guard let presentingController = getPresenter() else { return }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingController) { [unowned self] result, error in
            guard error == nil else {
                self.errorMessage = "error: \(error?.localizedDescription)"
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                self.errorMessage = "error: \(error?.localizedDescription)"
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { result, error in
                self.checkStatus()
            }
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        UserDefaults.standard.removeObject(forKey: "userEmail")
        self.checkStatus()
    }
    
    func getPresenter() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first,
              let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
              let window = windowSceneDelegate.window,
              let presentingController = window?.rootViewController else {
            print("Could not get presenting uiviewcontroller")
            return nil
        }
        
        return presentingController
    }
}
