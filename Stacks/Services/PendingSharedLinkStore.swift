import Foundation

struct PendingSharedLink: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var url: URL
    var title: String?
    var createdAt: Date

    init(id: UUID = UUID(), url: URL, title: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.url = url
        self.title = title
        self.createdAt = createdAt
    }
}

enum SharedImportConfiguration {
    static let appGroupID = "group.com.example.stacks"
    static let pendingLinkKey = "stacks.pendingSharedLink"
    static let callbackURL = URL(string: "stacks://shared-link")!
}

enum PendingSharedLinkStore {
    static func save(_ link: PendingSharedLink) throws {
        let data = try JSONEncoder().encode(link)
        defaults.set(data, forKey: SharedImportConfiguration.pendingLinkKey)
    }

    static func load() -> PendingSharedLink? {
        guard let data = defaults.data(forKey: SharedImportConfiguration.pendingLinkKey) else {
            return nil
        }
        return try? JSONDecoder().decode(PendingSharedLink.self, from: data)
    }

    static func clear() {
        defaults.removeObject(forKey: SharedImportConfiguration.pendingLinkKey)
    }

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: SharedImportConfiguration.appGroupID) ?? .standard
    }
}
