import PhotosUI
import SwiftUI

struct AddItemOptionsSheet: View {
    let onSelect: (AddItemSource) -> Void

    var body: some View {
        NavigationStack {
            List {
                Section("Add item to Stack") {
                    Button {
                        onSelect(.search)
                    } label: {
                        Label("Search", systemImage: "magnifyingglass")
                    }

                    Button {
                        onSelect(.pastedLink)
                    } label: {
                        Label("Paste Link", systemImage: "link")
                    }

                    Button {
                        onSelect(.manualPhoto)
                    } label: {
                        Label("Take Picture", systemImage: "camera")
                    }
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SearchAddItemSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appServices) private var services
    @State private var viewModel = AddItemViewModel()

    let onAdd: (ProductSearchResult) async -> Void

    var body: some View {
        NavigationStack {
            List {
                if viewModel.isLoading {
                    Section {
                        ProgressView("Searching")
                    }
                }

                Section {
                    ForEach(viewModel.results) { result in
                        Button {
                            Task {
                                await onAdd(result)
                                dismiss()
                            }
                        } label: {
                            HStack(spacing: 14) {
                                Text(result.demoGlyph ?? "🧩")
                                    .font(.system(size: 34))
                                    .frame(width: 52, height: 52)
                                    .background(Color.stacksCream, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                                VStack(alignment: .leading, spacing: 5) {
                                    Text(result.title)
                                        .font(.headline)
                                    Text("\(result.brand) • \(formattedPrice(result.price))")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $viewModel.query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search products")
            .onSubmit(of: .search) {
                Task { await viewModel.search(services: services) }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .overlay {
                if viewModel.results.isEmpty && !viewModel.isLoading {
                    ContentUnavailableView("Search products", systemImage: "magnifyingglass", description: Text("Find a product, then add it to the canvas."))
                }
            }
        }
    }

    private func formattedPrice(_ price: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: price as NSDecimalNumber) ?? "$\(price)"
    }
}

struct PasteLinkAddItemSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var link = ""
    @State private var isSaving = false

    let onAdd: (String) async -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Product link") {
                    TextField("https://", text: $link)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .textContentType(.URL)
                }

                Section {
                    Button {
                        save()
                    } label: {
                        HStack {
                            Text(isSaving ? "Adding" : "Add Link")
                            Spacer()
                            if isSaving { ProgressView() }
                        }
                    }
                    .disabled(isSaving)
                }
            }
            .navigationTitle("Paste Link")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func save() {
        guard !isSaving else { return }
        isSaving = true
        Task {
            await onAdd(link)
            isSaving = false
            dismiss()
        }
    }
}

struct ManualPhotoAddItemSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AddItemViewModel()
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isSaving = false

    let onAdd: (String, String, Data?) async -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Photo") {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label(viewModel.selectedImageData == nil ? "Take or Choose Picture" : "Picture Selected", systemImage: "camera")
                    }
                }

                Section("Details") {
                    TextField("Title", text: $viewModel.manualTitle)
                    TextField("Product link", text: $viewModel.manualLink)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .textContentType(.URL)
                }

                Section {
                    Button {
                        save()
                    } label: {
                        HStack {
                            Text(isSaving ? "Adding" : "Add Photo Item")
                            Spacer()
                            if isSaving { ProgressView() }
                        }
                    }
                    .disabled(isSaving)
                }
            }
            .navigationTitle("Take Picture")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task(id: selectedPhoto) {
                guard let selectedPhoto else { return }
                viewModel.selectedImageData = try? await selectedPhoto.loadTransferable(type: Data.self)
            }
        }
    }

    private func save() {
        guard !isSaving else { return }
        isSaving = true
        Task {
            await onAdd(viewModel.manualTitle, viewModel.manualLink, viewModel.selectedImageData)
            isSaving = false
            dismiss()
        }
    }
}
