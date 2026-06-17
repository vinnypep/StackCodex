import SwiftUI

struct LoadingRowsView: View {
    var body: some View {
        VStack(spacing: 14) {
            ForEach(0..<3, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.white.opacity(0.7))
                    .frame(height: 96)
                    .overlay(alignment: .leading) {
                        VStack(alignment: .leading, spacing: 10) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.black.opacity(0.08))
                                .frame(width: 140, height: 14)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.black.opacity(0.06))
                                .frame(width: 220, height: 12)
                        }
                        .padding()
                    }
            }
        }
        .redacted(reason: .placeholder)
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    var systemImage: String = "square.stack.3d.up"

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(Color.stacksInk.opacity(0.45))
            Text(title)
                .font(.stacksDisplay(size: 24, weight: .bold))
                .foregroundStyle(Color.stacksInk)
            Text(message)
                .font(.stacksText(size: 15))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.stacksMutedInk)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .stacksCard()
    }
}

