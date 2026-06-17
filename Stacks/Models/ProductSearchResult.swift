import Foundation

struct ProductSearchResult: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var title: String
    var brand: String
    var price: Decimal
    var currencyCode: String
    var sourceURL: URL
    var imageURL: URL?
    var shortDescription: String
    var demoGlyph: String?

    func makeStackItem(stackID: UUID, placement: StickerPlacement) -> StackItem {
        StackItem(
            id: UUID(),
            stackID: stackID,
            title: title,
            brand: brand,
            shortDescription: shortDescription,
            price: price,
            currencyCode: currencyCode,
            sourceURL: sourceURL,
            buyURL: sourceURL,
            affiliateURL: nil,
            originalImageURL: imageURL,
            removedBackgroundImageURL: nil,
            removalStatus: .processing,
            placement: placement,
            addSource: .search,
            claimStatus: nil,
            demoGlyph: demoGlyph
        )
    }
}

