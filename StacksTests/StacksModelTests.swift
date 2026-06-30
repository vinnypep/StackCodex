import XCTest
@testable import Stacks

final class StacksModelTests: XCTestCase {
    func testWishlistTitleAddsMarker() {
        let seed = MockSeedData()
        var stack = seed.myStacks[0]
        stack.wishlistMode = true

        XCTAssertEqual(stack.displayTitle, "Hello • Wishlist")
    }

    func testBackgroundRemovalWorkingStates() {
        XCTAssertTrue(BackgroundRemovalStatus.queued.isWorking)
        XCTAssertTrue(BackgroundRemovalStatus.processing.isWorking)
        XCTAssertFalse(BackgroundRemovalStatus.complete.isWorking)
        XCTAssertFalse(BackgroundRemovalStatus.failed.isWorking)
    }

    func testProductSearchResultCreatesProcessingStackItem() {
        let stackID = UUID()
        let result = ProductSearchResult(
            id: UUID(),
            title: "Lamp",
            brand: "Studio",
            price: 48,
            currencyCode: "USD",
            sourceURL: URL(string: "https://example.com/lamp")!,
            imageURL: nil,
            shortDescription: "A test lamp.",
            demoGlyph: "💡"
        )

        let item = result.makeStackItem(stackID: stackID, placement: .centered)

        XCTAssertEqual(item.stackID, stackID)
        XCTAssertEqual(item.title, "Lamp")
        XCTAssertEqual(item.removalStatus, .processing)
        XCTAssertEqual(item.addSource, .search)
        XCTAssertEqual(item.purchaseURL, item.buyURL)
    }

    func testMockRepositoryCreatesStack() async throws {
        let seed = MockSeedData()
        let repository = MockStackRepository(seed: seed)

        let stack = try await repository.createStack(
            title: "Birthday Ideas",
            wishlistMode: true,
            owner: seed.currentUser
        )

        XCTAssertEqual(stack.title, "Birthday Ideas")
        XCTAssertTrue(stack.wishlistMode)
        XCTAssertEqual(stack.ownerID, seed.currentUserID)
    }

    func testPendingSharedLinkStoreRoundTrips() throws {
        PendingSharedLinkStore.clear()
        let link = PendingSharedLink(url: URL(string: "https://example.com/jacket")!, title: "Jacket")

        try PendingSharedLinkStore.save(link)

        XCTAssertEqual(PendingSharedLinkStore.load(), link)
        PendingSharedLinkStore.clear()
        XCTAssertNil(PendingSharedLinkStore.load())
    }

    func testDiscoverSeedDataDoesNotStartWithProcessingSavedItems() {
        let seed = MockSeedData()
        let savedItems = seed.discoverStacks
            .filter(\.isBookmarked)
            .flatMap(\.items)

        XCTAssertFalse(savedItems.contains { $0.removalStatus.isWorking })
    }

    func testProductPageImageExtractorPrefersFrontWhiteProductImage() {
        let html = """
        <meta property="og:image" content="http://example.com/cdn/shop/files/lifestyle-scene.jpg">
        <img alt="Model wearing oven" src="https://example.com/cdn/shop/files/model-side.jpg">
        <img alt="Arc XL front facing product white background" src="https://example.com/cdn/shop/files/arc-xl-front-white-1200x1200.png">
        <img alt="Logo" src="https://example.com/logo.png">
        <img src="sizeImage(item.image, 800)">
        """

        let imageURL = ProductPageImageExtractor.bestImageURL(
            in: html,
            baseURL: URL(string: "https://example.com/products/arc-xl")!
        )

        XCTAssertEqual(
            imageURL?.absoluteString,
            "https://example.com/cdn/shop/files/arc-xl-front-white-1200x1200.png"
        )
    }
}
