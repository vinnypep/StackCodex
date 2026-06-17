# Stacks

Stacks is a SwiftUI iOS 18+ wishlist and curation app. It opens through onboarding, then lets users create visual Stacks of background-removed product stickers, add items by search/link/photo, open product details with buy links, and discover/follow/bookmark other creators.

## Open in Xcode

1. Clone or download this repository.
2. Open `Stacks.xcodeproj`.
3. Select the `Stacks` scheme.
4. Choose an iOS 18+ simulator.
5. Run.

The current build uses mock services and demo data by default, so it does not need Supabase, Replicate, SerpAPI, Sovrn, or Apple developer credentials to launch in Simulator.

## Live Backend Swap

The app is already split behind protocols in `Stacks/Services`:

- `AuthService`
- `StackRepository`
- `ProfileRepository`
- `ProductSearchService`
- `BackgroundRemovalService`
- `AffiliateService`
- `ClaimService`
- `CollaborationService`
- `StorageService`
- `RealtimeService`

Replace `AppServices.mock()` in `StacksApp.swift` with `AppServices.supabaseBackedPlaceholder()` after implementing the Supabase and edge-function clients.

Starter Supabase Edge Function stubs live in `supabase/functions` for product search, link parsing, background removal, AI descriptions, affiliate wrapping, and web previews.

## Design Notes

- App background: warm cream `#F5F2ED`.
- Stack detail canvas: pure white, matching the supplied reference image.
- Product stickers use stable free positions, subtle shadows, white halo treatment, and a vertical shimmer while background removal is processing.
- Liquid Glass helpers are guarded for iOS 26+ and fall back to native materials.

## Font Note

Product descriptions call `InstrumentSerif-Italic` via `Font.custom`. Add the font file to the app target later if you want exact typography; iOS will otherwise fall back while preserving the italic treatment.
