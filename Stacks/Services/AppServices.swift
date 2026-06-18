import SwiftUI
import UIKit

struct AppServices: @unchecked Sendable {
    let auth: any AuthService
    let stacks: any StackRepository
    let profiles: any ProfileRepository
    let productSearch: any ProductSearchService
    let backgroundRemoval: any BackgroundRemovalService
    let affiliate: any AffiliateService
    let claims: any ClaimService
    let collaboration: any CollaborationService
    let storage: any StorageService
    let realtime: any RealtimeService
    let haptics: HapticsService

    static func mock() -> AppServices {
        let seed = MockSeedData()
        let stackRepository = MockStackRepository(seed: seed)
        return AppServices(
            auth: MockAuthService(seed: seed),
            stacks: stackRepository,
            profiles: MockProfileRepository(seed: seed),
            productSearch: MockProductSearchService(),
            backgroundRemoval: AppleVisionBackgroundRemovalService(),
            affiliate: MockAffiliateService(),
            claims: MockClaimService(),
            collaboration: MockCollaborationService(seed: seed),
            storage: MockStorageService(),
            realtime: MockRealtimeService(),
            haptics: HapticsService()
        )
    }

    static func supabaseBackedPlaceholder() -> AppServices {
        AppServices(
            auth: SupabaseAuthService(),
            stacks: SupabaseStackRepository(),
            profiles: SupabaseProfileRepository(),
            productSearch: EdgeFunctionProductSearchService(),
            backgroundRemoval: AppleVisionBackgroundRemovalService(),
            affiliate: EdgeFunctionAffiliateService(),
            claims: EdgeFunctionClaimService(),
            collaboration: SupabaseCollaborationService(),
            storage: SupabaseStorageService(),
            realtime: SupabaseRealtimeService(),
            haptics: HapticsService()
        )
    }
}

private struct AppServicesKey: EnvironmentKey {
    nonisolated(unsafe) static var defaultValue: AppServices { .mock() }
}

extension EnvironmentValues {
    var appServices: AppServices {
        get { self[AppServicesKey.self] }
        set { self[AppServicesKey.self] = newValue }
    }
}

struct HapticsService: Sendable {
    @MainActor
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    @MainActor
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
