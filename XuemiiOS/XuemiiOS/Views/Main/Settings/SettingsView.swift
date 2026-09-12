//
//  SettingsView.swift
//  Xuemi
//
//  Created by Gracelyn Gosal on 13/6/26.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(SettingsManager.self) private var settingsManager

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    NavigationLink {
                        AccountInfoView()
                    } label: {
                        AccountInfoRow(email: authManager.email)
                    }
                }

                Section("Chinese Level") {
                    Picker("Chinese Level", selection: Binding(
                        get: { settingsManager.chineseLevel ?? .express },
                        set: { settingsManager.chineseLevel = $0 }
                    )) {
                        ForEach(Vocabulary.ChineseLevel.allCases, id: \.rawValue) { chineseLevel in
                            Text(chineseLevel.name)
                                .tag(chineseLevel)
                        }
                    }
                    .onChange(of: settingsManager.chineseLevel) {
                        settingsManager.save()
                    }
                }

                Section("App Details") {
                    NavigationLink {
                        AppInfoView()
                    } label: {
                        Label {
                            Text("About Our App")
                                .font(.headline)
                        } icon: {
                            Image(systemName: "info.circle")
                                .imageScale(.large)
                                .foregroundStyle(.accent)
                        }
                    }
                }
                
                Section("Acknowledgements") {
                    NavigationLink {
                        AcknowledgementsView()
                    } label: {
                        Label {
                            Text("Acknowledgements")
                                .font(.headline)
                        } icon: {
                            Image(systemName: "heart")
                                .imageScale(.large)
                                .foregroundStyle(.accent)
                        }
                    }
                }
                
                Section("Help & Support") {
                    Link(destination: URL(string: "mailto:klaag.co@gmail.com")!) {
                        Label {
                            VStack(alignment: .leading) {
                                Text("Contact the Xuemi Team")
                                    .font(.headline)
                                Text("Email us at klaag.co@gmail.com")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "envelope")
                                .imageScale(.large)
                                .foregroundStyle(.accent)
                        }
                    }
                    .buttonStyle(.plain)
                }
                
//                Section {
//                    Toggle("App Update Notifications", isOn: .constant(true))
//                } header: {
//                    Text("Notifications")
//                } footer: {
//                    Text("Receive announcements about new Xuemi features, updates and improvements.")
//                }
                
                Section("Sign Out") {
                    Button("Sign out", systemImage: "rectangle.portrait.and.arrow.right", role: .destructive) {
                        authManager.signOut()
                    }
                    .foregroundStyle(.red)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
