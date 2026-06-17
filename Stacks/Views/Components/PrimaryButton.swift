import SwiftUI

struct PrimaryButton: View {
    let title: String
    var systemImage: String?
    var isLoading = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 18, weight: .bold))
                }
                Text(title)
                    .font(.stacksText(size: 17, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .foregroundStyle(.white)
            .background(Color.stacksInk, in: Capsule())
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}

struct GlassButton: View {
    let title: String
    var systemImage: String?
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 17, weight: .semibold))
                }
                Text(title)
                    .font(.stacksText(size: 17, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .foregroundStyle(Color.stacksInk)
            .stacksGlass(cornerRadius: 29, interactive: true)
        }
        .buttonStyle(.plain)
    }
}

