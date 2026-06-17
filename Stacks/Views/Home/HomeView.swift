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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                if viewModel.isLoading {
                    LoadingRowsView()
                } else if viewModel.stacks.isEmpty {
                    EmptyStateView(
                        title: "No Stacks yet",
                        message: "Tap plus to make your first wishlist or visual collection."
                    )
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.stacks) { stack in
                            StackCardView(stack: stack) {
                                onOpenStack(stack)
                            }
                        }
                    }
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
            VStack(alignment: .leading, spacing: 8) {
                Text("My Stacks")
                    .font(.stacksDisplay(size: 44, weight: .bold))
                    .foregroundStyle(Color.stacksInk)
                Text("Your wishlists, references, and beautiful little piles.")
                    .font(.stacksText(size: 16))
                    .foregroundStyle(Color.stacksMutedInk)
            }

            Spacer()

            GlassCircleButton(systemImage: "plus", accessibilityLabel: "Create stack") {
                services.haptics.impact(.medium)
                sheet = .createStack
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

                Section {
                    Button {
                        Task {
                            if let stack = await viewModel.createStack(services: services, user: user) {
                                dismiss()
                                onCreated(stack)
                            }
                        }
                    } label: {
                        Label("Create Stack", systemImage: "plus.circle.fill")
                    }
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
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

struct StackCardView: View {
    let stack: Stack
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                StackPreviewCanvas(items: stack.items)
                    .frame(height: 190)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(stack.displayTitle)
                            .font(.stacksDisplay(size: 28, weight: .bold))
                            .foregroundStyle(Color.stacksInk)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                        Spacer()
                        Image(systemName: stack.visibility == .private ? "lock.fill" : "globe")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.stacksMutedInk)
                    }

                    Text("\(stack.items.count) items by \(stack.author.displayName)")
                        .font(.stacksText(size: 15, weight: .medium))
                        .foregroundStyle(Color.stacksMutedInk)
                }
            }
            .padding(16)
            .background(.white.opacity(0.78), in: RoundedRectangle(cornerRadius: 32, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(.white.opacity(0.8), lineWidth: 1)
            }
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

