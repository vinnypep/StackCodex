import SwiftUI

@main
struct StacksApp: App {
    @State private var session = AppSession(services: .mock())

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(session)
                .environment(\.appServices, session.services)
        }
    }
}

