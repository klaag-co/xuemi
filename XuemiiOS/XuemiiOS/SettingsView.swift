//
//  SettingsView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 16/4/24.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {

                Section(header: Text("App").font(.headline)) {
                    AppInfoView()
                }
                
                Section(header: Text("Acknowledgement").font(.headline)) {
                    ForEach(acknowledgements, id: \.self) { person in
                        AcknowledgementDetailView(person: person)
                    }
                }
                
                Section(header: Text("Help and Support").font(.headline)) {
                    HelpSupportView()
                }
            }
            .navigationTitle("Settings")
        }
    }
}



struct AppInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Our app, Xuemi, is an app that will help secondary school students improve their Chinese language in a more convenient manner.")
            Text("Students will be able to study anywhere, anytime. The app features will allow students to practise their reading and writing and strengthen their use of the Chinese language. Students will be able to learn how to write the Chinese words correctly, and read passages fluently and with confidence.")
            Text("The app includes a test function which tests students based on the ‘O’ level marking scheme. The content from sec 1-sec 4 will be compiled in this app, allowing easier access to materials for students. Additionally, we will include a note-taking function in the app.")
        }
        .padding()
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
        VStack(alignment: .leading, spacing: 10) {
            Text("For help and support, please contact:")
            Text("kmy_er_sze_lei@s2023.ssts.edu.sg")
                .foregroundColor(.blue)
        }
        .padding()
    }
}

struct Acknowledgement: Hashable {
    let name: String
    let role: String
    let icon: String
}

let acknowledgements = [
    Acknowledgement(name: "Kmy Er Sze Lei", role: "Project coordinator, designer, developer", icon: "person.fill"),
    Acknowledgement(name: "Gracelyn Gosal", role: "Lead Developer (iOS), marketing", icon: "hammer.fill"),
    Acknowledgement(name: "Lau Rei Yan Abigail", role: "Lead Developer (Android)", icon: "hammer.fill"),
    Acknowledgement(name: "Yoshioka Lili", role: "Lead designer, marketing", icon: "paintbrush.fill"),
    Acknowledgement(name: "Yeo Shu Axelia", role: "Marketing IC", icon: "megaphone.fill")
]


#Preview {
    SettingsView()
}

