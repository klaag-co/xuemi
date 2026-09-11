//
//  AccountInfoView.swift
//  Xuemi
//
//  Created by Tristan Chay on 14/6/26.
//

import SwiftUI

struct AccountInfoView: View {
    @Environment(AuthManager.self) private var authManager
    
    var body: some View {
        List {
//            Section("Profile Photo") {
//                
//            }
            
            Section("Information") {
                LabeledContent {
                    Text(authManager.email ?? "?")
                } label: {
                    Text("Email")
                }
                LabeledContent {
                    Text(authManager.signInMethod?.name ?? "?")
                } label: {
                    Text("Sign In Method")
                }
            }
            
            Section("Account Management") {
                Button("Delete Account", systemImage: "trash", role: .destructive) {
                    authManager.deleteAccount()
                }
                .foregroundStyle(.red)
            }
        }
        .navigationTitle("Account")
    }
}

#Preview {
    AccountInfoView()
}
