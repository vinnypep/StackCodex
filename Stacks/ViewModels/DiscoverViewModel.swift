import Foundation
import Observation

@MainActor
@Observable
final class DiscoverViewModel {
    var query = ""
    var stacks: [Stack] = []
    var suggestedCreators: [UserProfile] = []
    var isLoading = false
    var errorMessage: String?

    func load(services: AppServices) async {
        await refresh(services: services, query: query)
        do {
            suggestedCreators = try await services.profiles.suggestedCreators()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refresh(services: AppServices, query: String? = nil) async {
        isLoading = true
        defer { isLoading = false }
        do {
            stacks = try await services.stacks.fetchDiscoverStacks(query: query)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleBookmark(stack: Stack, services: AppServices, user: UserProfile) async {
        do {
            let updated = try await services.stacks.toggleBookmark(stackID: stack.id, userID: user.id)
            replace(updated)
            services.haptics.impact(.medium)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleFollow(authorID: UUID, services: AppServices, user: UserProfile) async {
        do {
            stacks = try await services.stacks.toggleFollow(authorID: authorID, userID: user.id)
            services.haptics.impact(.medium)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func replace(_ stack: Stack) {
        guard let index = stacks.firstIndex(where: { $0.id == stack.id }) else { return }
        stacks[index] = stack
    }
}
