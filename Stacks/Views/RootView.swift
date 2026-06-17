import SwiftUI

struct RootView: View {
    @Environment(AppSession.self) private var session

    var body: some View {
        Group {
            switch session.state {
            case .launching:
                LaunchView()
            case .signedOut, .onboarding:
                OnboardingView()
            case .signedIn:
                AppShellView()
            }
        }
        .task {
            if session.state == .launching {
                await session.restore()
            }
        }
    }
}

private struct LaunchView: View {
    var body: some View {
        ZStack {
            Color.stacksCream.ignoresSafeArea()
            VStack(spacing: 18) {
                ProgressView()
                    .tint(Color.stacksInk)
                Text("Stacks")
                    .font(.stacksDisplay(size: 40))
                    .foregroundStyle(Color.stacksInk)
            }
        }
    }
}

