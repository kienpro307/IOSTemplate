import SwiftUI
import ComposableArchitecture

/// Profile view - User profile and stats
public struct ProfileView: View {
    let store: StoreOf<AppReducer>

    public init(store: StoreOf<AppReducer>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                // Profile header
                profileHeader

                // Stats
                statsSection

                // Actions
                actionsSection

                // Content sections
                contentSection

                Spacer()
            }
            .padding(Spacing.viewPadding)
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .background(Color.theme.background)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    // Edit profile
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
    }

    // MARK: - Components

    private var profileHeader: some View {
        VStack(spacing: Spacing.md) {
            // Avatar
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.theme.primary, .theme.secondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
                .overlay(
                    Text(store.user.profile?.name.prefix(1).uppercased() ?? "U")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                )

            // Name and email
            VStack(spacing: Spacing.xs) {
                Text(store.user.profile?.name ?? "User Name")
                    .font(.theme.headlineMedium)
                    .foregroundColor(.theme.textPrimary)

                Text(store.user.profile?.email ?? "user@example.com")
                    .font(.theme.bodyMedium)
                    .foregroundColor(.theme.textSecondary)
            }
        }
    }

    private var statsSection: some View {
        HStack(spacing: 0) {
            StatItem(value: "127", label: "Posts")
            Divider().frame(height: 40)
            StatItem(value: "1.2K", label: "Followers")
            Divider().frame(height: 40)
            StatItem(value: "345", label: "Following")
        }
        .padding(Spacing.lg)
        .background(Color.theme.surface)
        .cornerRadius(CornerRadius.card)
        .shadow(.md)
    }

    private var actionsSection: some View {
        VStack(spacing: Spacing.sm) {
            Button("Edit Profile") {
                // Handle edit
            }
            .primaryButton()

            Button("Share Profile") {
                // Handle share
            }
            .secondaryButton()
        }
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Activity")
                .font(.theme.titleLarge)
                .foregroundColor(.theme.textPrimary)

            VStack(spacing: Spacing.sm) {
                ProfileMenuItem(
                    icon: "heart.fill",
                    title: "Favorites",
                    subtitle: "24 items",
                    color: .red
                )

                ProfileMenuItem(
                    icon: "bookmark.fill",
                    title: "Saved",
                    subtitle: "12 items",
                    color: .orange
                )

                ProfileMenuItem(
                    icon: "clock.fill",
                    title: "History",
                    subtitle: "View all",
                    color: .blue
                )
            }
        }
    }
}

// MARK: - Stat Item

struct StatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Text(value)
                .font(.theme.titleLarge)
                .foregroundColor(.theme.textPrimary)

            Text(label)
                .font(.theme.caption)
                .foregroundColor(.theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Profile Menu Item

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        Button {
            // Handle menu item tap
        } label: {
            HStack(spacing: Spacing.md) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.1))
                    .cornerRadius(CornerRadius.sm)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(title)
                        .font(.theme.bodyLarge)
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
            .padding(Spacing.md)
            .background(Color.theme.surface)
            .cornerRadius(CornerRadius.md)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ProfileView(
            store: Store(
                initialState: AppState(
                    user: UserState(
                        profile: UserProfile(
                            id: "123",
                            email: "john.doe@example.com",
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
