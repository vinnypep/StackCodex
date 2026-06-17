import Foundation
import Observation

@MainActor
@Observable
final class AddItemViewModel {
    var query = ""
    var results: [ProductSearchResult] = []
    var pastedLink = ""
    var manualTitle = ""
    var manualLink = ""
    var selectedImageData: Data?
    var isLoading = false
    var errorMessage: String?

    func search(services: AppServices) async {
        let cleanQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanQuery.isEmpty else {
            results = []
            return
        }

        isLoading = true
        defer { isLoading = false }
        do {
            results = try await services.productSearch.searchProducts(query: cleanQuery)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
