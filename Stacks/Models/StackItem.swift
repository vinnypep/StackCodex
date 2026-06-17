import Foundation

struct StackItem: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var stackID: UUID
    var title: String
    var brand: String
    var shortDescription: String
    var price: Decimal
    var currencyCode: String
    var sourceURL: URL
    var buyURL: URL
    var affiliateURL: URL?
    var originalImageURL: URL?
    var removedBackgroundImageURL: URL?
    var removalStatus: BackgroundRemovalStatus
    var placement: StickerPlacement
    var addSource: AddItemSource
    var claimStatus: GiftClaimStatus?
    var demoGlyph: String?

    var purchaseURL: URL {
        affiliateURL ?? buyURL
    }

    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 0
        return formatter.string(from: price as NSDecimalNumber) ?? "$\(price)"
    }
}

struct StickerPlacement: Codable, Hashable, Sendable {
    var xRatio: Double
    var yRatio: Double
    var scale: Double
    var rotationDegrees: Double

    static let centered = StickerPlacement(xRatio: 0.5, yRatio: 0.5, scale: 1, rotationDegrees: 0)
}

enum BackgroundRemovalStatus: String, Codable, CaseIterable, Hashable, Sendable {
    case queued
    case processing
    case complete
    case failed

    var isWorking: Bool {
        self == .queued || self == .processing
    }
}

enum AddItemSource: String, Codable, CaseIterable, Hashable, Sendable {
    case search
    case pastedLink
    case manualPhoto

    var title: String {
        switch self {
        case .search: "Search"
        case .pastedLink: "Paste Link"
        case .manualPhoto: "Take Picture"
        }
    }
}

