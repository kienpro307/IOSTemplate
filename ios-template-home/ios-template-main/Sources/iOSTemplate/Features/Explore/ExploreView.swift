import SwiftUI
import ComposableArchitecture

/// Explore view - Discovery and search
public struct ExploreView: View {
    let store: StoreOf<AppReducer>
    @State private var searchText = ""

    public init(store: StoreOf<AppReducer>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                // Search suggestions
                searchSuggestionsSection

                // Categories
                categoriesSection

                // Trending
                trendingSection

                Spacer()
            }
            .padding(Spacing.viewPadding)
        }
        .navigationTitle("Explore")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Search...")
        .background(Color.theme.background)
    }

    // MARK: - Components

    private var searchSuggestionsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Popular Searches")
                .font(.theme.titleLarge)
                .foregroundColor(.theme.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(["Swift", "SwiftUI", "TCA", "iOS", "Design"], id: \.self) { tag in
                        TagChip(title: tag)
                    }
                }
            }
        }
    }

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Categories")
                .font(.theme.titleLarge)
                .foregroundColor(.theme.textPrimary)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: Spacing.md),
                    GridItem(.flexible(), spacing: Spacing.md)
                ],
                spacing: Spacing.md
            ) {
                CategoryCard(icon: "swift", title: "Development", color: .orange)
                CategoryCard(icon: "paintbrush", title: "Design", color: .pink)
                CategoryCard(icon: "book", title: "Learning", color: .blue)
                CategoryCard(icon: "briefcase", title: "Business", color: .green)
            }
        }
    }

    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Trending")
                .font(.theme.titleLarge)
                .foregroundColor(.theme.textPrimary)

            VStack(spacing: Spacing.md) {
                ForEach(0..<5, id: \.self) { index in
                    TrendingRow(
                        rank: index + 1,
                        title: "Trending Item \(index + 1)",
                        subtitle: "Category",
                        trend: index % 2 == 0 ? .up : .down
                    )
                }
            }
        }
    }
}

// MARK: - Tag Chip

struct TagChip: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.theme.labelMedium)
            .foregroundColor(.theme.primary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(Color.theme.primary.opacity(0.1))
            .cornerRadius(CornerRadius.chip)
    }
}

// MARK: - Category Card

struct CategoryCard: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        Button {
            // Handle category selection
        } label: {
            VStack(spacing: Spacing.md) {
                Image(systemName: icon)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .background(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text(title)
                    .font(.theme.titleMedium)
                    .foregroundColor(.theme.textPrimary)
                    .padding(.bottom, Spacing.sm)
            }
            .background(Color.theme.surface)
            .cornerRadius(CornerRadius.card)
            .shadow(.md)
        }
    }
}

// MARK: - Trending Row

struct TrendingRow: View {
    let rank: Int
    let title: String
    let subtitle: String
    let trend: Trend

    enum Trend {
        case up, down
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Rank
            Text("\(rank)")
                .font(.theme.titleLarge)
                .foregroundColor(.theme.textSecondary)
                .frame(width: 32)

            // Info
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(.theme.bodyLarge)
                    .foregroundColor(.theme.textPrimary)

                Text(subtitle)
                    .font(.theme.caption)
                    .foregroundColor(.theme.textSecondary)
            }

            Spacer()

            // Trend indicator
            HStack(spacing: 4) {
                Image(systemName: trend == .up ? "arrow.up" : "arrow.down")
                    .font(.caption)
                    .foregroundColor(trend == .up ? .green : .red)

                Text("\(Int.random(in: 10...50))%")
                    .font(.theme.caption)
                    .foregroundColor(trend == .up ? .green : .red)
            }
        }
        .padding(Spacing.md)
        .background(Color.theme.surface)
        .cornerRadius(CornerRadius.md)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ExploreView(
            store: Store(
                initialState: AppState()
            ) {
                AppReducer()
            }
        )
    }
}
