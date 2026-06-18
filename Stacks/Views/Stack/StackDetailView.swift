import SwiftUI

private enum StackSheet: Identifiable {
    case addOptions
    case search
    case pasteLink
    case manualPhoto
    case more

    var id: String {
        switch self {
        case .addOptions: "addOptions"
        case .search: "search"
        case .pasteLink: "pasteLink"
        case .manualPhoto: "manualPhoto"
        case .more: "more"
        }
    }
}

struct StackDetailView: View {
    @Environment(AppSession.self) private var session
    @Environment(\.appServices) private var services
    @State private var viewModel: StackDetailViewModel
    @State private var sheet: StackSheet?

    let onOpenProduct: (StackItem) -> Void

    init(stack: Stack, onOpenProduct: @escaping (StackItem) -> Void) {
        _viewModel = State(initialValue: StackDetailViewModel(stack: stack))
        self.onOpenProduct = onOpenProduct
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                StackHeaderView(
                    stack: viewModel.stack,
                    isOwner: session.currentUser?.id == viewModel.stack.ownerID,
                    onAdd: {
                        services.haptics.impact(.medium)
                        sheet = .addOptions
                    },
                    onMore: {
                        services.haptics.impact(.light)
                        sheet = .more
                    },
                    onFollow: {
                        services.haptics.impact(.medium)
                    }
                )
                .padding(.horizontal, 28)
                .padding(.top, 28)

                StickerCanvasView(items: viewModel.stack.items, onTap: onOpenProduct)
                    .frame(height: 1060)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await services.realtime.watchStack(id: viewModel.stack.id)
            await viewModel.completeVisibleProcessingItems(services: services)
        }
        .onDisappear {
            Task { await services.realtime.stopWatchingStack(id: viewModel.stack.id) }
        }
        .sheet(item: $sheet) { destination in
            switch destination {
            case .addOptions:
                AddItemOptionsSheet { source in
                    switch source {
                    case .search: sheet = .search
                    case .pastedLink: sheet = .pasteLink
                    case .manualPhoto: sheet = .manualPhoto
                    }
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            case .search:
                SearchAddItemSheet { result in
                    await viewModel.addSearchResult(result, services: services)
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            case .pasteLink:
                PasteLinkAddItemSheet { link in
                    await viewModel.addPastedLink(link, services: services)
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            case .manualPhoto:
                ManualPhotoAddItemSheet { title, link, imageData in
                    await viewModel.addManualPhoto(title: title, link: link, imageData: imageData, services: services)
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            case .more:
                StackMoreSheet(stack: viewModel.stack)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
        .alert("Something went wrong", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

private struct StackHeaderView: View {
    let stack: Stack
    let isOwner: Bool
    let onAdd: () -> Void
    let onMore: () -> Void
    let onFollow: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .top, spacing: 16) {
                Text(stack.displayTitle)
                    .font(.stacksDisplay(size: 74, weight: .bold))
                    .foregroundStyle(Color.stacksInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.32)
                    .allowsTightening(true)

                Spacer(minLength: 8)

                HStack(spacing: 10) {
                    GlassCircleButton(systemImage: "plus", accessibilityLabel: "Add item", size: 52, iconSize: 20, action: onAdd)
                    GlassCircleButton(systemImage: "ellipsis", accessibilityLabel: "More", size: 52, iconSize: 20, action: onMore)
                }
            }

            HStack(alignment: .center, spacing: 10) {
                AvatarView(profile: stack.author, size: 30)

                Text(stack.author.displayName)
                    .font(.stacksText(size: 28, weight: .semibold))
                    .foregroundStyle(Color.stacksInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)

                Spacer()

                Text(stack.createdAt.stackHeaderDate)
                    .font(.stacksText(size: 22, weight: .regular))
                    .foregroundStyle(Color.stacksMutedInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Rectangle()
                .fill(Color.stacksDivider)
                .frame(height: 1)

            if !isOwner {
                BlackPillButton(
                    title: stack.isFollowingAuthor ? "Following" : "Follow",
                    systemImage: stack.isFollowingAuthor ? "checkmark" : "plus",
                    action: onFollow
                )
            }
        }
    }
}

private struct StickerCanvasView: View {
    let items: [StackItem]
    let onTap: (StackItem) -> Void

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                Color.white

                ForEach(items) { item in
                    Button {
                        onTap(item)
                    } label: {
                        StickerImageView(item: item, size: stickerSize(for: item, canvas: proxy.size))
                            .rotationEffect(.degrees(item.placement.rotationDegrees))
                    }
                    .buttonStyle(.plain)
                    .position(
                        x: proxy.size.width * item.placement.xRatio,
                        y: proxy.size.height * item.placement.yRatio
                    )
                    .zIndex(item.removalStatus.isWorking ? 20 : 1)
                }
            }
        }
    }

    private func stickerSize(for item: StackItem, canvas: CGSize) -> CGFloat {
        let base = min(canvas.width, 430) * 0.24
        return max(62, min(158, base * item.placement.scale))
    }
}

private struct StackMoreSheet: View {
    @Environment(\.dismiss) private var dismiss
    let stack: Stack

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        dismiss()
                    } label: {
                        Label("Share Stack", systemImage: "square.and.arrow.up")
                    }

                    Button {
                        dismiss()
                    } label: {
                        Label(stack.isBookmarked ? "Remove Bookmark" : "Bookmark", systemImage: stack.isBookmarked ? "bookmark.slash" : "bookmark")
                    }

                    Button {
                        dismiss()
                    } label: {
                        Label("Invite Collaborator", systemImage: "person.badge.plus")
                    }
                }
            }
            .navigationTitle("Stack Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
