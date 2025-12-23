import SwiftUI
import ComposableArchitecture

/// Onboarding view - Reusable onboarding với configurable content
///
/// **Pattern: Parameterized Component**
///
/// View này được design để reuse cho nhiều apps khác nhau.
/// Mỗi app pass OnboardingConfig riêng với content và logic customize.
///
/// ## Usage:
/// ```swift
/// // App A - Banking
/// let bankingConfig = OnboardingConfig(
///     pages: [OnboardingPage(icon: "banknote", title: "Banking", ...)],
///     finalButtonText: "Start Banking",
///     onComplete: { ... }
/// )
/// OnboardingView(store: store, config: bankingConfig)
///
/// // App B - Fitness
/// let fitnessConfig = OnboardingConfig(
///     pages: [OnboardingPage(icon: "figure.run", title: "Fitness", ...)],
///     backgroundColor: .black,
///     finalButtonText: "Let's Go!",
///     onComplete: { ... }
/// )
/// OnboardingView(store: store, config: fitnessConfig)
/// ```
///
/// ## Customization:
/// - **Content**: Pages, titles, icons, colors
/// - **Behavior**: onComplete closure cho logic riêng
/// - **UI**: Background colors, button text
/// - **Features**: Show/hide skip button
///
public struct OnboardingView: View {
    // MARK: - Properties

    let store: StoreOf<AppReducer>
    let config: OnboardingConfig

    @State private var currentPage = 0

    // MARK: - Initialization

    /// Khởi tạo OnboardingView với custom config
    ///
    /// - Parameters:
    ///   - store: TCA Store
    ///   - config: OnboardingConfig customize cho app
    public init(store: StoreOf<AppReducer>, config: OnboardingConfig) {
        self.store = store
        self.config = config
    }

    /// Convenience init với default config
    ///
    /// Dùng khi không cần customize, sử dụng template default
    public init(store: StoreOf<AppReducer>) {
        self.store = store
        self.config = .default {
            store.send(AppAction.config(.updateFeatureFlag(key: "showOnboarding", value: false)))
        }
    }

    // MARK: - Body

    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                // Skip button (optional - theo config)
                if config.showSkipButton {
                    HStack {
                        Spacer()
                        Button(config.skipButtonText) {
                            completeOnboarding()
                        }
                        .tertiaryButton()
                    }
                    .padding()
                }

                // Page view với content từ config
                TabView(selection: $currentPage) {
                    ForEach(Array(config.pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                // Continue/Get Started button với text từ config
                Button(currentPage == config.pages.count - 1
                       ? config.finalButtonText
                       : config.continueButtonText) {
                    if currentPage < config.pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                }
                .primaryButton()
                .padding()
            }
            .background(config.backgroundColor)  // Background từ config
        }
    }

    // MARK: - Private Methods

    private func completeOnboarding() {
        // Gọi closure từ config - mỗi app có logic riêng
        config.onComplete()
    }
}

// MARK: - Onboarding Page View

/// View hiển thị mỗi onboarding page
struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: Spacing.xxxl) {
            Spacer()

            // Icon với gradient từ config
            Image(systemName: page.icon)
                .font(.system(size: 100))
                .foregroundColor(.white)
                .frame(width: 200, height: 200)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [page.color, page.color.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(.xl)

            // Content từ config
            VStack(spacing: Spacing.md) {
                Text(page.title)
                    .font(.theme.displayMedium)
                    .foregroundColor(.theme.textPrimary)

                Text(page.description)
                    .font(.theme.bodyLarge)
                    .foregroundColor(.theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xxxl)
            }

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview("Onboarding") {
    OnboardingView(
        store: Store(
            initialState: AppState()
        ) {
            AppReducer()
        },
        config: OnboardingConfig(
            pages: [
                OnboardingPage(
                    icon: "banknote",
                    title: "Secure Banking",
                    description: "Your money is safe with us",
                    color: .green
                ),
                OnboardingPage(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Track Expenses",
                    description: "Monitor your spending",
                    color: .blue
                )
            ],
            backgroundColor: Color.green.opacity(0.05),
            finalButtonText: "Start Banking",
            onComplete: {
                print("Banking onboarding completed")
            }
        )
    )
}
