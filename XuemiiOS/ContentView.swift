import SwiftUI

struct ContentView: View {
    @StateObject private var bookmarkManager = BookmarkManager.shared
    @ObservedObject private var authmanager: AuthenticationManager = .shared
    @AppStorage("hasCompletedProfile") private var hasCompletedProfile = false
    @AppStorage("shouldShowOnboarding") private var shouldShowOnboarding = false
    @State private var showOnboarding = false

    var body: some View {
        ZStack {
            if authmanager.isLoggedIn == true {
                TabView {
                    HomeView().tabItem { Label("Home", systemImage: "house") }
                    BookmarkView().tabItem { Label("Bookmarks", systemImage: "bookmark") }
                    LeaderboardView().tabItem { Label("Leaderboard", systemImage: "medal") }
                    NotesView().tabItem { Label("Notes", systemImage: "doc.text") }
                    FolderView(vocabManager: VocabManager()).tabItem { Label("Vocabulary", systemImage: "pencil.and.list.clipboard") }
                }
                .environmentObject(bookmarkManager)
                .environmentObject(ProfileManager.shared)
                .environmentObject(ScoreManager.shared)    // ← provides chip + trends data
            } else if authmanager.isLoggedIn == false {
                LoginView()
            } else {
                ProgressView().controlSize(.large)
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            ProfileOnboardingView { profile in
                ProfileManager.shared.update(profile: profile, avatar: nil)
                hasCompletedProfile = true
                shouldShowOnboarding = false
                showOnboarding = false
            }
        }
        .task { evaluateOnboarding() }
        .onChange(of: authmanager.isLoggedIn) { _ in evaluateOnboarding() }
        .onChange(of: hasCompletedProfile) { _ in evaluateOnboarding() }
        .onChange(of: shouldShowOnboarding) { _ in evaluateOnboarding() }
    }

    private func evaluateOnboarding() {
        let loggedIn = authmanager.isLoggedIn ?? false
        if loggedIn && (!hasCompletedProfile || shouldShowOnboarding) {
            DispatchQueue.main.async { showOnboarding = true }
        } else {
            showOnboarding = false
        }
    }
}

#Preview { ContentView() }

