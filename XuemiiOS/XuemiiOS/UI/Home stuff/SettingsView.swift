import SwiftUI
import PhotosUI

// MARK: - Local Profile Store

struct UserProfile: Codable, Hashable {
    var email: String
    var name: String
    var school: String
}

final class LocalProfileStore: ObservableObject {
    @AppStorage("profile_email")  private var storedEmail: String = ""
    @AppStorage("profile_name")   private var storedName: String = ""
    @AppStorage("profile_school") private var storedSchool: String = ""
    @AppStorage("profile_avatar_data") var avatarData: Data?
    @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = false
    
    @StateObject private var store = LocalProfileStore()
    
    @Published var profile: UserProfile = .init(email: "", name: "", school: "")

    init() {
        self.profile = .init(email: storedEmail, name: storedName, school: storedSchool)
    }

    func save(email: String, name: String, school: String) {
        storedEmail  = email
        storedName   = name
        storedSchool = school
        profile      = .init(email: email, name: name, school: school)
    }
}

// MARK: - Settings (card layout with section titles)

struct SettingsView: View {
    @ObservedObject private var authmanager: AuthenticationManager = .shared
    @StateObject private var store = LocalProfileStore()
//    @State private var EducationStream = "G3"
//    let educationstreams = ["G3", "HCL"]

    // Fallback to signed-in email when stored profile email is empty
    private var accountEmail: String {
        let stored = store.profile.email.trimmingCharacters(in: .whitespacesAndNewlines)
        if !stored.isEmpty { return stored }
        return authmanager.email ?? ""
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    NavigationLink {
                        PersonalInfoView(store: store, signedInEmail: authmanager.email ?? "")
                    } label: {
                        HStack(spacing: 14) {
                            Group {
                                if let data = store.avatarData, let ui = UIImage(data: data) {
                                    Image(uiImage: ui).resizable().scaledToFill()
                                } else {
                                    let initial = String((accountEmail.first ?? "K")).uppercased()
                                    ZStack {
                                        Circle().fill(Color(.systemRed))
                                        Text(initial)
                                            .font(.title3).bold()
                                            .foregroundStyle(.white)
                                    }
                                }
                            }
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(accountEmail.isEmpty ? "Not set" : accountEmail)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                Text("Edit name, school & profile photo")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }

                Section("App Details") {
                    NavigationLink {
                        AppInfoDetailView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "info.circle")
                                .imageScale(.large)
                                .frame(width: 28)
                                .foregroundStyle(.blue)
                            Text("About Our App")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }
                
//                Section("Education stream") {
//                    Picker("Select", selection: $EducationStream){
//                        ForEach(educationstreams, id: \.self) {
//                            Text($0)
//                        }
//                    }
//                    .pickerStyle(.menu)
//                }
                
                Section("Acknowledgements") {
                    NavigationLink {
                        AcknowledgementsView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "heart")
                                .imageScale(.large)
                                .frame(width: 28)
                                .foregroundStyle(.blue)
                            Text("Acknowledgements")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }

                Section("Help & Support") {
                    Link(destination: URL(string: "mailto:klaag.co@gmail.com")!) {
                        HStack(spacing: 12) {
                            Image(systemName: "envelope")
                                .imageScale(.large)
                                .frame(width: 28)
                                .foregroundStyle(.blue)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Contact the Xuemi Team")
                                    .font(.headline)
                                Text("Email us at klaag.co@gmail.com")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }

                Section("Sign Out") {
                    Button {
                        withAnimation {
                            authmanager.signOut()
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .imageScale(.large)
                                .frame(width: 28)
                                .foregroundStyle(.red)
                            Text("Sign out")
                                .font(.headline)
                                .foregroundStyle(.red)
                            Spacer()
                        }
                    }
                }
            }
            Section("Notifications") {
                Toggle("Daily Study Reminder", isOn: $dailyReminderEnabled)
                    .onChange(of: dailyReminderEnabled) { _, newValue in
                        if newValue {
                            NotificationManager.shared.requestPermission()
                            NotificationManager.shared.scheduleDailyReminder(hour: 20, minute: 0)
                        } else {
                            NotificationManager.shared.cancelDailyReminder()
                        }
                    }
            }
            }
        }
    }


// MARK: - Personal Info (with photo chooser + email fallback)

struct PersonalInfoView: View {
    @ObservedObject var store: LocalProfileStore
    var signedInEmail: String = ""   // passed from SettingsView

    @State private var email: String = ""
    @State private var name: String = ""
    @State private var school: String = ""
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        Form {
            Section(header: Text("Profile Photo")) {
                HStack(spacing: 16) {
                    avatarPreview
                    VStack(alignment: .leading, spacing: 8) {
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            Text("Choose Photo")
                        }
                        if store.avatarData != nil {
                            Button("Reset Photo", role: .destructive) { store.avatarData = nil }
                                .font(.footnote)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

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
                    store.save(
                        email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                        name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                        school: school.trimmingCharacters(in: .whitespacesAndNewlines)
                    )
                }
            }
        }
        .navigationTitle("Account")
        .onAppear {
            let stored = store.profile.email.trimmingCharacters(in: .whitespacesAndNewlines)
            email  = stored.isEmpty ? signedInEmail : stored
            name   = store.profile.name
            school = store.profile.school
        }
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                guard let newItem else { return }
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    if let ui = UIImage(data: data),
                       let jpeg = ui.jpegData(compressionQuality: 0.85) {
                        store.avatarData = jpeg
                    } else {
                        store.avatarData = data
                    }
                }
            }
        }
    }

    @ViewBuilder private var avatarPreview: some View {
        if let data = store.avatarData, let ui = UIImage(data: data) {
            Image(uiImage: ui).resizable().scaledToFill()
                .frame(width: 60, height: 60).clipShape(Circle())
        } else {
            Image(systemName: "person.crop.circle.fill").resizable().scaledToFill()
                .frame(width: 60, height: 60).clipShape(Circle())
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - About & Acknowledgements

struct AppInfoDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {

                VStack(alignment: .leading, spacing: 8) {
                    Text("Learn Chinese Smarter")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Xuemi helps secondary school students practise Chinese anytime, anywhere, with tools for revision, writing, notes and progress tracking.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 6)

                VStack(spacing: 14) {
                    AboutFeatureCard(
                        icon: "book.fill",
                        title: "Sec 1–4 Content",
                        description: "Access Chinese vocabulary and revision materials across secondary levels."
                    )

                    AboutFeatureCard(
                        icon: "checkmark.circle.fill",
                        title: "Quizzes & Practice",
                        description: "Test your understanding with MCQ and memory card activities."
                    )

                    AboutFeatureCard(
                        icon: "pencil.and.scribble",
                        title: "Writing Support",
                        description: "Practise Chinese character writing and build confidence."
                    )

                    AboutFeatureCard(
                        icon: "folder.fill",
                        title: "Custom Folders",
                        description: "Save selected words into folders for personalised revision."
                    )

                    AboutFeatureCard(
                        icon: "note.text",
                        title: "Smart Notes",
                        description: "Keep notes and review your learning results in one place."
                    )
                }
            }
            .padding()
        }
        .navigationTitle("About Xuemi")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AboutFeatureCard: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(.blue)
                .frame(width: 32, height: 32)
                .background(Color.blue.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct Acknowledgement: Identifiable {
    let id = UUID()
    let name: String
    let role: String
    let icon: String
}

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
                            .foregroundColor(.blue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(member.name).font(.headline)
                            Text(member.role).font(.subheadline).foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .navigationTitle("Acknowledgements")
    }
}

