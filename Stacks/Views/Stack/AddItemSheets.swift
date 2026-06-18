import PhotosUI
import SwiftUI
import UIKit

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
                                ProductResultThumbnail(result: result)

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

private struct ProductResultThumbnail: View {
    let result: ProductSearchResult

    var body: some View {
        AsyncImage(url: result.imageURL ?? DemoProductImageCatalog.url(for: result.title)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
            case .empty:
                ProgressView()
                    .tint(Color.stacksInk)
            default:
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.stacksInk.opacity(0.7))
            }
        }
        .frame(width: 52, height: 52)
        .padding(6)
        .background(Color.stacksCream, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
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
    @State private var isShowingCamera = false
    @State private var isSaving = false

    let onAdd: (String, String, Data?) async -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Photo") {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        Button {
                            isShowingCamera = true
                        } label: {
                            Label("Take Picture", systemImage: "camera")
                        }
                    }

                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label(viewModel.selectedImageData == nil ? "Choose from Library" : "Picture Selected", systemImage: "photo.on.rectangle")
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
            .sheet(isPresented: $isShowingCamera) {
                CameraCaptureView(imageData: $viewModel.selectedImageData)
                    .ignoresSafeArea()
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

private struct CameraCaptureView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    @Binding var imageData: Data?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(imageData: $imageData, dismiss: dismiss)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding private var imageData: Data?
        private let dismiss: DismissAction

        init(imageData: Binding<Data?>, dismiss: DismissAction) {
            _imageData = imageData
            self.dismiss = dismiss
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                imageData = image.jpegData(compressionQuality: 0.9)
            }
            dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
        }
    }
}
