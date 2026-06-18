import SwiftUI

struct ProductDetailView: View {
    let item: StackItem

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                StickerImageView(item: item, size: 260)
                    .rotationEffect(.degrees(item.placement.rotationDegrees))
                    .padding(.top, 42)

                VStack(spacing: 18) {
                    Text(item.title)
                        .font(.stacksDisplay(size: 54, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.stacksInk)
                        .lineLimit(3)
                        .minimumScaleFactor(0.58)
                        .allowsTightening(true)

                    Text(item.shortDescription)
                        .font(.instrumentSerifItalic(size: 28))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.stacksInk.opacity(0.78))
                        .lineSpacing(4)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 22)
                .stacksGlass(cornerRadius: 30)
                .padding(.horizontal, 18)

                Link(destination: item.purchaseURL) {
                    GlassBuyButtonContent(price: item.formattedPrice)
                }
                .padding(.horizontal, 22)

                VStack(alignment: .leading, spacing: 12) {
                    DetailRow(label: "Source", value: item.sourceURL.host ?? item.sourceURL.absoluteString)
                    DetailRow(label: "Added by", value: item.addSource.title)
                    DetailRow(label: "Background", value: item.removalStatus.rawValue.capitalized)
                }
                .padding(18)
                .stacksGlass(cornerRadius: 24)
                .padding(.horizontal, 22)
            }
            .padding(.bottom, 34)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("Product")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct GlassBuyButtonContent: View {
    let price: String

    var body: some View {
        HStack {
            Text("Buy Now")
            Spacer()
            Text(price)
        }
        .font(.stacksText(size: 18, weight: .bold))
        .foregroundStyle(Color.stacksInk)
        .padding(.horizontal, 24)
        .frame(height: 62)
        .stacksGlass(cornerRadius: 31, interactive: true)
        .overlay {
            Capsule()
                .stroke(Color.stacksInk.opacity(0.16), lineWidth: 1)
        }
    }
}

private struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(Color.stacksMutedInk)
            Spacer()
            Text(value)
                .foregroundStyle(Color.stacksInk)
                .lineLimit(1)
        }
        .font(.stacksText(size: 15, weight: .medium))
    }
}
