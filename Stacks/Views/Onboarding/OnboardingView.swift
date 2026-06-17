import SwiftUI

private enum OnboardingStage {
    case hero
    case interests
    case firstStack
}

private enum OnboardingSheet: Identifiable {
    case email

    var id: String { "email" }
}

struct OnboardingView: View {
    @Environment(AppSession.self) private var session
    @State private var stage: OnboardingStage = .hero
    @State private var sheet: OnboardingSheet?
    @State private var selectedInterests: Set<String> = []

    private let interests = ["Fashion", "Home", "Books", "Tech", "Gifts", "Art", "Travel", "Food"]

    var body: some View {
        ZStack {
            Color.stacksCream.ignoresSafeArea()

            switch stage {
            case .hero:
                hero
            case .interests:
                interestsView
            case .firstStack:
                firstStackPrompt
            }
        }
        .sheet(item: $sheet) { _ in
            EmailSignInSheet { email in
                await session.signInWithEmail(email)
                if case .onboarding = session.state {
                    stage = .interests
                }
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }

    private var hero: some View {
        VStack(spacing: 0) {
            AnimatedStickerCloud()
                .frame(height: 390)
                .padding(.top, 28)

            VStack(spacing: 22) {
                Text("Curate the things you love")
                    .font(.stacksDisplay(size: 56, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.stacksInk)
                    .lineSpacing(-4)
                    .minimumScaleFactor(0.78)

                Text("Build visual Stacks, save products, and share a link that feels like a tiny editorial page.")
                    .font(.stacksText(size: 18))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.stacksMutedInk)
                    .padding(.horizontal, 10)

                VStack(spacing: 12) {
                    PrimaryButton(title: "Continue with Apple", systemImage: "apple.logo") {
                        Task {
                            await session.signInWithApple()
                            if case .onboarding = session.state {
                                stage = .interests
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

    private var interestsView: some View {
        VStack(alignment: .leading, spacing: 28) {
            VStack(alignment: .leading, spacing: 10) {
                Text("What are you stacking?")
                    .font(.stacksDisplay(size: 42, weight: .bold))
                    .foregroundStyle(Color.stacksInk)
                Text("Pick a few lanes so Discover starts with the right mood.")
                    .font(.stacksText(size: 17))
                    .foregroundStyle(Color.stacksMutedInk)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(interests, id: \.self) { interest in
                    Button {
                        if selectedInterests.contains(interest) {
                            selectedInterests.remove(interest)
                        } else {
                            selectedInterests.insert(interest)
                        }
                    } label: {
                        HStack {
                            Text(interest)
                                .font(.stacksText(size: 18, weight: .semibold))
                            Spacer()
                            Image(systemName: selectedInterests.contains(interest) ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 22, weight: .semibold))
                        }
                        .foregroundStyle(Color.stacksInk)
                        .padding(18)
                        .frame(height: 78)
                        .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(selectedInterests.contains(interest) ? Color.stacksInk : .white.opacity(0.6), lineWidth: 1.5)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()

            PrimaryButton(title: "Continue") {
                stage = .firstStack
            }
        }
        .padding(24)
    }

    private var firstStackPrompt: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(.white.opacity(0.8))
                    .frame(width: 210, height: 210)
                    .stacksGlass(cornerRadius: 105)

                VStack(spacing: 10) {
                    Text("🏀")
                        .font(.system(size: 64))
                    Text("📓")
                        .font(.system(size: 54))
                        .offset(x: 48, y: -10)
                    Text("🍌")
                        .font(.system(size: 54))
                        .offset(x: -48, y: -18)
                }
            }

            Text("Start with one Stack")
                .font(.stacksDisplay(size: 46, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.stacksInk)

            Text("Your home screen opens with your own Stacks and a plus button for the next one.")
                .font(.stacksText(size: 18))
                .foregroundStyle(Color.stacksMutedInk)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 18)

            Spacer()

            PrimaryButton(title: "Open Stacks", systemImage: "arrow.right") {
                Task {
                    await session.completeOnboarding()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 28)
        }
    }
}

private struct AnimatedStickerCloud: View {
    @State private var isFloating = false

    private let stickers: [(String, CGFloat, CGFloat, CGFloat, Double)] = [
        ("🏀", -118, -18, 86, -6),
        ("💳", 80, -120, 70, 8),
        ("🍌", 112, 80, 76, -12),
        ("📓", -82, 104, 80, 5),
        ("💡", 0, 0, 86, 10),
        ("🧩", 6, -176, 68, -8)
    ]

    var body: some View {
        ZStack {
            ForEach(Array(stickers.enumerated()), id: \.offset) { index, sticker in
                Text(sticker.0)
                    .font(.system(size: sticker.3))
                    .frame(width: sticker.3 * 1.25, height: sticker.3 * 1.25)
                    .background(.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 10)
                    .rotationEffect(.degrees(sticker.4 + (isFloating ? 4 : -4)))
                    .offset(
                        x: sticker.1,
                        y: sticker.2 + (isFloating ? CGFloat(index.isMultiple(of: 2) ? -14 : 14) : CGFloat(index.isMultiple(of: 2) ? 10 : -10))
                    )
                    .animation(.easeInOut(duration: 2.4 + Double(index) * 0.12).repeatForever(autoreverses: true), value: isFloating)
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear { isFloating = true }
    }
}

