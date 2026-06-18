import SwiftUI

private enum OnboardingStage: Equatable {
    case hero
    case saveAnything
    case stackIt
    case shareIt
    case firstStack
}

private enum OnboardingSheet: Identifiable {
    case email

    var id: String { "email" }
}

struct OnboardingView: View {
    @Environment(AppSession.self) private var session
    @Environment(\.appServices) private var services
    @State private var stage: OnboardingStage = .hero
    @State private var sheet: OnboardingSheet?
    @State private var firstStackTitle = ""
    @State private var firstItemTitle = ""
    @State private var firstItemLink = ""
    @State private var isCreatingFirstStack = false

    var body: some View {
        ZStack {
            Color.stacksCream.ignoresSafeArea()

            switch stage {
            case .hero:
                hero
            case .saveAnything:
                ExplainerScreen(
                    title: "Save anything",
                    visual: SaveAnythingVisual(),
                    primaryTitle: "Next",
                    onPrimary: { stage = .stackIt },
                    onSkip: completeOnboarding
                )
            case .stackIt:
                ExplainerScreen(
                    title: "Stack it.",
                    visual: StackItVisual(),
                    primaryTitle: "Next",
                    onPrimary: { stage = .shareIt },
                    onSkip: completeOnboarding
                )
            case .shareIt:
                ExplainerScreen(
                    title: "Share it",
                    visual: ShareItVisual(),
                    primaryTitle: "Make your first Stack",
                    onPrimary: { stage = .firstStack },
                    onSkip: completeOnboarding
                )
            case .firstStack:
                firstStackPrompt
            }
        }
        .sheet(item: $sheet) { _ in
            EmailSignInSheet { email in
                await session.signInWithEmail(email)
                if case .onboarding = session.state {
                    stage = .saveAnything
                }
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            if case .onboarding = session.state, stage == .hero {
                stage = .saveAnything
            }
        }
    }

    private var hero: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                ProductPhotoCloud()
                    .frame(height: min(max(proxy.size.height * 0.46, 286), 390))
                    .padding(.top, 20)

                VStack(spacing: 18) {
                    Text("Curate the things you love")
                        .font(.stacksDisplay(size: proxy.size.width < 380 ? 48 : 56, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.stacksInk)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                        .allowsTightening(true)
                        .frame(maxWidth: .infinity)

                    VStack(spacing: 12) {
                        PrimaryButton(title: "Continue with Apple", systemImage: "apple.logo") {
                            Task {
                                await session.signInWithApple()
                                if case .onboarding = session.state {
                                    stage = .saveAnything
                                }
                            }
                        }

                        GlassButton(title: "Continue with Email", systemImage: "envelope") {
                            sheet = .email
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
            }
        }
    }

    private var firstStackPrompt: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Stack name", text: $firstStackTitle)
                    TextField("First item name", text: $firstItemTitle)
                    TextField("Product link", text: $firstItemLink)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .textContentType(.URL)
                } header: {
                    Text("Make your first Stack")
                } footer: {
                    Text("Add one thing, name it, and save the link. You can share the finished Stack from inside the app.")
                }

                Section {
                    Button {
                        createFirstStack()
                    } label: {
                        HStack {
                            Text(isCreatingFirstStack ? "Creating" : "Create and Enter")
                            Spacer()
                            if isCreatingFirstStack {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isCreatingFirstStack)

                    Button("Skip for now") {
                        completeOnboarding()
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.stacksCream)
            .navigationTitle("First Stack")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private func createFirstStack() {
        guard !isCreatingFirstStack else { return }
        isCreatingFirstStack = true

        Task {
            do {
                guard case .onboarding(let authSession) = session.state else {
                    isCreatingFirstStack = false
                    return
                }

                let profile = try await services.profiles.currentProfile(for: authSession)
                let stack = try await services.stacks.createStack(
                    title: firstStackTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "First Stack" : firstStackTitle,
                    wishlistMode: false,
                    owner: profile
                )

                let cleanItemTitle = firstItemTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                if !cleanItemTitle.isEmpty,
                   let url = URL(string: firstItemLink),
                   url.scheme?.hasPrefix("http") == true {
                    let item = StackItem(
                        id: UUID(),
                        stackID: stack.id,
                        title: cleanItemTitle,
                        brand: "First Find",
                        shortDescription: "The first thing saved into this Stack.",
                        price: 0,
                        currencyCode: "USD",
                        sourceURL: url,
                        buyURL: url,
                        affiliateURL: try? await services.affiliate.affiliateURL(for: url),
                        originalImageURL: DemoProductImageCatalog.url(for: cleanItemTitle),
                        removedBackgroundImageURL: nil,
                        removalStatus: .complete,
                        placement: .centered,
                        addSource: .pastedLink,
                        claimStatus: nil,
                        demoGlyph: nil
                    )
                    _ = try await services.stacks.addItem(item, to: stack.id)
                }

                isCreatingFirstStack = false
                await session.completeOnboarding()
            } catch {
                isCreatingFirstStack = false
                await session.completeOnboarding()
            }
        }
    }

    private func completeOnboarding() {
        Task {
            await session.completeOnboarding()
        }
    }
}

private struct ExplainerScreen<Visual: View>: View {
    let title: String
    let visual: Visual
    let primaryTitle: String
    let onPrimary: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 18)

            visual
                .frame(maxWidth: .infinity)
                .frame(height: 430)
                .padding(.horizontal, 18)

            Text(title)
                .font(.stacksDisplay(size: 54, weight: .bold))
                .foregroundStyle(Color.stacksInk)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .allowsTightening(true)
                .padding(.horizontal, 24)
                .padding(.top, 8)

            Spacer(minLength: 18)

            VStack(spacing: 12) {
                PrimaryButton(title: primaryTitle, systemImage: "arrow.right", action: onPrimary)
                Button("Skip") {
                    onSkip()
                }
                .font(.stacksText(size: 16, weight: .semibold))
                .foregroundStyle(Color.stacksMutedInk)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
    }
}

private struct ProductPhotoCloud: View {
    @State private var isFloating = false

    private let items: [(String, CGFloat, CGFloat, CGFloat, Double)] = [
        ("Red Sneakers", -112, -34, 132, -7),
        ("Chrome Task Lamp", 92, -126, 116, 8),
        ("Dot Grid Notebook", 104, 76, 118, -10),
        ("Camera", -94, 96, 122, 6),
        ("Watch", 0, -2, 134, 11),
        ("Tote Bag", 8, -188, 102, -8)
    ]

    var body: some View {
        ZStack {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                ProductObjectImage(title: item.0)
                    .frame(width: item.3, height: item.3)
                    .padding(8)
                    .background(.white.opacity(0.64), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 10)
                    .rotationEffect(.degrees(item.4 + (isFloating ? 3 : -3)))
                    .offset(
                        x: item.1,
                        y: item.2 + (isFloating ? CGFloat(index.isMultiple(of: 2) ? -12 : 12) : CGFloat(index.isMultiple(of: 2) ? 8 : -8))
                    )
                    .animation(.easeInOut(duration: 2.4 + Double(index) * 0.1).repeatForever(autoreverses: true), value: isFloating)
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear { isFloating = true }
    }
}

private struct SaveAnythingVisual: View {
    var body: some View {
        VStack(spacing: 14) {
            SaveMethodRow(title: "Picture", systemImage: "camera.fill", objectTitle: "Red Sneakers")
            SaveMethodRow(title: "Link", systemImage: "link", objectTitle: "Watch")
            SaveMethodRow(title: "Share Sheet", systemImage: "square.and.arrow.up", objectTitle: "Camera")
        }
        .padding(.top, 42)
    }
}

private struct SaveMethodRow: View {
    let title: String
    let systemImage: String
    let objectTitle: String

    var body: some View {
        HStack(spacing: 16) {
            ProductObjectImage(title: objectTitle)
                .frame(width: 72, height: 72)
                .padding(8)
                .background(.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))

            Label(title, systemImage: systemImage)
                .font(.stacksText(size: 22, weight: .bold))
                .foregroundStyle(Color.stacksInk)

            Spacer()
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

private struct StackItVisual: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 22, x: 0, y: 12)

            Text("Stack")
                .font(.stacksDisplay(size: 48, weight: .bold))
                .foregroundStyle(Color.stacksInk)
                .position(x: 98, y: 70)

            ProductObjectImage(title: "Red Sneakers")
                .frame(width: 118, height: 118)
                .rotationEffect(.degrees(-9))
                .position(x: 116, y: 178)

            ProductObjectImage(title: "Chrome Task Lamp")
                .frame(width: 126, height: 126)
                .rotationEffect(.degrees(7))
                .position(x: 260, y: 220)

            ProductObjectImage(title: "Watch")
                .frame(width: 104, height: 104)
                .rotationEffect(.degrees(-4))
                .position(x: 188, y: 318)
        }
        .padding(.top, 30)
        .padding(.horizontal, 8)
    }
}

private struct ShareItVisual: View {
    var body: some View {
        VStack(spacing: 18) {
            HStack(spacing: 12) {
                Image(systemName: "message.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 58, height: 58)
                    .background(Color.stacksInk, in: Circle())

                VStack(alignment: .leading, spacing: 6) {
                    RoundedRectangle(cornerRadius: 7)
                        .fill(Color.stacksInk.opacity(0.84))
                        .frame(width: 188, height: 16)
                    RoundedRectangle(cornerRadius: 7)
                        .fill(Color.stacksInk.opacity(0.18))
                        .frame(width: 132, height: 14)
                }
                .padding(16)
                .background(.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            }

            HStack(spacing: 14) {
                MiniDiscoverCard(title: "Desk")
                MiniDiscoverCard(title: "Gifts")
            }
        }
        .padding(.top, 58)
    }
}

private struct MiniDiscoverCard: View {
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                Color.white
                ProductObjectImage(title: title == "Desk" ? "Chrome Task Lamp" : "Tote Bag")
                    .frame(width: 82, height: 82)
                    .rotationEffect(.degrees(title == "Desk" ? -8 : 9))
            }
            .frame(width: 142, height: 146)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            Text(title)
                .font(.stacksDisplay(size: 22, weight: .bold))
                .foregroundStyle(Color.stacksInk)
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
    }
}

private struct ProductObjectImage: View {
    let title: String

    var body: some View {
        AsyncImage(url: DemoProductImageCatalog.url(for: title)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
            case .empty:
                ProgressView()
                    .tint(Color.stacksInk)
            case .failure:
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(Color.stacksInk.opacity(0.72))
            @unknown default:
                EmptyView()
            }
        }
    }
}
