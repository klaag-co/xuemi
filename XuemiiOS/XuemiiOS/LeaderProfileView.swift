import SwiftUI

struct LeaderProfileView: View {
    let entry: LeaderboardEntry

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Avatar
                if let data = entry.avatarJPEGData, let img = UIImage(data: data) {
                    Image(uiImage: img)
                        .resizable().scaledToFill()
                        .frame(width: 96, height: 96)
                        .clipShape(Circle())
                        .shadow(radius: 6)
                } else {
                    ZStack {
                        Circle().fill(Color.orange.opacity(0.2))
                            .frame(width: 96, height: 96)
                        Text(entry.favoriteAnimal ?? "🙂").font(.largeTitle)
                    }
                }

                Text(entry.username).font(.title2).bold()

                VStack(alignment: .leading, spacing: 8) {
                    if let a = entry.favoriteAnimal, !a.isEmpty {
                        LabeledRow(icon: "pawprint.fill", label: "Favorite Animal", value: a)
                    }
                    if let c = entry.favoriteColor, !c.isEmpty {
                        LabeledRow(icon: "paintpalette.fill", label: "Favorite Color", value: c)
                    }
                    if let country = entry.country, !country.isEmpty {
                        LabeledRow(icon: "globe.asia.australia.fill", label: "Country", value: country)
                    }
                    if let school = entry.school, !school.isEmpty {
                        LabeledRow(icon: "building.columns.fill", label: "School", value: school)
                    }
                    if let bio = entry.bioLine, !bio.isEmpty {
                        LabeledRow(icon: "quote.bubble.fill", label: "About", value: bio)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 24)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct LabeledRow: View {
    let icon: String
    let label: String
    let value: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon).foregroundColor(.orange)
            Text(label).font(.subheadline).foregroundColor(.secondary)
            Spacer()
            Text(value).font(.body)
        }
    }
}

