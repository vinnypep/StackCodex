import SwiftUI

struct GlassCircleButton: View {
    let systemImage: String
    var accessibilityLabel: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(Color.stacksInk)
                .frame(width: 64, height: 64)
                .background(Color.black.opacity(0.055), in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

