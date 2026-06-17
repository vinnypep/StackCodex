import Foundation

struct MockSeedData: Sendable {
    let currentUserID = UUID(uuidString: "2DB1814B-145C-478F-A730-0D5F47EF6B93")!
    let isabellaID = UUID(uuidString: "796EF807-A099-42B0-B1BE-D5E16D0A7891")!
    let stackID = UUID(uuidString: "B19D9F63-938F-4AE2-8B7A-6569D2E5C63E")!

    var currentUser: UserProfile {
        UserProfile(
            id: currentUserID,
            displayName: "Owen Hacker",
            username: "owen",
            avatarURL: nil,
            bio: "Collecting beautiful, useful things.",
            linkInBioURL: URL(string: "https://stacks.example/owen"),
            isFollowing: false
        )
    }

    var isabella: UserProfile {
        UserProfile(
            id: isabellaID,
            displayName: "Isabella Martinez",
            username: "isabella",
            avatarURL: nil,
            bio: "Objects, jokes, and tiny visual obsessions.",
            linkInBioURL: URL(string: "https://stacks.example/isabella"),
            isFollowing: true
        )
    }

    var myStacks: [Stack] {
        [
            makeReferenceStack(owner: currentUser, title: "Hello", isMine: true),
            Stack(
                id: UUID(uuidString: "80DAB29E-6623-4D5F-82F8-3486808DE7A0")!,
                ownerID: currentUserID,
                author: currentUser,
                title: "Desk Dreams",
                summary: "The small things that make work feel smoother.",
                visibility: .publicDiscover,
                wishlistMode: false,
                collaborators: [],
                items: deskItems(stackID: UUID(uuidString: "80DAB29E-6623-4D5F-82F8-3486808DE7A0")!),
                createdAt: Date(timeIntervalSince1970: 1_775_580_000),
                updatedAt: Date(timeIntervalSince1970: 1_775_580_000),
                isBookmarked: false,
                isFollowingAuthor: false
            )
        ]
    }

    var discoverStacks: [Stack] {
        [
            makeReferenceStack(owner: isabella, title: "Hello", isMine: false),
            Stack(
                id: UUID(uuidString: "2F51A9C0-CFF0-4AEF-AD81-8139BFA33FC1")!,
                ownerID: isabellaID,
                author: isabella,
                title: "Good Luck Charms",
                summary: "Tiny things with strange confidence.",
                visibility: .publicDiscover,
                wishlistMode: true,
                collaborators: [],
                items: charmItems(stackID: UUID(uuidString: "2F51A9C0-CFF0-4AEF-AD81-8139BFA33FC1")!),
                createdAt: Date(timeIntervalSince1970: 1_775_493_000),
                updatedAt: Date(timeIntervalSince1970: 1_775_493_000),
                isBookmarked: true,
                isFollowingAuthor: true
            )
        ]
    }

    func makeReferenceStack(owner: UserProfile, title: String, isMine: Bool) -> Stack {
        Stack(
            id: isMine ? stackID : UUID(uuidString: "6056C082-B3A0-4E2E-BC46-F0EE5B782735")!,
            ownerID: owner.id,
            author: owner,
            title: title,
            summary: "A white canvas of background-removed stickers.",
            visibility: .publicDiscover,
            wishlistMode: false,
            collaborators: [],
            items: referenceItems(stackID: isMine ? stackID : UUID(uuidString: "6056C082-B3A0-4E2E-BC46-F0EE5B782735")!),
            createdAt: Date(timeIntervalSince1970: 1_775_232_000),
            updatedAt: Date(timeIntervalSince1970: 1_775_232_000),
            isBookmarked: !isMine,
            isFollowingAuthor: !isMine
        )
    }

