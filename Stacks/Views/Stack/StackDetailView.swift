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
                    }
                )
                .padding(.horizontal, 20)
                .padding(.top, 18)

                EditorialProductGridView(items: viewModel.stack.items, onTap: onOpenProduct)
                    .padding(.horizontal, 22)
                    .padding(.top, 44)
                    .padding(.bottom, 64)
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

    var body: some View {
        VStack(spacing: 10) {
            Text(stack.title)
                .font(.stacksDisplay(size: 72, weight: .black))
                .foregroundStyle(Color.stacksInk)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.36)
                .allowsTightening(true)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, isOwner ? 92 : 52)

            Text(stackDescription)
                .font(.stacksText(size: 14, weight: .black))
                .foregroundStyle(Color.stacksInk)
                .multilineTextAlignment(.center)
                .textCase(.uppercase)
                .lineLimit(5)
                .minimumScaleFactor(0.78)
                .allowsTightening(true)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 430)
        }
        .frame(maxWidth: .infinity)
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 8) {
                if isOwner {
                    EditorialActionButton(systemImage: "plus", accessibilityLabel: "Add item", action: onAdd)
                }

                EditorialActionButton(systemImage: "ellipsis", accessibilityLabel: "More", action: onMore)
            }
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

private struct EditorialActionButton: View {
    let systemImage: String
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.stacksInk)
                .frame(width: 38, height: 38)
                .background(Color.black.opacity(0.055), in: Circle())
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

private struct EditorialProductGridView: View {
    let items: [StackItem]
    let onTap: (StackItem) -> Void

    private let columns = Array(
        repeating: GridItem(.flexible(minimum: 62), spacing: 22, alignment: .center),
        count: 4
    )

    var body: some View {
        LazyVGrid(columns: columns, alignment: .center, spacing: 46) {
            ForEach(items) { item in
                Button(action: { onTap(item) }) {
                    StickerImageView(item: item, size: 86)
                        .rotationEffect(.degrees(0))
                        .frame(maxWidth: .infinity)
                        .frame(height: 102)
                }
                .buttonStyle(.plain)
                .zIndex(item.removalStatus.isWorking ? 20 : 1)
            }
        }
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
