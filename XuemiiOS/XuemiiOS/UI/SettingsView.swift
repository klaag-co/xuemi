//
//  SettingsView.swift — Xuemi (No Firebase version)
//  Avatar picker saved locally, and Personal Info stored locally with AppStorage.
//  No Firebase imports/usage.
//
//  Requirements:
//  • iOS 16+ (PhotosPicker)
//  • AuthenticationManager.shared (for signOut only)
//

import SwiftUI
import PhotosUI

// MARK: - Local Profile Store

struct UserProfile: Codable, Hashable {
    var email: String
    var name: String
    var school: String
}

final class LocalProfileStore: ObservableObject {
    // Persist simple fields locally
    @AppStorage("profile_email") private var storedEmail: String = ""
    @AppStorage("profile_name") private var storedName: String = ""
    @AppStorage("profile_school") private var storedSchool: String = ""
    @AppStorage("profile_avatar_data") var avatarData: Data?

    @Published var profile: UserProfile

    init() {
        self.profile = UserProfile(email: storedEmail, name: storedName, school: storedSchool)
    }

    func save(email: String, name: String, school: String) {
        storedEmail = email
        storedName = name
        storedSchool = school
        profile = UserProfile(email: email, name: name, school: school)
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @ObservedObject private var authmanager: AuthenticationManager = .shared
    @StateObject private var store = LocalProfileStore()
    
    var body: some View {
        NavigationStack {
            List {
                // Profile header (avatar + name + email)
                Section { ProfileHeader(profile: store.profile, avatarData: $store.avatarData) }
                
                // Account → Personal Info page
                Section(header: Text("Account").font(.headline)) {
                    NavigationLink {
                        PersonalInfoView(store: store)
                    } label: {
                        AccountCard(email: store.profile.email,
                                    subtitle: "Tap to view account information",
                                    avatarData: store.avatarData)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .listRowBackground(Color.clear)
                }
                
                
                // Sign out (still uses your AuthenticationManager)
                Section(header: Text("Sign out").font(.headline)) {
                    Button("Sign out") {
                        withAnimation { authmanager.signOut() }
                    }
                }
                
                // App info (unchanged)
                Section(header: Text("App").font(.headline)) {
                    NavigationLink("About Our App") { AppInfoDetailView() }
                }
                
                // Help & Support (unchanged)
                Section(header: Text("Help and Support").font(.headline)) {
                    HelpSupportView()
                }
            }
            .navigationTitle("Settings")
        }
    }
}


// MARK: - Profile Header

struct ProfileHeader: View {
    let profile: UserProfile
    @Binding var avatarData: Data?
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 10) {
            avatarView
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Text("Change Profile Photo").font(.subheadline).foregroundColor(.blue)
            }
            .onChange(of: selectedPhoto) { _, newItem in
                Task {
                    guard let newItem else { return }
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        // Optionally compress to JPEG to reduce size
                        if let uiImage = UIImage(data: data), let jpeg = uiImage.jpegData(compressionQuality: 0.85) {
                            avatarData = jpeg
                        } else {
                            avatarData = data
                        }
                    }
                }
            }

            if !profile.name.isEmpty { Text(profile.name).font(.headline) }
            if !profile.email.isEmpty { Text(profile.email).font(.subheadline).foregroundStyle(.secondary) }

            if avatarData != nil {
                Button("Reset Photo") { avatarData = nil }
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    @ViewBuilder private var avatarView: some View {
        if let data = avatarData, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 72, height: 72)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.secondary.opacity(0.2), lineWidth: 1))
        } else {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFill()
                .frame(width: 72, height: 72)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.secondary.opacity(0.2), lineWidth: 1))
        }
    }
}

// MARK: - Account Card (custom cell)

private struct AccountCard: View {
    let email: String
    let subtitle: String
    let avatarData: Data?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
            HStack(spacing: 14) {
                avatar
                VStack(alignment: .leading, spacing: 2) {
                    Text(email.isEmpty ? "Not set" : email)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .foregroundColor(Color(.tertiaryLabel))
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.vertical, 2)
    }

    private var avatar: some View {
        Group {
            if let data = avatarData, let ui = UIImage(data: data) {
                Image(uiImage: ui).resizable().scaledToFill()
            } else {
                InitialsAvatar(text: email)
            }
        }
        .frame(width: 48, height: 48)
        .clipShape(Circle())
    }
}

private struct InitialsAvatar: View {
    let text: String
    var body: some View {
        let initial = String((text.first ?? "K")).uppercased()
        ZStack {
            Circle().fill(Color(.systemRed))
            Text(initial)
                .font(.title3).bold()
                .foregroundColor(.white)
        }
    }
}

// MARK: - Personal Info

struct PersonalInfoView: View {
    @ObservedObject var store: LocalProfileStore
    @State private var email: String = ""
    @State private var name: String = ""
    @State private var school: String = ""

    var body: some View {
        Form {
            Section(header: Text("Email")) {
                TextField("you@example.com", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            Section(header: Text("Name")) {
                TextField("Your name", text: $name)
                    .textInputAutocapitalization(.words)
            }
            Section(header: Text("School")) {
                TextField("Your school", text: $school)
            }
            Section {
                Button("Save") {
                    store.save(email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                               name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                               school: school.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }
        }
        .navigationTitle("Personal Info")
        .onAppear {
            email = store.profile.email
            name = store.profile.name
            school = store.profile.school
        }
    }
}

// MARK: - App Info & Support (unchanged from your version)

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