    private func referenceItems(stackID: UUID) -> [StackItem] {
        [
            item(stackID: stackID, title: "Brooklyn Ball", brand: "Neighborhood Goods", price: 68, glyph: "🏀", x: 0.74, y: 0.11, scale: 1.25, rotation: -4, description: "A little courtside mythology, polished into a collectible that looks better floating than sitting still."),
            item(stackID: stackID, title: "Endless Illusion Patch", brand: "Studio Tape", price: 24, glyph: "🎟️", x: 0.35, y: 0.16, scale: 0.74, rotation: -2, description: "A wavy yellow banner with the kind of slogan that feels discovered, not designed."),
            item(stackID: stackID, title: "Tiny Banana Walker", brand: "Fruit Stand", price: 18, glyph: "🍌", x: 0.67, y: 0.32, scale: 0.72, rotation: 7, description: "Cheerfully strange, deeply unnecessary, and somehow exactly the thing the stack needed."),
            item(stackID: stackID, title: "Little Donkey", brand: "Pocket Zoo", price: 31, glyph: "🫏", x: 0.25, y: 0.32, scale: 0.88, rotation: -8, description: "A tiny character with enough attitude to hold a whole corner of the canvas."),
            item(stackID: stackID, title: "Live Laugh Dale Plate", brand: "Garage Sale", price: 42, glyph: "▬", x: 0.38, y: 0.47, scale: 0.9, rotation: -3, description: "A small black plate with a very specific energy and absolutely no interest in explaining itself."),
            item(stackID: stackID, title: "Score Button", brand: "Match Day", price: 12, glyph: "🔴", x: 0.75, y: 0.52, scale: 1.0, rotation: 2, description: "A badge for the heartbreak, the optimism, and the group chat afterward."),
            item(stackID: stackID, title: "Toy Head", brand: "Brick Bureau", price: 26, glyph: "🧱", x: 0.65, y: 0.67, scale: 0.82, rotation: 4, description: "A blocky little frown that says more about taste than a smile ever could."),
            item(stackID: stackID, title: "Driver License Card", brand: "Novelty Office", price: 17, glyph: "💳", x: 0.35, y: 0.72, scale: 1.0, rotation: -6, description: "A fake credential for a real sense of humor, crisp enough to earn its own shadow."),
            item(stackID: stackID, title: "Serious Man", brand: "Moodboard Supply", price: 54, glyph: "🕴️", x: 0.26, y: 0.88, scale: 1.08, rotation: -5, description: "All business, all sticker, and somehow the least practical purchase here."),
            item(stackID: stackID, title: "Happy Banana", brand: "Fruit Stand", price: 20, glyph: "🍌", x: 0.48, y: 0.86, scale: 0.88, rotation: 10, description: "A gentler banana, clearly here for morale and not logistics."),
            item(stackID: stackID, title: "Take It Easy Patch", brand: "Slow Goods", price: 29, glyph: "🐢", x: 0.73, y: 0.9, scale: 0.94, rotation: -7, description: "A soft reminder with sticker-shop confidence and a perfect amount of wobble.")
        ]
    }

    private func deskItems(stackID: UUID) -> [StackItem] {
        [
            item(stackID: stackID, title: "Chrome Task Lamp", brand: "Anglepoise", price: 160, glyph: "💡", x: 0.25, y: 0.22, scale: 1.1, rotation: -6, description: "A clean pool of light for late edits and early ideas."),
            item(stackID: stackID, title: "Dot Grid Notebook", brand: "Leuchtturm", price: 28, glyph: "📓", x: 0.68, y: 0.34, scale: 1.08, rotation: 7, description: "A quiet place to make messy thinking look intentional."),
            item(stackID: stackID, title: "Black Fountain Pen", brand: "Kaweco", price: 35, glyph: "🖋️", x: 0.42, y: 0.64, scale: 1.0, rotation: -12, description: "A tiny ritual for signing, sketching, and pretending emails are not real.")
        ]
    }

    private func charmItems(stackID: UUID) -> [StackItem] {
        [
            item(stackID: stackID, title: "Lucky Matchbook", brand: "Hotel Shop", price: 16, glyph: "🎫", x: 0.3, y: 0.2, scale: 0.9, rotation: -8, description: "A miniature souvenir that makes the whole table feel cinematic."),
            item(stackID: stackID, title: "Pearl Dice", brand: "Dice House", price: 44, glyph: "🎲", x: 0.7, y: 0.35, scale: 1.1, rotation: 10, description: "Glossy little odds, ready to make a shelf look luckier."),
            item(stackID: stackID, title: "Ribbon Pin", brand: "Ribbon Room", price: 22, glyph: "🎀", x: 0.45, y: 0.62, scale: 1.0, rotation: 3, description: "Sweet, graphic, and just sharp enough to keep the stack awake.")
        ]
    }

    private func item(
        stackID: UUID,
        title: String,
        brand: String,
        price: Decimal,
        glyph: String,
        x: Double,
        y: Double,
        scale: Double,
        rotation: Double,
        description: String
    ) -> StackItem {
        StackItem(
            id: UUID(),
            stackID: stackID,
            title: title,
            brand: brand,
            shortDescription: description,
            price: price,
            currencyCode: "USD",
            sourceURL: URL(string: "https://example.com/products/\(title.slugified)")!,
            buyURL: URL(string: "https://example.com/products/\(title.slugified)")!,
            affiliateURL: URL(string: "https://go.example.com/\(title.slugified)")!,
            originalImageURL: nil,
            removedBackgroundImageURL: nil,
            removalStatus: title == "Live Laugh Dale Plate" ? .processing : .complete,
            placement: StickerPlacement(xRatio: x, yRatio: y, scale: scale, rotationDegrees: rotation),
            addSource: .search,
            claimStatus: nil,
            demoGlyph: glyph
        )
    }
}

private extension String {
    var slugified: String {
        lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .filter { $0.isLetter || $0.isNumber || $0 == "-" }
    }
}
