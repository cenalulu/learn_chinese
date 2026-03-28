import SwiftUI
import SwiftData

@main
struct LearnChineseApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(
                for: Word.self, UserWordRecord.self, UserProfile.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(container)
    }
}

/// Handles first-launch seeding before showing the main UI.
struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var isReady = false

    var body: some View {
        Group {
            if isReady {
                ContentView()
            } else {
                // Brief loading state during seed
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Loading…")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .onAppear { seed() }
    }

    private func seed() {
        let profile: UserProfile
        if let existing = profiles.first {
            profile = existing
        } else {
            let new = UserProfile()
            modelContext.insert(new)
            profile = new
        }
        DataSeeder.seedIfNeeded(context: modelContext, profile: profile)
        isReady = true
    }
}
