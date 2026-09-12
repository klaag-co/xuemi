//
//  AcknowledgementsView.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 14/6/26.
//

import SwiftUI

struct AcknowledgementsView: View {
    private let team: [Acknowledgement] = [
        Acknowledgement(name: "Kmy Er Sze Lei", role: "Project Coordinator, Designer, Developer", icon: "person.fill"),
        Acknowledgement(name: "Gracelyn Gosal", role: "Lead Developer (iOS), Marketing", icon: "hammer.fill"),
        Acknowledgement(name: "Lau Rei Yan Abigail", role: "Lead Developer (Android)", icon: "hammer.fill"),
        Acknowledgement(name: "Yoshioka Lili", role: "Lead Designer, Marketing", icon: "paintbrush.fill"),
        Acknowledgement(name: "Yeo Shu Axelia", role: "Marketing IC", icon: "megaphone.fill"),
        Acknowledgement(name: "Chay Yu Hung Tristan", role: "Consultant", icon: "person.fill"),
        Acknowledgement(name: "Ms Wong Lu Ting", role: "Head of Department", icon: "person.fill"),
        Acknowledgement(name: "Ms Yap Hui Min", role: "Subject Head", icon: "person.fill"),
        Acknowledgement(name: "CL Department", role: "Client", icon: "building.2.fill")
    ]

    var body: some View {
        List {
            Section("Special Thanks") {
                Text("Thank you to everyone who supported Xuemi throughout its development. We are very grateful for your guidance, feedback, and encouragement!")
            }

            Section("Project Contributors") {
                ForEach(team) { member in
                    HStack(spacing: 14) {
                        Image(systemName: member.icon)
                            .frame(width: 28, height: 28)
                            .foregroundStyle(.accent)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(member.name)
                                .font(.headline)

                            Text(member.role)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .navigationTitle("Acknowledgements")
    }
}
