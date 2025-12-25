import SwiftUI
import ComposableArchitecture
import UI

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

    @Perception.Bindable var store: StoreOf<OnboardingReducer>

    // MARK: - Initialization

    /// Khởi tạo OnboardingView với custom config
    ///
    /// - Parameters:
    ///   - store: TCA Store của OnboardingReducer
    public init(store: StoreOf<OnboardingReducer>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        WithPerceptionTracking {
            VStack(spacing: 0) {
                // Skip button (optional - theo config)
                if store.config.showSkipButton {
                    HStack {
                        Spacer()
                        Button(store.config.skipButtonText) {
                            store.send(.skip)
                        }
                        .tertiaryButton()
                    }
                    .padding(Spacing.lg)
                }

                // Page view với content từ config
                TabView(selection: Binding(
                    get: { store.currentPage },
                    set: { newPage in
                        store.send(.goToPage(newPage))
                    }
                )) {
                    ForEach(Array(store.config.pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                #if os(iOS)
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                #endif

                // Continue/Get Started button với text từ config
                Button(
                    store.currentPage == store.config.pages.count - 1
                        ? store.config.finalButtonText
                        : store.config.continueButtonText
                ) {
                    if store.currentPage < store.config.pages.count - 1 {
                        store.send(.nextPage)
                    } else {
                        store.send(.complete)
                    }
                }
                .primaryButton()
                .padding(Spacing.lg)
            }
            .background(store.config.backgroundColor)
        }
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
                .shadow(ShadowStyle.xl)

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
            initialState: OnboardingState(config: .default)
        ) {
            OnboardingReducer()
        }
    )
}

