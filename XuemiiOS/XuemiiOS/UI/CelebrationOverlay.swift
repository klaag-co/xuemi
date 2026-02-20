import SwiftUI

struct CelebrationOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()
            VStack(spacing: 12) {
                Text("🔥 Streak +1!")
                    .font(.title2).bold()
                Text("You hit today’s goal — keep it going!")
                    .font(.subheadline).foregroundColor(.secondary)
                ConfettiView()
                    .frame(height: 120)
                    .allowsHitTesting(false)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(radius: 12)
            .padding(32)
        }
        .transition(.scale.combined(with: .opacity))
    }
}

