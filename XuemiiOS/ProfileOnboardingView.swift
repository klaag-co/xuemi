import SwiftUI

struct ProfileOnboardingView: View {
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
    @State private var bioTail: String = ""

    let onComplete: (UserProfile) -> Void

    private let countries = ["Singapore","Japan","Malaysia","Indonesia","Thailand","China","Hong Kong","Taiwan","Philippines","Vietnam","India","United States","United Kingdom","Australia","New Zealand","Other"]
    private let animals = ["Cat","Dog","Rabbit","Hamster","Bird","Fish","Turtle","Fox","Panda","Koala","Tiger","Lion","Dolphin","Whale","Otter","Other"]
    private let colors = ["Blue","Red","Green","Yellow","Purple","Pink","Orange","Black","White","Grey","Cyan","Magenta","Brown","Teal","Indigo","Other"]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Name")) {
                    TextField("First name", text: $firstName).textInputAutocapitalization(.words)
                    TextField("Last name (optional)", text: $lastName).textInputAutocapitalization(.words)
                }
                Section(header: Text("Username")) {
                    TextField("Username", text: $username).textInputAutocapitalization(.never).autocorrectionDisabled()
                    if !usernameSanitized.isEmpty && !isUsernameValid(usernameSanitized) {
                        Text("Use 3–20 letters, numbers or _. Don’t start with _.").font(.footnote).foregroundColor(.red)
                    }
                }
                Section(header: Text("School")) {
                    TextField("Your school", text: $school).textInputAutocapitalization(.words)
                }
                Section(header: Text("Country & Age")) {
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
                Section(header: Text("About You")) {
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
                        TextField("something...", text: $bioTail)
                    }
                }
            }
            .navigationTitle("Set up your profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Continue") {
                        let profile = UserProfile(
                            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : lastName.trimmingCharacters(in: .whitespacesAndNewlines),
                            username: usernameSanitized,
                            school: school.trimmingCharacters(in: .whitespacesAndNewlines),
                            country: country == "Other" ? customCountry.trimmingCharacters(in: .whitespacesAndNewlines) : country,
                            age: age,
                            favoriteAnimal: favoriteAnimal == "Other" ? customAnimal.trimmingCharacters(in: .whitespacesAndNewlines) : favoriteAnimal,
                            favoriteColor: favoriteColor == "Other" ? customColor.trimmingCharacters(in: .whitespacesAndNewlines) : favoriteColor,
                            bioLine: "I like " + bioTail.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                        onComplete(profile)
                        dismiss()
                    }
                    .disabled(!isValid)
                }
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
        !bioTail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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

