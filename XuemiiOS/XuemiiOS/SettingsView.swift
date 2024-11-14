//
//  SettingsView.swift
//  XuemiiOS
//
//  Created by Gracelyn Gosal on 16/4/24.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
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
    let name: String
    let role: String
    let icon: String
}

let acknowledgements = [
    Acknowledgement(name: "Kmy Er Sze Lei", role: "Project Coordinator, Designer, Developer", icon: "person.fill"),
    Acknowledgement(name: "Gracelyn Gosal", role: "Lead Developer (iOS), Marketing", icon: "hammer.fill"),
    Acknowledgement(name: "Lau Rei Yan Abigail", role: "Lead Developer (Android)", icon: "hammer.fill"),
    Acknowledgement(name: "Yoshioka Lili", role: "Lead Designer, Marketing", icon: "paintbrush.fill"),
    Acknowledgement(name: "Yeo Shu Axelia", role: "Marketing IC", icon: "megaphone.fill"),
    Acknowledgement(name: "Chay Yu Hung Tristan", role: "Consultant", icon: "person.fill"),
    Acknowledgement(name: "Ms Wong Lu Ting", role: "Head of Department", icon: "person.fill"),
    Acknowledgement(name: "Ms Yap Hui Min", role: "Teacher-in-Charge", icon: "person.fill"),
    Acknowledgement(name: "Ms Tan Sook Qin", role: "Teacher-in-Charge", icon: "person.fill"),
    Acknowledgement(name: "Ms Yeo Sok Hui", role: "Teacher-in-Charge", icon: "person.fill"),
    Acknowledgement(name: "Ms Xu Wei", role: "Teacher-in-Charge", icon: "person.fill"),
    Acknowledgement(name: "CL Department", role: "Client", icon: "building.2.fill")
]

