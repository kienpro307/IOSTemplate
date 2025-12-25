import SwiftUI
import ComposableArchitecture
import UI

/// Home view - Main dashboard
public struct HomeView: View {
    @Perception.Bindable var store: StoreOf<HomeReducer>

    public init(store: StoreOf<HomeReducer>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
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
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .background(Color.theme.background)
            #if os(iOS)
            .refreshable {
                store.send(.refresh)
            }
            #endif
            .onAppear {
                store.send(.onAppear)
            }
        }
    }

    // MARK: - Components

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Welcome back,")
                    .font(.subheadline)
                    .foregroundColor(.theme.textSecondary)

                Text("User")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.theme.textPrimary)
            }

            Spacer()

            // Notification badge
            Button {
                store.send(.notificationTapped)
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
                    .font(.headline)
                    .foregroundColor(.theme.textPrimary)

                Spacer()
            }

            Text("Explore the app features and customize your experience.")
                .font(.body)
                .foregroundColor(.theme.textSecondary)
                .lineLimit(2)

            Button("Get Started") {
                store.send(.getStartedTapped)
            }
            .primaryButton()
        }
        .cardPadding()
        .background(Color.theme.surface)
        .cornerRadius(CornerRadius.card)
        .shadow(ShadowStyle.md)
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Quick Actions")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.theme.textPrimary)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: Spacing.md),
                    GridItem(.flexible(), spacing: Spacing.md)
                ],
                spacing: Spacing.md
            ) {
                ForEach(store.quickActions) { action in
                    QuickActionCard(
                        icon: action.icon,
                        title: action.title,
                        color: action.color
                    ) {
                        store.send(.quickActionTapped(action))
                    }
                }
            }
        }
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Recent Activity")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.theme.textPrimary)

                Spacer()

                Button("See All") {
                    store.send(.seeAllTapped)
                }
                .tertiaryButton()
            }

            VStack(spacing: Spacing.sm) {
                ForEach(Array(store.recentActivities.enumerated()), id: \.element.id) { index, activity in
                    ActivityRow(
                        icon: activity.icon,
                        title: activity.title,
                        subtitle: activity.subtitle,
                        color: activity.color
                    ) {
                        store.send(.activityTapped(activity))
                    }

                    if index < store.recentActivities.count - 1 {
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
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.sm) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(color)
                    .cornerRadius(CornerRadius.md)

                Text(title)
                    .font(.caption)
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
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.theme.textPrimary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.theme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.theme.textTertiary)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HomeView(
            store: Store(
                initialState: HomeState()
            ) {
                HomeReducer()
            }
        )
    }
}
