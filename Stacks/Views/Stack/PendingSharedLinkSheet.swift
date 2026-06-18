import SwiftUI

struct PendingSharedLinkSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appServices) private var services
    @State private var stacks: [Stack] = []
    @State private var isLoading = true
    @State private var isSaving = false
    @State private var errorMessage: String?

    let link: PendingSharedLink
    let user: UserProfile
    let onSaved: (Stack) -> Void

    var body: some View {
        NavigationStack {
            List {
                Section("Shared link") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(link.title ?? link.url.host ?? "Product link")
                            .font(.headline)
                        Text(link.url.absoluteString)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }

                Section("Save to Stack") {
                    if isLoading {
                        ProgressView("Loading Stacks")
                    } else if stacks.isEmpty {
                        ContentUnavailableView("No Stacks yet", systemImage: "square.stack.3d.up", description: Text("Create a Stack first, then share links into it."))
                    } else {
                        ForEach(stacks) { stack in
                            Button {
                                save(to: stack)
                            } label: {
                                HStack {
                                    Text(stack.displayTitle)
                                    Spacer()
                                    if isSaving {
                                        ProgressView()
                                    } else {
                                        Image(systemName: "plus.circle")
                                            .foregroundStyle(Color.stacksInk)
                                    }
                                }
                            }
                            .disabled(isSaving)
                        }
                    }
                }
            }
            .navigationTitle("Save to Stacks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        PendingSharedLinkStore.clear()
                        dismiss()
                    }
                }
            }
            .task {
                await loadStacks()
            }
            .alert("Could not save link", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func loadStacks() async {
        isLoading = true
        defer { isLoading = false }
        do {
            stacks = try await services.stacks.fetchMyStacks(for: user.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func save(to stack: Stack) {
        guard !isSaving else { return }
        isSaving = true
        Task {
            do {
                let item = try await services.productSearch.productFromPastedLink(
                    link.url,
                    stackID: stack.id,
                    placement: StickerPlacement(xRatio: 0.5, yRatio: 0.32, scale: 1, rotationDegrees: -4)
                )
                let updated = try await services.stacks.addItem(item, to: stack.id)
                PendingSharedLinkStore.clear()
                services.haptics.notification(.success)
                isSaving = false
                dismiss()
                onSaved(updated)
            } catch {
                isSaving = false
                errorMessage = error.localizedDescription
                services.haptics.notification(.error)
            }
        }
    }
}
