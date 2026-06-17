import SwiftUI

struct BlackPillButton: View {
    let title: String
    var systemImage: String?
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 25, weight: .medium))
                }
                Text(title)
                    .font(.stacksText(size: 26, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 32)
            .frame(height: 86)
            .background(Color.stacksInk, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

