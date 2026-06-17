import SwiftUI

struct ProfileView: View {
    @Environment(AppSession.self) private var session
    let profile: UserProfile

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text(profile.initials)
                        .font(.stacksDisplay(size: 44, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 110, height: 110)
                        .background(Color.stacksInk, in: Circle())

                    VStack(spacing: 6) {
                        Text(profile.displayName)
                            .font(.stacksDisplay(size: 36, weight: .bold))
                            .foregroundStyle(Color.stacksInk)
                        Text("@\(profile.username)")
                            .font(.stacksText(size: 17, weight: .semibold))
                            .foregroundStyle(Color.stacksMutedInk)
                    }

                    Text(profile.bio)
                        .font(.stacksText(size: 17))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.stacksInk.opacity(0.72))
                        .padding(.horizontal, 18)

                    if let url = profile.linkInBioURL {
                        Link(destination: url) {
                            Label("Open Creator Link", systemImage: "link")
                                .font(.stacksText(size: 16, weight: .bold))
                                .foregroundStyle(Color.stacksInk)
                                .padding(.horizontal, 18)
                                .frame(height: 48)
                                .stacksGlass(cornerRadius: 24, interactive: true)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 32, style: .continuous))

                VStack(alignment: .leading, spacing: 14) {
                    Text("Creator Tools")
                        .font(.stacksText(size: 20, weight: .bold))
                        .foregroundStyle(Color.stacksInk)

                    ListStyleRow(systemImage: "square.and.arrow.up", title: "Share link in bio")
                    ListStyleRow(systemImage: "person.2", title: "Collaborators")
                    ListStyleRow(systemImage: "gift", title: "Wishlist claims")
                }

                if session.currentUser?.id == profile.id {
                    Button(role: .destructive) {
                        Task { await session.signOut() }
                    } label: {
                        Text("Sign Out")
                            .font(.stacksText(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(20)
        }
        .background(Color.stacksCream.ignoresSafeArea())
        .navigationTitle(profile.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ListStyleRow: View {
    let systemImage: String
    let title: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.stacksInk)
                .frame(width: 42, height: 42)
                .background(.white.opacity(0.8), in: Circle())

            Text(title)
                .font(.stacksText(size: 17, weight: .semibold))
                .foregroundStyle(Color.stacksInk)

            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.stacksMutedInk)
        }
        .padding(16)
        .background(.white.opacity(0.68), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

