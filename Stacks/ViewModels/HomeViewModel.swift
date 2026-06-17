import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    var stacks: [Stack] = []
    var isLoading = false
    var errorMessage: String?
    var createTitle = ""
    var createWishlistMode = false

    func load(services: AppServices, user: UserProfile) async {
        isLoading = true
        defer { isLoading = false }
        do {
            stacks = try await services.stacks.fetchMyStacks(for: user.id)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createStack(services: AppServices, user: UserProfile) async -> Stack? {
        do {
            let stack = try await services.stacks.createStack(
                title: createTitle.isEmpty ? "Untitled Stack" : createTitle,
                wishlistMode: createWishlistMode,
                owner: user
            )
            stacks.insert(stack, at: 0)
            createTitle = ""
            createWishlistMode = false
            services.haptics.notification(.success)
            return stack
        } catch {
            errorMessage = error.localizedDescription
            services.haptics.notification(.error)
            return nil
        }
    }
}
