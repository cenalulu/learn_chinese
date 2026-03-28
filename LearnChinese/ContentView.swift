import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(AppTab.home)

            WordListView()
                .tabItem {
                    Label("Words", systemImage: "character.book.closed.fill")
                }
                .tag(AppTab.words)
        }
    }
}

enum AppTab: Hashable {
    case home, words
}
