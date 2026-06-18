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
        if let imageURL = item.removedBackgroundImageURL ?? item.originalImageURL ?? DemoProductImageCatalog.url(for: item.title) {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .tint(Color.stacksInk)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure:
                    fallbackObject
                @unknown default:
                    fallbackObject
                }
            }
        } else {
            fallbackObject
        }
    }

    private var fallbackObject: some View {
        Image(systemName: "shippingbox.fill")
            .font(.system(size: size * 0.48, weight: .semibold))
            .foregroundStyle(Color.stacksInk.opacity(0.72))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var stickerHalo: some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(.white.opacity(item.removalStatus.isWorking ? 0.82 : 0.01))
            .blur(radius: item.removalStatus.isWorking ? 4 : 0)
    }
}

enum DemoProductImageCatalog {
    static func url(for title: String) -> URL? {
        let lower = title.lowercased()
        let rawURL: String

        if lower.contains("shoe") || lower.contains("studio edition") {
            rawURL = "https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=520&q=80"
        } else if lower.contains("lamp") {
            rawURL = "https://images.unsplash.com/photo-1507473885765-e6ed057f782c?auto=format&fit=crop&w=520&q=80"
        } else if lower.contains("notebook") || lower.contains("book") {
            rawURL = "https://images.unsplash.com/photo-1517842645767-c639042777db?auto=format&fit=crop&w=520&q=80"
        } else if lower.contains("pen") {
            rawURL = "https://images.unsplash.com/photo-1583485088034-697b5bc54ccd?auto=format&fit=crop&w=520&q=80"
        } else if lower.contains("ball") {
            rawURL = "https://images.unsplash.com/photo-1519861531473-9200262188bf?auto=format&fit=crop&w=520&q=80"
        } else if lower.contains("banana") {
            rawURL = "https://images.unsplash.com/photo-1528825871115-3581a5387919?auto=format&fit=crop&w=520&q=80"
        } else if lower.contains("watch") {
            rawURL = "https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=520&q=80"
        } else if lower.contains("camera") || lower.contains("photo") {
            rawURL = "https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?auto=format&fit=crop&w=520&q=80"
        } else if lower.contains("patch") || lower.contains("pin") || lower.contains("button") || lower.contains("badge") {
            rawURL = "https://images.unsplash.com/photo-1523293182086-7651a899d37f?auto=format&fit=crop&w=520&q=80"
        } else if lower.contains("card") || lower.contains("license") {
            rawURL = "https://images.unsplash.com/photo-1556745757-8d76bdb6984b?auto=format&fit=crop&w=520&q=80"
        } else if lower.contains("dice") {
            rawURL = "https://images.unsplash.com/photo-1605870445919-838d190e8e1b?auto=format&fit=crop&w=520&q=80"
        } else if lower.contains("head") || lower.contains("toy") {
            rawURL = "https://images.unsplash.com/photo-1581235720704-06d3acfcb36f?auto=format&fit=crop&w=520&q=80"
        } else if lower.contains("man") || lower.contains("fashion") {
            rawURL = "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=520&q=80"
        } else if lower.contains("donkey") || lower.contains("charm") {
            rawURL = "https://images.unsplash.com/photo-1549366021-9f761d040a94?auto=format&fit=crop&w=520&q=80"
        } else {
            rawURL = "https://images.unsplash.com/photo-1544441893-675973e31985?auto=format&fit=crop&w=520&q=80"
        }

        return URL(string: rawURL)
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
