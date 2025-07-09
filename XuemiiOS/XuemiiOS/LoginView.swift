//
//  LoginView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 8/7/25.
//

import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @ObservedObject private var authmanager: AuthenticationManager = .shared
    var body: some View {
        VStack {
            Image("xuemi")
                .resizable()
                .scaledToFit()
                .frame(width:200)
                .mask(RoundedRectangle(cornerRadius: 45))
                .padding()
            Text("Welcome to Xuemi!")
                .font(.largeTitle)
            GoogleSignInButton(action: authmanager.signIn)
                .padding()
            Button("Guest login") {
                
            }
        }
    }
}

#Preview {
    LoginView()
}
