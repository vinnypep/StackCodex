import SwiftUI

struct DiscoverView: View {
    @Environment(AppSession.self) private var session
    @Environment(\.appServices) private var services
    @State private var viewModel = DiscoverViewModel()

    let onOpenStack: (Stack) -> Void
    let onOpenProfile: (UserProfile) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Discover")
                        .font(.stacksDisplay(size: 44, weight: .bold))
                        .foregroundStyle(Color.stacksInk)
                    Text("Find creators, follow their Stacks, and bookmark the ones worth returning to.")
                        .font(.stacksText(size: 16))
                        .foregroundStyle(Color.stacksMutedInk)
                }

                savedStacks
                stackFeed
                suggestedCreators
            }
            .padding(20)
            .padding(.bottom, 24)
        }
        .background(Color.stacksCream.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .searchable(text: $viewModel.query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Username or Stack title")
        .onSubmit(of: .search) {
            Task { await viewModel.refresh(services: services, query: viewModel.query) }
        }
        .onChange(of: viewModel.query) { _, newValue in
            guard newValue.isEmpty else { return }
            Task { await viewModel.refresh(services: services) }
        }
        .task {
            await viewModel.load(services: services)
        }
        .refreshable {
            await viewModel.load(services: services)
        }
    }

    private var savedStacks: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Pinned / Saved")
                .font(.stacksText(size: 20, weight: .bold))
                .foregroundStyle(Color.stacksInk)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(viewModel.stacks.filter(\.isBookmarked)) { stack in
                        Button {
                            onOpenStack(stack)
                        } label: {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(stack.title)
                                    .font(.stacksDisplay(size: 23, weight: .bold))
                                    .foregroundStyle(Color.stacksInk)
                                    .lineLimit(1)

                                HStack(spacing: -8) {
                                    ForEach(stack.items.prefix(3)) { item in
                                        StickerImageView(item: item, size: 48)
                                    }
                                }

                                Text("@\(stack.author.username)")
                                    .font(.stacksText(size: 14, weight: .semibold))
                                    .foregroundStyle(Color.stacksMutedInk)
                            }
                            .frame(width: 178, alignment: .leading)
                            .padding(16)
                            .background(.white.opacity(0.76), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var stackFeed: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Stacks")
                .font(.stacksText(size: 20, weight: .bold))
                .foregroundStyle(Color.stacksInk)

            if viewModel.isLoading {
                LoadingRowsView()
            } else if viewModel.stacks.isEmpty {
                EmptyStateView(title: "No Stacks found", message: "Try another creator name or Stack title.", systemImage: "magnifyingglass")
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.stacks) { stack in
                        DiscoverStackRow(
                            stack: stack,
                            onOpen: { onOpenStack(stack) },
                            onProfile: { onOpenProfile(stack.author) },
                            onFollow: {
                                guard let user = session.currentUser else { return }
                                Task {
                                    await viewModel.toggleFollow(authorID: stack.author.id, services: services, user: user)
                                }
                            },
                            onBookmark: {
                                guard let user = session.currentUser else { return }
                                Task {
                                    await viewModel.toggleBookmark(stack: stack, services: services, user: user)
                                }
                            }
                        )
                    }
                }
            }
        }
    }

    private var suggestedCreators: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Suggested Users")
                .font(.stacksText(size: 20, weight: .bold))
                .foregroundStyle(Color.stacksInk)

            ForEach(viewModel.suggestedCreators) { creator in
                Button {
                    onOpenProfile(creator)
                } label: {
                    HStack(spacing: 14) {
                        Text(creator.initials)
                            .font(.stacksText(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 52, height: 52)
                            .background(Color.stacksInk, in: Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text(creator.displayName)
                                .font(.stacksText(size: 17, weight: .bold))
                                .foregroundStyle(Color.stacksInk)
                            Text("@\(creator.username)")
                                .font(.stacksText(size: 14, weight: .medium))
                                .foregroundStyle(Color.stacksMutedInk)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.stacksMutedInk)
                    }
                    .padding(16)
                    .background(.white.opacity(0.68), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct DiscoverStackRow: View {
    let stack: Stack
    let onOpen: () -> Void
    let onProfile: () -> Void
    let onFollow: () -> Void
    let onBookmark: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button(action: onOpen) {
                GeometryReader { proxy in
                    ZStack {
                        Color.white
                        ForEach(stack.items.prefix(5)) { item in
                            StickerImageView(item: item, size: 64)
                                .rotationEffect(.degrees(item.placement.rotationDegrees))
                                .position(
                                    x: proxy.size.width * item.placement.xRatio,
                                    y: proxy.size.height * item.placement.yRatio
                                )
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 170)
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            }
            .buttonStyle(.plain)

            HStack(alignment: .top, spacing: 12) {
                Button(action: onProfile) {
                    Text(stack.author.initials)
                        .font(.stacksText(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.stacksInk, in: Circle())
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 5) {
                    Text(stack.displayTitle)
                        .font(.stacksDisplay(size: 26, weight: .bold))
                        .foregroundStyle(Color.stacksInk)
                    Text("@\(stack.author.username) • \(stack.items.count) items")
                        .font(.stacksText(size: 14, weight: .medium))
                        .foregroundStyle(Color.stacksMutedInk)
                }

                Spacer()

                HStack(spacing: 10) {
                    Button(action: onBookmark) {
                        Image(systemName: stack.isBookmarked ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.stacksInk)
                            .frame(width: 42, height: 42)
                            .background(.white.opacity(0.85), in: Circle())
                    }
                    .buttonStyle(.plain)

                    Button(action: onFollow) {
                        Text(stack.isFollowingAuthor ? "Following" : "Follow")
                            .font(.stacksText(size: 14, weight: .bold))
                            .foregroundStyle(stack.isFollowingAuthor ? Color.stacksInk : .white)
                            .padding(.horizontal, 14)
                            .frame(height: 42)
                            .background(stack.isFollowingAuthor ? .white.opacity(0.85) : Color.stacksInk, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 32, style: .continuous))
    }
}
