import SwiftUI

struct GlassCircleButton: View {
    let systemImage: String
    var accessibilityLabel: String
    var size: CGFloat = 52
    var iconSize: CGFloat = 20
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(Color.stacksInk)
                .frame(width: size, height: size)
                .background(Color.black.opacity(0.055), in: Circle())
                .stacksGlass(cornerRadius: size / 2, interactive: true)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}
