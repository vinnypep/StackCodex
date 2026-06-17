import Foundation

struct AuthSession: Codable, Hashable, Sendable {
    let userID: UUID
    var email: String?
    var displayName: String
    var hasCompletedOnboarding: Bool
}

