import SwiftUI

struct StickerImageView: View {
    let item: StackItem
    var size: CGFloat = 118

    var body: some View {
        ZStack {
            stickerContent
                .frame(width: size, height: size)
                .padding(4)
                .background {
                    stickerHalo
                }
                .shadow(color: .black.opacity(0.16), radius: 10, x: 0, y: 8)
                .shadow(color: .white.opacity(0.85), radius: 2, x: 0, y: 0)

            if item.removalStatus.isWorking {
                RemovalShimmerView()
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .frame(width: size + 20, height: size + 20)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.title)
        .accessibilityHint(item.removalStatus.isWorking ? "Removing background" : "Open product")
    }

    @ViewBuilder
    private var stickerContent: some View {
        if let imageURL = item.removedBackgroundImageURL ?? item.originalImageURL {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure:
                    fallbackGlyph
                @unknown default:
                    fallbackGlyph
                }
            }
        } else {
            fallbackGlyph
        }
    }

    private var fallbackGlyph: some View {
        Text(item.demoGlyph ?? "◼")
            .font(.system(size: size * 0.6))
            .minimumScaleFactor(0.4)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var stickerHalo: some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(.white.opacity(item.removalStatus.isWorking ? 0.82 : 0.01))
            .blur(radius: item.removalStatus.isWorking ? 4 : 0)
    }
}

struct RemovalShimmerView: View {
    @State private var offset: CGFloat = -80

    var body: some View {
        LinearGradient(
            colors: [
                .white.opacity(0),
                .white.opacity(0.88),
                .white.opacity(0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 70)
        .offset(y: offset)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.15).repeatForever(autoreverses: true)) {
                offset = 80
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        }
    }
}

