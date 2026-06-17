import Foundation

struct SupabaseAuthService: AuthService {
    func restoreSession() async throws -> AuthSession? {
        throw AppError.configurationRequired("Supabase Auth")
    }

    func signInWithApple() async throws -> AuthSession {
        throw AppError.configurationRequired("Supabase Auth + Sign in with Apple")
    }

    func signInWithEmail(_ email: String) async throws -> AuthSession {
        throw AppError.configurationRequired("Supabase Auth email OTP")
    }

    func signOut() async throws {
        throw AppError.configurationRequired("Supabase Auth")
    }
}

struct SupabaseStackRepository: StackRepository {
    func fetchMyStacks(for userID: UUID) async throws -> [Stack] {
        throw AppError.configurationRequired("Supabase stacks table")
    }

    func fetchDiscoverStacks(query: String?) async throws -> [Stack] {
        throw AppError.configurationRequired("Supabase discover query")
    }

    func createStack(title: String, wishlistMode: Bool, owner: UserProfile) async throws -> Stack {
        throw AppError.configurationRequired("Supabase stacks insert")
    }

    func addItem(_ item: StackItem, to stackID: UUID) async throws -> Stack {
        throw AppError.configurationRequired("Supabase stack_items insert")
    }

    func updateItem(_ item: StackItem, in stackID: UUID) async throws -> Stack {
        throw AppError.configurationRequired("Supabase stack_items update")
    }

    func toggleBookmark(stackID: UUID, userID: UUID) async throws -> Stack {
        throw AppError.configurationRequired("Supabase bookmarks table")
    }

    func toggleFollow(authorID: UUID, userID: UUID) async throws -> [Stack] {
        throw AppError.configurationRequired("Supabase follows table")
    }
}

struct SupabaseProfileRepository: ProfileRepository {
    func currentProfile(for session: AuthSession) async throws -> UserProfile {
        throw AppError.configurationRequired("Supabase profiles table")
    }

    func suggestedCreators() async throws -> [UserProfile] {
        throw AppError.configurationRequired("Supabase suggested creators query")
    }
}

struct EdgeFunctionProductSearchService: ProductSearchService {
    func searchProducts(query: String) async throws -> [ProductSearchResult] {
        throw AppError.configurationRequired("product-search edge function")
    }

    func productFromPastedLink(_ url: URL, stackID: UUID, placement: StickerPlacement) async throws -> StackItem {
        throw AppError.configurationRequired("link-parser edge function")
    }
}

struct EdgeFunctionBackgroundRemovalService: BackgroundRemovalService {
    func removeBackground(for item: StackItem) async throws -> URL? {
        throw AppError.configurationRequired("Replicate rembg edge function")
    }
}

struct EdgeFunctionAffiliateService: AffiliateService {
    func affiliateURL(for url: URL) async throws -> URL {
        throw AppError.configurationRequired("Sovrn affiliate edge function")
    }
}

struct EdgeFunctionClaimService: ClaimService {
    func claim(item: StackItem, claimerName: String) async throws -> GiftClaim {
        throw AppError.configurationRequired("gift-claim edge function")
    }
}

struct SupabaseCollaborationService: CollaborationService {
    func invite(email: String, to stack: Stack) async throws -> Collaborator {
        throw AppError.configurationRequired("Supabase collaborators table")
    }
}

struct SupabaseStorageService: StorageService {
    func uploadImageData(_ data: Data, preferredName: String) async throws -> URL {
        throw AppError.configurationRequired("Supabase Storage")
    }
}

struct SupabaseRealtimeService: RealtimeService {
    func watchStack(id: UUID) async {}
    func stopWatchingStack(id: UUID) async {}
}

