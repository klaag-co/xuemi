//
//  SettingsView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 16/4/24.
//

import SwiftUI
import FirebaseFirestore

struct SettingsView: View {
    @ObservedObject private var authmanager: AuthenticationManager = .shared
    
    @State private var acknowledgements: [Acknowledgement] = []
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Sign out").font(.headline)) {
                    Button("Sign out"){
                        withAnimation{
                            authmanager.signOut()
                        }
                    }
                }
                Section(header: Text("App").font(.headline)) {
                    NavigationLink(destination: AppInfoDetailView()) {
                        HStack {
                            Text("About Our App")
                            Spacer()
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section(header: Text("Acknowledgement").font(.headline)) {
                    if acknowledgements.isEmpty {
                        ProgressView()
                    } else {
                        ForEach(acknowledgements, id: \.self) { person in
                            AcknowledgementDetailView(person: person)
                        }
                    }
                }
                
                Section(header: Text("Help and Support").font(.headline)) {
                    HelpSupportView()
                }
            }
            .onAppear {
                Task {
                    let query = try await Firestore.firestore().collection("acknowledgements").getDocuments()
                    self.acknowledgements = []
                    query.documents.forEach { document in
                        let acknowledgement = Acknowledgement(
                            position: document.data()["position"] as? Int ?? -1,
                            name: document.data()["name"] as? String ?? "",
                            role: document.data()["role"] as? String ?? "",
                            icon: document.data()["icon"] as? String ?? ""
                        )
                        self.acknowledgements.append(acknowledgement)
                    }
                    acknowledgements.sort(by: { $0.position < $1.position })
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct AppInfoDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Our app, Xuemi, is an app that will help secondary school students improve their Chinese language in a more convenient manner.")
                Text("Students will be able to study anywhere, anytime. The app features will allow students to practise their reading and writing and strengthen their use of the Chinese language. Students will be able to learn how to write the Chinese words correctly, and read passages fluently and with confidence.")
                Text("The app includes a test function which tests students based on the ‘O’ level marking scheme. The content from sec 1-sec 4 will be compiled in this app, allowing easier access to materials for students. Additionally, we will include a note-taking function in the app.")
            }
            .padding()
        }
        .navigationTitle("About Our App")
    }
}

struct AcknowledgementDetailView: View {
    let person: Acknowledgement
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(person.name)
                    .font(.headline)
                Text(person.role)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: person.icon)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 8)
    }
}

struct HelpSupportView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("For help and support, please contact:")
            Link(destination: URL(string: "mailto:klaag.co@gmail.com")!) {
                Text("klaag.co@gmail.com")
            }
        }
    }
}

struct Acknowledgement: Hashable {
    let position: Int
    let name: String
    let role: String
    let icon: String
}
