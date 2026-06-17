import SwiftUI

struct ProductDetailView: View {
    let item: StackItem

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.88))
                        .frame(width: 270, height: 270)
                        .stacksGlass(cornerRadius: 135)

                    StickerImageView(item: item, size: 220)
                        .rotationEffect(.degrees(item.placement.rotationDegrees))
                }
                .padding(.top, 34)

                VStack(spacing: 10) {
                    Text(item.brand)
                        .font(.stacksText(size: 15, weight: .semibold))
                        .textCase(.uppercase)
                        .tracking(1.2)
                        .foregroundStyle(Color.stacksMutedInk)

                    Text(item.title)
                        .font(.stacksDisplay(size: 38, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.stacksInk)
                        .lineLimit(3)
                        .minimumScaleFactor(0.72)

                    Text(item.shortDescription)
                        .font(.instrumentSerifItalic(size: 24))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.stacksInk.opacity(0.78))
                        .lineSpacing(4)
                        .padding(.top, 8)
                }
                .padding(.horizontal, 24)

                Link(destination: item.purchaseURL) {
                    HStack {
                        Text("Buy Now")
                        Spacer()
                        Text(item.formattedPrice)
                    }
                    .font(.stacksText(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .frame(height: 62)
                    .background(Color.stacksInk, in: Capsule())
                }
                .padding(.horizontal, 24)

                VStack(alignment: .leading, spacing: 12) {
                    DetailRow(label: "Source", value: item.sourceURL.host ?? item.sourceURL.absoluteString)
                    DetailRow(label: "Added by", value: item.addSource.title)
                    DetailRow(label: "Background", value: item.removalStatus.rawValue.capitalized)
                }
                .padding(18)
                .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 34)
        }
        .background(Color.stacksCream.ignoresSafeArea())
        .navigationTitle("Product")
        .navigationBarTitleDisplayMode(.inline)
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

