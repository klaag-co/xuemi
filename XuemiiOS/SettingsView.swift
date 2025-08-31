import SwiftUI

struct SettingsView: View {
    @ObservedObject private var authmanager: AuthenticationManager = .shared
    @EnvironmentObject private var profile: ProfileManager
    @State private var showEdit = false

    var body: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    Button { showEdit = true } label: {
                        AvatarView(image: profile.avatarImage)
                    }
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(displayName).font(.headline)
                        if let handle = profile.profile?.username, !handle.isEmpty {
                            Text("@\(handle)").foregroundColor(.secondary)
                        }
                        if let bio = profile.profile?.bioLine, !bio.isEmpty {
                            Text(bio).font(.subheadline).foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    Button("Edit") { showEdit = true }.buttonStyle(.bordered)
                }
                .padding(.vertical, 8)
            } header: {
                Text("Profile").font(.headline)
            }

            Section(header: Text("Sign out").font(.headline)) {
                Button("Sign out") { withAnimation { authmanager.signOut() } }
            }

            Section(header: Text("App").font(.headline)) {
                NavigationLink(destination: AppInfoDetailView()) {
                    HStack { Text("About Our App"); Spacer() }.padding(.vertical, 8)
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
        .sheet(isPresented: $showEdit) {
            EditProfileView(
                initial: profile.profile,
                initialAvatar: profile.avatarImage
            ) { updatedProfile, updatedImage in
                ProfileManager.shared.update(profile: updatedProfile, avatar: updatedImage)
            }
        }
    }

    private var displayName: String {
        if let p = profile.profile {
            if let last = p.lastName, !last.isEmpty { return "\(p.firstName) \(last)" }
            return p.firstName
        }
        return "User"
    }
}

struct AvatarView: View {
    var image: UIImage?
    var body: some View {
        Group {
            if let ui = image {
                Image(uiImage: ui).resizable().scaledToFill()
            } else {
                Image(systemName: "person.crop.circle.fill").resizable().scaledToFit().symbolRenderingMode(.hierarchical)
            }
        }
        .frame(width: 64, height: 64)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.secondary.opacity(0.2), lineWidth: 1))
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
                Text(person.name).font(.headline)
                Text(person.role).font(.subheadline).foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: person.icon).foregroundColor(.blue)
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
    Acknowledgement(name: "Ms Yap Hui Min", role: "Acting Subject Head", icon: "person.fill"),
    Acknowledgement(name: "Mr Tan Chuan Leong", role: "Level Head, Upper Secondary", icon: "person.fill"),
    Acknowledgement(name: "Ms Tan Sook Qin", role: "Teacher-in-Charge", icon: "person.fill"),
    Acknowledgement(name: "Ms Yeo Sok Hui", role: "Teacher-in-Charge", icon: "person.fill"),
    Acknowledgement(name: "Ms Xu Wei", role: "Teacher-in-Charge", icon: "person.fill"),
    Acknowledgement(name: "Ms Ms Liew Sui Qiong", role: "Teacher-in-Charge", icon: "person.fill"),
    Acknowledgement(name: "Ms Yap Yee Ying", role: "Teacher-in-Charge", icon: "person.fill"),
    Acknowledgement(name: "Ms Wong Ho Yan", role: "Teacher-in-Charge", icon: "person.fill"),
    Acknowledgement(name: "Ms Goh Su Huei", role: "Teacher-in-Charge", icon: "person.fill"),
    Acknowledgement(name: "CL Department", role: "Client", icon: "building.2.fill")
]

