import SwiftUI
import UIKit

struct AppServices {
    var auth: any AuthService
    var stacks: any StackRepository
    var profiles: any ProfileRepository
    var productSearch: any ProductSearchService
    var backgroundRemoval: any BackgroundRemovalService
    var affiliate: any AffiliateService
    var claims: any ClaimService
    var collaboration: any CollaborationService
    var storage: any StorageService
    var realtime: any RealtimeService
    var haptics: HapticsService

    static func mock() -> AppServices {
        let seed = MockSeedData()
        let stackRepository = MockStackRepository(seed: seed)
        return AppServices(
            auth: MockAuthService(seed: seed),
            stacks: stackRepository,
            profiles: MockProfileRepository(seed: seed),
            productSearch: MockProductSearchService(),
            backgroundRemoval: MockBackgroundRemovalService(),
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
            backgroundRemoval: EdgeFunctionBackgroundRemovalService(),
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
    static let defaultValue = AppServices.mock()
}

extension EnvironmentValues {
    var appServices: AppServices {
        get { self[AppServicesKey.self] }
        set { self[AppServicesKey.self] = newValue }
    }
}

final class HapticsService {
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
