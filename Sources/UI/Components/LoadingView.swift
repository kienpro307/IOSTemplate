import SwiftUI

/// Loading indicator view với theme styling
public struct LoadingView: View {
    let message: String?
    let style: LoadingStyle

    public init(message: String? = nil, style: LoadingStyle = .default) {
        self.message = message
        self.style = style
    }

    public var body: some View {
        VStack(spacing: Spacing.md) {
            ProgressView()
                .progressViewStyle(style.progressViewStyle)
                .scaleEffect(style.scale)

            if let message = message {
                Text(message)
                    .font(.theme.bodyMedium)
                    .foregroundColor(.theme.textSecondary)
            }
        }
        .padding(Spacing.lg)
    }
}

// MARK: - Loading Style

/// Loading indicator style
public enum LoadingStyle {
    case `default`
    case large
    case small

    var progressViewStyle: some ProgressViewStyle {
        switch self {
        case .default, .large:
            return CircularProgressViewStyle(tint: .theme.primary)
        case .small:
            return CircularProgressViewStyle(tint: .theme.primary)
        }
    }

    var scale: CGFloat {
        switch self {
        case .default:
            return 1.0
        case .large:
            return 1.5
        case .small:
            return 0.7
        }
    }
}

// MARK: - View Extension

public extension View {
    /// Show loading overlay
    func loading(_ isLoading: Bool, message: String? = nil) -> some View {
        self.overlay {
            if isLoading {
                ZStack {
                    Color.theme.background.opacity(0.8)
                        .ignoresSafeArea()

                    LoadingView(message: message)
                        .padding()
                        .background(Color.theme.surface)
                        .cornerRadius(CornerRadius.lg)
                        .shadow(ShadowStyle.md)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Loading View") {
    VStack(spacing: Spacing.xl) {
        LoadingView()
        LoadingView(message: "Đang tải...")
        LoadingView(message: "Đang xử lý", style: .large)
    }
    .padding()
}

