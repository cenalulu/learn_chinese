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

            CourseMapView()
                .tabItem {
                    Label("Lessons", systemImage: "books.vertical.fill")
                }
                .tag(AppTab.lessons)

            WritingTabView()
                .tabItem {
                    Label("Writing", systemImage: "pencil.tip.crop.circle.fill")
                }
                .tag(AppTab.writing)

            WordListView()
                .tabItem {
                    Label("Words", systemImage: "character.book.closed.fill")
                }
                .tag(AppTab.words)
        }
    }
}

enum AppTab: Hashable {
    case home, lessons, writing, words
}
