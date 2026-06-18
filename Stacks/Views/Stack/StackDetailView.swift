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
                EditorialStackHeaderView(
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
                .padding(.horizontal, 24)
                .padding(.top, 18)

                EditorialProductGridView(items: viewModel.stack.items, onTap: onOpenProduct)
                    .padding(.horizontal, 24)
                    .padding(.top, 58)
                    .padding(.bottom, 56)
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

private struct EditorialStackHeaderView: View {
    let stack: Stack
    let isOwner: Bool
    let onAdd: () -> Void
    let onMore: () -> Void
    let onFollow: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 10) {
                Text(stack.title)
                    .font(.stacksDisplay(size: 88, weight: .black))
                    .foregroundStyle(Color.stacksInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.28)
                    .allowsTightening(true)

                Spacer(minLength: 0)

                HStack(spacing: 8) {
                    if isOwner {
                        Button(action: onAdd) {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(Color.stacksInk)
                                .frame(width: 38, height: 38)
                                .background(Color.black.opacity(0.055), in: Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Add item")
                    }

                    Button(action: onMore) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color.stacksInk)
                            .frame(width: 38, height: 38)
                            .background(Color.black.opacity(0.055), in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("More")
                }
                .padding(.top, 14)
            }

            Text(stackDescription)
                .font(.stacksText(size: 15, weight: .black))
                .foregroundStyle(Color.stacksInk)
                .textCase(.uppercase)
                .lineLimit(4)
                .minimumScaleFactor(0.72)
                .allowsTightening(true)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.trailing, 24)
        }
    }

    private var stackDescription: String {
        let cleanSummary = stack.summary.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanSummary.isEmpty {
            return "\(stack.author.displayName)'s curated stack of standout pieces, saved links, and favorite finds."
        }
        return cleanSummary
    }
}

private struct EditorialProductGridView: View {
    let items: [StackItem]
    let onTap: (StackItem) -> Void

    var body: some View {
        GeometryReader { proxy in
            let columnSpacing = max(18, proxy.size.width * 0.055)
            let rowSpacing = max(48, proxy.size.width * 0.14)
            let itemSize = max(68, (proxy.size.width - columnSpacing * 3) / 4)
            let columns = Array(
                repeating: GridItem(.flexible(minimum: 54, maximum: itemSize), spacing: columnSpacing, alignment: .center),
                count: 4
            )

            LazyVGrid(columns: columns, alignment: .center, spacing: rowSpacing) {
                ForEach(items) { item in
                    Button(action: { onTap(item) }) {
                        StickerImageView(item: item, size: min(138, itemSize * 1.22))
                            .rotationEffect(.degrees(0))
                            .frame(width: itemSize, height: itemSize * 1.18)
                    }
                    .buttonStyle(.plain)
                    .zIndex(item.removalStatus.isWorking ? 20 : 1)
                }
            }
        }
        .frame(minHeight: gridHeight)
    }

    private var gridHeight: CGFloat {
        let rows = max(1, Int(ceil(Double(items.count) / 4.0)))
        return CGFloat(rows) * 138 + CGFloat(max(0, rows - 1)) * 54
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
