import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var username: String = ""
    @State private var school: String = ""
    @State private var country: String = "Singapore"
    @State private var customCountry: String = ""
    @State private var age: Int = 14
    @State private var favoriteAnimal: String = "Cat"
    @State private var customAnimal: String = ""
    @State private var favoriteColor: String = "Blue"
    @State private var customColor: String = ""
    @State private var bioLikeTail: String = ""
    @State private var avatarImage: UIImage?
    @State private var pickerItem: PhotosPickerItem?

    let onSave: (UserProfile, UIImage?) -> Void

    private let countries = ["Singapore","Japan","Malaysia","Indonesia","Thailand","China","Hong Kong","Taiwan","Philippines","Vietnam","India","United States","United Kingdom","Australia","New Zealand","Other"]
    private let animals = ["Cat","Dog","Rabbit","Hamster","Bird","Fish","Turtle","Fox","Panda","Koala","Tiger","Lion","Dolphin","Whale","Otter","Other"]
    private let colors = ["Blue","Red","Green","Yellow","Purple","Pink","Orange","Black","White","Grey","Cyan","Magenta","Brown","Teal","Indigo","Other"]

    init(initial: UserProfile?, initialAvatar: UIImage?, onSave: @escaping (UserProfile, UIImage?) -> Void) {
        self.onSave = onSave
        _avatarImage = State(initialValue: initialAvatar)
        if let p = initial {
            _firstName = State(initialValue: p.firstName)
            _lastName = State(initialValue: p.lastName ?? "")
            _username = State(initialValue: p.username)
            _school = State(initialValue: p.school)
            _country = State(initialValue: countries.contains(p.country) ? p.country : "Other")
            _customCountry = State(initialValue: countries.contains(p.country) ? "" : p.country)
            _age = State(initialValue: p.age)
            _favoriteAnimal = State(initialValue: animals.contains(p.favoriteAnimal) ? p.favoriteAnimal : "Other")
            _customAnimal = State(initialValue: animals.contains(p.favoriteAnimal) ? "" : p.favoriteAnimal)
            _favoriteColor = State(initialValue: colors.contains(p.favoriteColor) ? p.favoriteColor : "Other")
            _customColor = State(initialValue: colors.contains(p.favoriteColor) ? "" : p.favoriteColor)
            _bioLikeTail = State(initialValue: p.bioLine.replacingOccurrences(of: "^I like\\s*", with: "", options: .regularExpression))
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 12) {
                        ZStack(alignment: .bottomTrailing) {
                            Group {
                                if let img = avatarImage {
                                    Image(uiImage: img).resizable().scaledToFill()
                                } else {
                                    Image(systemName: "person.crop.circle.fill").resizable().scaledToFit().symbolRenderingMode(.hierarchical)
                                }
                            }
                            .frame(width: 96, height: 96)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.secondary.opacity(0.2), lineWidth: 1))

                            PhotosPicker(selection: $pickerItem, matching: .images) {
                                Image(systemName: "camera.fill")
                                    .padding(8)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                            }
                            .offset(x: 6, y: 6)
                        }
                        Text("Tap to change photo").font(.footnote).foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }

                Section("Name") {
                    TextField("First name", text: $firstName).textInputAutocapitalization(.words)
                    TextField("Last name (optional)", text: $lastName).textInputAutocapitalization(.words)
                }

                Section("Username") {
                    TextField("Username", text: $username).textInputAutocapitalization(.never).autocorrectionDisabled()
                    if !usernameSanitized.isEmpty && !isUsernameValid(usernameSanitized) {
                        Text("Use 3–20 letters, numbers or _. Don’t start with _.").font(.footnote).foregroundColor(.red)
                    }
                }

                Section("School") {
                    TextField("Your school", text: $school).textInputAutocapitalization(.words)
                }

                Section("Country & Age") {
                    Picker("Country", selection: $country) {
                        ForEach(countries, id: \.self) { Text($0).tag($0) }
                    }
                    if country == "Other" {
                        TextField("Enter your country", text: $customCountry).textInputAutocapitalization(.words)
                    }
                    Picker("Age", selection: $age) {
                        ForEach(8...100, id: \.self) { Text("\($0)") }
                    }
                }

                Section("About You") {
                    Picker("Favourite animal", selection: $favoriteAnimal) {
                        ForEach(animals, id: \.self) { Text($0).tag($0) }
                    }
                    if favoriteAnimal == "Other" {
                        TextField("Enter your favourite animal", text: $customAnimal)
                    }
                    Picker("Favourite colour", selection: $favoriteColor) {
                        ForEach(colors, id: \.self) { Text($0).tag($0) }
                    }
                    if favoriteColor == "Other" {
                        TextField("Enter your favourite colour", text: $customColor)
                    }
                    HStack {
                        Text("I like")
                        TextField("something...", text: $bioLikeTail)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let finalCountry = country == "Other" ? customCountry.trimmingCharacters(in: .whitespacesAndNewlines) : country
                        let finalAnimal = favoriteAnimal == "Other" ? customAnimal.trimmingCharacters(in: .whitespacesAndNewlines) : favoriteAnimal
                        let finalColor = favoriteColor == "Other" ? customColor.trimmingCharacters(in: .whitespacesAndNewlines) : favoriteColor
                        let profile = UserProfile(
                            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : lastName.trimmingCharacters(in: .whitespacesAndNewlines),
                            username: usernameSanitized,
                            school: school.trimmingCharacters(in: .whitespacesAndNewlines),
                            country: finalCountry,
                            age: age,
                            favoriteAnimal: finalAnimal,
                            favoriteColor: finalColor,
                            bioLine: "I like " + bioLikeTail.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                        onSave(profile, avatarImage)
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
            .onChange(of: pickerItem) { _ in loadPickedImage() }
        }
    }

    private func loadPickedImage() {
        guard let item = pickerItem else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self), let img = UIImage(data: data) {
                await MainActor.run { avatarImage = img }
            }
        }
    }

    private var isValid: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        isUsernameValid(usernameSanitized) &&
        !school.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !(country == "Other" && customCountry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) &&
        !(favoriteAnimal == "Other" && customAnimal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) &&
        !(favoriteColor == "Other" && customColor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) &&
        (8...100).contains(age) &&
        !bioLikeTail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var usernameSanitized: String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
        let filtered = username.unicodeScalars.filter { allowed.contains($0) }
        var result = String(String.UnicodeScalarView(filtered)).lowercased()
        if result.hasPrefix("_") { result.removeFirst() }
        return String(result.prefix(20))
    }

    private func isUsernameValid(_ u: String) -> Bool {
        guard u.count >= 3 else { return false }
        guard u.range(of: "^[a-z0-9_]{3,20}$", options: .regularExpression) != nil else { return false }
        guard !u.hasPrefix("_") else { return false }
        return true
    }
}

