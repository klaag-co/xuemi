import SwiftUI

struct LeaderboardView: View {
    @ObservedObject private var lb = LeaderboardManager.shared
    @State private var selected: LeaderboardEntry? = nil
    @State private var searchText: String = ""
    @State private var selectedColor: String? = nil
    @State private var selectedAnimal: String? = nil
    @State private var selectedCountry: String? = nil
    @State private var selectedSchool: String? = nil
    @State private var selectedAge: String? = nil

    private let countries = ["Singapore","Japan","Malaysia","Indonesia","Thailand","China","Hong Kong","Taiwan","Philippines","Vietnam","India","United States","United Kingdom","Australia","New Zealand","Other"]
    private let animals = ["Cat","Dog","Rabbit","Hamster","Bird","Fish","Turtle","Fox","Panda","Koala","Tiger","Lion","Dolphin","Whale","Otter","Other"]
    private let colors = ["Blue","Red","Yellow","Purple","Pink","Orange","Black","White","Grey","Cyan","Magenta","Brown","Teal","Indigo","Other"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                TextField("Search by username", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        Menu {
                            Button("All Colors") { selectedColor = nil }
                            ForEach(colors, id: \.self) { color in
                                Button(color) { selectedColor = color }
                            }
                        } label: {
                            FilterPill(title: selectedColor ?? "Color", systemImage: "paintpalette.fill", isActive: selectedColor != nil)
                        }
                        Menu {
                            Button("All Animals") { selectedAnimal = nil }
                            ForEach(animals, id: \.self) { animal in
                                Button(animal) { selectedAnimal = animal }
                            }
                        } label: {
                            FilterPill(title: selectedAnimal ?? "Animal", systemImage: "pawprint.fill", isActive: selectedAnimal != nil)
                        }
                        Menu {
                            Button("All Countries") { selectedCountry = nil }
                            ForEach(countries, id: \.self) { c in
                                Button(c) { selectedCountry = c }
                            }
                        } label: {
                            FilterPill(title: selectedCountry ?? "Country", systemImage: "globe.asia.australia.fill", isActive: selectedCountry != nil)
                        }
                        Menu {
                            Button("All Schools") { selectedSchool = nil }
                            ForEach(allSchools, id: \.self) { s in
                                Button(s) { selectedSchool = s }
                            }
                        } label: {
                            FilterPill(title: selectedSchool ?? "School", systemImage: "building.columns.fill", isActive: selectedSchool != nil)
                        }
                        Menu {
                            Button("All Ages") { selectedAge = nil }
                            ForEach(allAges, id: \.self) { a in
                                Button(a) { selectedAge = a }
                            }
                        } label: {
                            FilterPill(title: selectedAge ?? "Age", systemImage: "person.fill", isActive: selectedAge != nil)
                        }
                        Button { clearAllFilters() } label: {
                            FilterPill(title: "Clear", systemImage: "xmark.circle.fill", isActive: anyFilterActive)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)
                }
                List {
                    ForEach(Array(filteredEntries.enumerated()), id: \.element.id) { index, e in
                        Button { selected = e } label: {
                            HStack(spacing: 12) {
                                Text("#\(index + 1)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(width: 34, alignment: .trailing)
                                AvatarThumb(data: e.avatarJPEGData, placeholderEmoji: e.favoriteAnimal ?? "🙂")
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(e.username).font(.headline)
                                    Text("Streak \(e.streak) day\(e.streak == 1 ? "" : "s")")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Leaderboard")
            .sheet(item: $selected) { entry in
                LeaderProfileView(entry: entry)
            }
        }
    }

    var allSchools: [String] {
        Array(Set(lb.entries.compactMap { $0.school })).sorted()
    }
    var allAges: [String] {
        Array(Set(lb.entries.compactMap { $0.ageDescription })).sorted()
    }
    var anyFilterActive: Bool {
        selectedColor != nil || selectedAnimal != nil || selectedCountry != nil || selectedSchool != nil || selectedAge != nil || !searchText.isEmpty
    }
    func clearAllFilters() {
        selectedColor = nil
        selectedAnimal = nil
        selectedCountry = nil
        selectedSchool = nil
        selectedAge = nil
        searchText = ""
    }
    var filteredEntries: [LeaderboardEntry] {
        lb.entries.filter { entry in
            let matchesSearch  = searchText.isEmpty || entry.username.localizedCaseInsensitiveContains(searchText)
            let matchesColor   = selectedColor   == nil || entry.favoriteColor   == selectedColor
            let matchesAnimal  = selectedAnimal  == nil || entry.favoriteAnimal  == selectedAnimal
            let matchesCountry = selectedCountry == nil || entry.country         == selectedCountry
            let matchesSchool  = selectedSchool  == nil || entry.school          == selectedSchool
            let matchesAge     = selectedAge     == nil || entry.ageDescription  == selectedAge
            return matchesSearch && matchesColor && matchesAnimal && matchesCountry && matchesSchool && matchesAge
        }
    }
}

private struct FilterPill: View {
    let title: String
    let systemImage: String
    let isActive: Bool
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
            Text(title).lineLimit(1)
        }
        .font(.subheadline)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(isActive ? Color.orange.opacity(0.2) : Color(.systemGray6))
        .clipShape(Capsule())
    }
}

struct AvatarThumb: View {
    let data: Data?
    let placeholderEmoji: String
    var body: some View {
        Group {
            if let data, let img = UIImage(data: data) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Circle().fill(Color.orange.opacity(0.2))
                    Text(placeholderEmoji).font(.title3)
                }
            }
        }
        .frame(width: 36, height: 36)
        .clipShape(Circle())
    }
}

