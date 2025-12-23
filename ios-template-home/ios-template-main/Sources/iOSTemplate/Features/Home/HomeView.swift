import SwiftUI
import ComposableArchitecture

/// Home view - Main dashboard
public struct HomeView: View {
    let store: StoreOf<AppReducer>

    public init(store: StoreOf<AppReducer>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                // Header
                headerSection

                // Welcome Card
                welcomeCard

                // Quick Actions
                quickActionsSection

                // Recent Activity
                recentActivitySection

                Spacer()
            }
            .padding(Spacing.viewPadding)
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.large)
        .background(Color.theme.background)
    }

    // MARK: - Components

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Welcome back,")
                    .font(.theme.bodyMedium)
                    .foregroundColor(.theme.textSecondary)

                Text(store.user.profile?.name ?? "User")
                    .font(.theme.headlineLarge)
                    .foregroundColor(.theme.textPrimary)
            }

            Spacer()

            // Notification badge
            Button {
                // Handle notification tap
            } label: {
                Image(systemName: "bell.fill")
                    .font(.title3)
                    .foregroundColor(.theme.textPrimary)
            }
            .iconButton()
        }
    }

    private var welcomeCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundColor(.theme.primary)

                Text("Getting Started")
                    .font(.theme.headlineSmall)
                    .foregroundColor(.theme.textPrimary)

                Spacer()
            }

            Text("Explore the app features and customize your experience.")
                .font(.theme.bodyMedium)
                .foregroundColor(.theme.textSecondary)
                .lineLimit(2)

            Button("Get Started") {
                // Handle get started
            }
            .primaryButton()
        }
        .cardPadding()
        .background(Color.theme.surface)
        .cornerRadius(CornerRadius.card)
        .shadow(.md)
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Quick Actions")
                .font(.theme.titleLarge)
                .foregroundColor(.theme.textPrimary)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: Spacing.md),
                    GridItem(.flexible(), spacing: Spacing.md)
                ],
                spacing: Spacing.md
            ) {
                QuickActionCard(
                    icon: "square.and.arrow.up",
                    title: "Share",
                    color: .blue
                )

                QuickActionCard(
                    icon: "bookmark",
                    title: "Saved",
                    color: .green
                )

                QuickActionCard(
                    icon: "chart.bar",
                    title: "Analytics",
                    color: .orange
                )

                QuickActionCard(
                    icon: "person.2",
                    title: "Friends",
                    color: .purple
                )
            }
        }
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Recent Activity")
                    .font(.theme.titleLarge)
                    .foregroundColor(.theme.textPrimary)

                Spacer()

                Button("See All") {
                    // Handle see all
                }
                .tertiaryButton()
            }

            VStack(spacing: Spacing.sm) {
                ForEach(0..<3, id: \.self) { index in
                    ActivityRow(
                        icon: "checkmark.circle.fill",
                        title: "Activity \(index + 1)",
                        subtitle: "2 hours ago",
                        color: .green
                    )

                    if index < 2 {
                        Divider()
                    }
                }
            }
            .padding(Spacing.md)
            .background(Color.theme.surface)
            .cornerRadius(CornerRadius.card)
        }
    }
}

// MARK: - Quick Action Card

struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        Button {
            // Handle action
        } label: {
            VStack(spacing: Spacing.sm) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(color)
                    .cornerRadius(CornerRadius.md)

                Text(title)
                    .font(.theme.labelMedium)
                    .foregroundColor(.theme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(Spacing.md)
            .background(Color.theme.backgroundSecondary)
            .cornerRadius(CornerRadius.card)
        }
    }
}

// MARK: - Activity Row

struct ActivityRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(.theme.bodyMedium)
                    .foregroundColor(.theme.textPrimary)

                Text(subtitle)
                    .font(.theme.caption)
                    .foregroundColor(.theme.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.theme.textTertiary)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HomeView(
            store: Store(
                initialState: AppState(
                    user: UserState(
                        profile: UserProfile(
                            id: "123",
                            email: "test@example.com",
                            name: "John Doe"
                        )
                    )
                )
            ) {
                AppReducer()
            }
        )
    }
}
