import SwiftUI

enum AppRoute: Hashable {
    case stack(Stack)
    case product(StackItem)
    case profile(UserProfile)
}

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case discover
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: "Home"
        case .discover: "Discover"
        case .profile: "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .home: "square.stack.3d.up"
        case .discover: "safari"
        case .profile: "person.crop.circle"
        }
    }
}

struct AppShellView: View {
    @Environment(AppSession.self) private var session
    @State private var selectedTab: AppTab = .home
    @State private var homePath: [AppRoute] = []
    @State private var discoverPath: [AppRoute] = []
    @State private var profilePath: [AppRoute] = []

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $homePath) {
                HomeView { stack in
                    homePath.append(.stack(stack))
                }
                .withAppDestinations(path: $homePath)
            }
            .tabItem {
                Label(AppTab.home.title, systemImage: AppTab.home.systemImage)
            }
            .tag(AppTab.home)

            NavigationStack(path: $discoverPath) {
                DiscoverView(
                    onOpenStack: { discoverPath.append(.stack($0)) },
                    onOpenProfile: { discoverPath.append(.profile($0)) }
                )
                .withAppDestinations(path: $discoverPath)
            }
            .tabItem {
                Label(AppTab.discover.title, systemImage: AppTab.discover.systemImage)
            }
            .tag(AppTab.discover)

            NavigationStack(path: $profilePath) {
                if let user = session.currentUser {
                    ProfileView(profile: user)
                        .withAppDestinations(path: $profilePath)
                }
            }
            .tabItem {
                Label(AppTab.profile.title, systemImage: AppTab.profile.systemImage)
            }
            .tag(AppTab.profile)
        }
        .tint(Color.stacksInk)
    }
}

private extension View {
    func withAppDestinations(path: Binding<[AppRoute]>) -> some View {
        navigationDestination(for: AppRoute.self) { route in
            switch route {
            case .stack(let stack):
                StackDetailView(stack: stack) { item in
                    path.wrappedValue.append(.product(item))
                }
            case .product(let item):
                ProductDetailView(item: item)
            case .profile(let profile):
                ProfileView(profile: profile)
            }
        }
    }
}

