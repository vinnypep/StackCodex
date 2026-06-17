import Foundation

struct Stack: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var ownerID: UUID
    var author: UserProfile
    var title: String
    var summary: String
    var visibility: StackVisibility
    var wishlistMode: Bool
    var collaborators: [Collaborator]
    var items: [StackItem]
    var createdAt: Date
    var updatedAt: Date
    var isBookmarked: Bool
    var isFollowingAuthor: Bool

    var displayTitle: String {
        wishlistMode ? "\(title) • Wishlist" : title
    }
}

enum StackVisibility: String, Codable, CaseIterable, Hashable, Sendable {
    case `private`
    case inviteOnly
    case publicLink
    case publicDiscover

    var title: String {
        switch self {
        case .private: "Private"
        case .inviteOnly: "Invite Only"
        case .publicLink: "Public Link"
        case .publicDiscover: "Discover"
        }
    }
}

