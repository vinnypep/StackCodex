import SwiftUI

enum AppRoute: Hashable {
    case stack(Stack)
    case product(StackItem)
    case profile(UserProfile)
}

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case discover

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: "Stacks"
        case .discover: "Discover"
        }
    }

    var systemImage: String {
        switch self {
        case .home: "square.stack.3d.up"
        case .discover: "safari"
        }
    }
}

struct AppShellView: View {
    @Environment(AppSession.self) private var session
    @State private var selectedTab: AppTab = .home
    @State private var homePath: [AppRoute] = []
    @State private var discoverPath: [AppRoute] = []
    @State private var pendingSharedLink: PendingSharedLink?

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $homePath) {
                HomeView(
                    onOpenStack: { homePath.append(.stack($0)) },
                    onOpenProfile: { homePath.append(.profile($0)) }
                )
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
        }
        .tint(Color.stacksInk)
        .task {
            pendingSharedLink = PendingSharedLinkStore.load()
        }
        .onOpenURL { url in
            guard url.scheme == "stacks" else { return }
            selectedTab = .home
            pendingSharedLink = PendingSharedLinkStore.load()
        }
        .sheet(item: $pendingSharedLink) { link in
            if let user = session.currentUser {
                PendingSharedLinkSheet(link: link, user: user) { stack in
                    selectedTab = .home
                    homePath.append(.stack(stack))
                }
            }
        }
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
