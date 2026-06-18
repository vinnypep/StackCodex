import SwiftUI

private enum HomeSheet: Identifiable {
    case createStack

    var id: String { "createStack" }
}

struct HomeView: View {
    @Environment(AppSession.self) private var session
    @Environment(\.appServices) private var services
    @State private var viewModel = HomeViewModel()
    @State private var sheet: HomeSheet?

    let onOpenStack: (Stack) -> Void
    let onOpenProfile: (UserProfile) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                if viewModel.isLoading {
                    LoadingRowsView()
                } else if viewModel.stacks.isEmpty {
                    EmptyStateView(
                        title: "No Stacks yet",
                        message: "Tap plus to make your first wishlist or visual collection."
                    )
                } else {
                    WalletStackList(stacks: viewModel.stacks, onOpenStack: onOpenStack)
                }
            }
            .padding(20)
            .padding(.bottom, 24)
        }
        .background(Color.stacksCream.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            if let user = session.currentUser {
                await viewModel.load(services: services, user: user)
            }
        }
        .refreshable {
            if let user = session.currentUser {
                await viewModel.load(services: services, user: user)
            }
        }
        .sheet(item: $sheet) { _ in
            if let user = session.currentUser {
                CreateStackSheet(viewModel: viewModel, user: user) { stack in
                    onOpenStack(stack)
                }
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            Text("Stacks")
                .font(.stacksDisplay(size: 46, weight: .bold))
                .foregroundStyle(Color.stacksInk)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Spacer()

            HStack(spacing: 10) {
                if let user = session.currentUser {
                    Button {
                        services.haptics.impact(.light)
                        onOpenProfile(user)
                    } label: {
                        AvatarView(profile: user, size: 42)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Profile")
                }

                GlassCircleButton(systemImage: "plus", accessibilityLabel: "Create stack", size: 42, iconSize: 18) {
                    services.haptics.impact(.medium)
                    sheet = .createStack
                }
            }
            .padding(.top, 4)
        }
    }
}

private struct CreateStackSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appServices) private var services
    @Bindable var viewModel: HomeViewModel

    let user: UserProfile
    let onCreated: (Stack) -> Void

    var body: some View {
        NavigationStack {
            List {
                Section("Stack") {
                    TextField("Title", text: $viewModel.createTitle)
                    Toggle("Wishlist mode", isOn: $viewModel.createWishlistMode)
                }
            }
            .navigationTitle("New Stack")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Task {
                            if let stack = await viewModel.createStack(services: services, user: user) {
                                dismiss()
                                onCreated(stack)
                            }
                        }
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

private struct WalletStackList: View {
    let stacks: [Stack]
    let onOpenStack: (Stack) -> Void

    var body: some View {
        LazyVStack(spacing: -190) {
            ForEach(Array(stacks.enumerated()), id: \.element.id) { index, stack in
                WalletStackCardView(stack: stack) {
                    onOpenStack(stack)
                }
                .zIndex(Double(stacks.count - index))
            }
        }
        .padding(.top, 4)
        .padding(.bottom, CGFloat(max(stacks.count - 1, 0)) * 190 + 24)
    }
}

struct WalletStackCardView: View {
    let stack: Stack
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .firstTextBaseline) {
                    Text(stack.displayTitle)
                        .font(.stacksDisplay(size: 31, weight: .bold))
                        .foregroundStyle(Color.stacksInk)
                        .lineLimit(1)
                        .minimumScaleFactor(0.58)
                        .allowsTightening(true)

                    Spacer()

                    Image(systemName: stack.visibility == .private ? "lock.fill" : "globe")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.stacksMutedInk)
                }

                StackPreviewCanvas(items: stack.items)
                    .frame(height: 224)
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))

                Text("\(stack.items.count) items by \(stack.author.displayName)")
                    .font(.stacksText(size: 15, weight: .medium))
                    .foregroundStyle(Color.stacksMutedInk)
                    .lineLimit(1)
            }
            .padding(17)
            .frame(maxWidth: .infinity)
            .background(.white.opacity(0.84), in: RoundedRectangle(cornerRadius: 32, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(.white.opacity(0.8), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.08), radius: 24, x: 0, y: 14)
        }
        .buttonStyle(.plain)
    }
}

private struct StackPreviewCanvas: View {
    let items: [StackItem]

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.white
                ForEach(Array(items.prefix(6).enumerated()), id: \.element.id) { index, item in
                    StickerImageView(item: item, size: index == 0 ? 62 : 52)
                        .rotationEffect(.degrees(item.placement.rotationDegrees))
                        .position(
                            x: proxy.size.width * item.placement.xRatio,
                            y: proxy.size.height * item.placement.yRatio
                        )
                }
            }
        }
    }
}
