# Explore - Discovery & Search

## Tổng quan

Thư mục `Explore/` chứa **discovery và search features** của ứng dụng. Đây là nơi users khám phá content mới, search, browse categories, và xem trending items.

### Chức năng chính
- Search functionality với searchable modifier
- Popular search suggestions
- Category browsing
- Trending content ranking
- Tag-based filtering
- Discovery recommendations

### Tác động đến toàn bộ app
- **Medium Impact**: Content discovery hub
- Enable users tìm kiếm content
- Drive engagement với trending và categories
- Support content exploration
- Tab thứ 2 trong MainTabView

---

## Cấu trúc Files

```
Explore/
└── ExploreView.swift        # Explore screen (210 dòng)
```

**Tổng cộng**: 1 file, 210 dòng code

---

## Chi tiết File: ExploreView.swift (210 dòng)

### Component Overview

```swift
public struct ExploreView: View {
    @Bindable var store: StoreOf<AppReducer>
    @State private var searchText = ""

    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                searchSuggestionsSection
                categoriesSection
                trendingSection
                Spacer()
            }
            .padding(Spacing.viewPadding)
        }
        .navigationTitle("Explore")
        .searchable(text: $searchText, prompt: "Search...")
        .background(Color.theme.background)
    }
}
```

### Local State (dòng 7)

```swift
@State private var searchText = ""
```

**Purpose**:
- Track search input
- Bind to `.searchable()` modifier
- Filter/trigger search on change

---

## UI Sections

### 1. Search Suggestions Section (dòng 37-50)

```swift
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
```

#### Visual Structure

```
Popular Searches

┌──────────────────────────────────────┐
│  Swift   SwiftUI   TCA   iOS  Design │ → Scrollable
└──────────────────────────────────────┘
```

**Popular Tags**:
- Swift
- SwiftUI
- TCA
- iOS
- Design

**Interaction**:
- Horizontal scroll
- Tap tag → Trigger search (TODO)

**Current Implementation**: Static tag list

**Future Enhancement**:
```swift
// Dynamic tags from API
@State private var popularTags: [String] = []

.task {
    popularTags = try await networkService.request(.getPopularSearches())
}
```

---

### 2. Categories Section (dòng 52-71)

```swift
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
```

#### Grid Layout

```
Categories

┌─────────────┬─────────────┐
│ Development │   Design    │
│     Swift   │ Paintbrush  │
│   Orange    │    Pink     │
├─────────────┼─────────────┤
│  Learning   │  Business   │
│    Book     │  Briefcase  │
│    Blue     │   Green     │
└─────────────┴─────────────┘
```

**Categories**:
1. **Development** - Orange, Swift icon
2. **Design** - Pink, Paintbrush icon
3. **Learning** - Blue, Book icon
4. **Business** - Green, Briefcase icon

**Grid**: 2 columns, flexible width

**Interaction**: Tap category → Browse content (TODO)

---

### 3. Trending Section (dòng 73-91)

```swift
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
```

#### Visual Structure

```
Trending

┌──────────────────────────────────┐
│ 1  Trending Item 1         ↑ 42% │
│    Category                      │
├──────────────────────────────────┤
│ 2  Trending Item 2         ↓ 23% │
│    Category                      │
├──────────────────────────────────┤
│ 3  Trending Item 3         ↑ 35% │
│    Category                      │
└──────────────────────────────────┘
```

**Trending Items**:
- Rank: 1-5
- Title: "Trending Item [N]"
- Subtitle: "Category"
- Trend: Alternating up/down (mock)

**Mock Logic**:
```swift
trend: index % 2 == 0 ? .up : .down
// Even index (0, 2, 4) → Up
// Odd index (1, 3) → Down
```

**Future Enhancement**: Real trend data từ API

---

## Reusable Components

### TagChip (dòng 96-108)

```swift
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
```

**Visual**:
```
┌─────────┐
│  Swift  │  ← Pill-shaped chip
└─────────┘
```

**Styling**:
- Primary text color
- Primary background (10% opacity)
- Chip corner radius (20pt)
- Horizontal/vertical padding

**Usage**:
```swift
TagChip(title: "SwiftUI")
TagChip(title: "iOS")
```

---

### CategoryCard (dòng 112-144)

```swift
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
```

**Visual**:
```
┌───────────────┐
│               │
│      📱       │  ← Gradient background
│               │     100pt height
│               │
├───────────────┤
│ Development   │  ← Title
└───────────────┘
```

**Gradient**:
- Start: Full color opacity
- End: 70% color opacity
- Direction: Top-left to bottom-right

**Components**:
- Top: Icon với gradient background
- Bottom: Title text
- Entire card clickable

**Action**: TODO - Handle category selection (Line 119)

---

### TrendingRow (dòng 149-194)

```swift
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
```

**Visual**:
```
┌────────────────────────────────────┐
│ 1   Trending Item 1          ↑ 42% │
│     Category                       │
└────────────────────────────────────┘
```

**Layout**:
- Leading: Rank number (fixed 32pt width)
- Center: Title + subtitle (vertical stack)
- Trailing: Trend arrow + percentage

**Trend Indicator**:
- **Up**: Green arrow + percentage
- **Down**: Red arrow + percentage

**Mock Percentage**:
```swift
Text("\(Int.random(in: 10...50))%")
```
- Random 10-50%
- Changes each render (not ideal for production)

**Future Enhancement**: Real trend percentage từ data

---

## Search Functionality

### Searchable Modifier (dòng 31)

```swift
.searchable(text: $searchText, prompt: "Search...")
```

**Features**:
- Native iOS search bar
- Two-way binding to `searchText`
- Placeholder: "Search..."
- Keyboard appears on tap

### Search Implementation (TODO)

**Current**: Search bar exists but no search logic

**Proper Implementation**:
```swift
@State private var searchText = ""
@State private var searchResults: [SearchResult] = []
@State private var isSearching = false

var body: some View {
    // ...
}
.searchable(text: $searchText, prompt: "Search...")
.onChange(of: searchText) { oldValue, newValue in
    performSearch(query: newValue)
}

private func performSearch(query: String) {
    guard !query.isEmpty else {
        searchResults = []
        return
    }

    isSearching = true

    Task {
        do {
            let results: [SearchResult] = try await networkService.request(
                .search(query: query, page: 1)
            )
            searchResults = results
        } catch {
            // Handle error
        }
        isSearching = false
    }
}
```

**Search Results Display**:
```swift
if !searchText.isEmpty {
    // Show search results
    SearchResultsView(results: searchResults, isLoading: isSearching)
} else {
    // Show explore content
    ScrollView {
        // Existing sections
    }
}
```

---

## Integration với Core Layer

### State Dependencies

**Read from AppState**: None currently

**Potential Future State**:
```swift
store.explore.searchHistory       // Recent searches
store.explore.categories          // Categories list
store.explore.trendingItems       // Trending data
store.explore.popularSearches     // Popular tags
```

### Actions Dispatched

**Potential Actions**:
```swift
// Search
store.send(.explore(.search(query: searchText)))

// Category tap
store.send(.explore(.categorySelected(.development)))

// Trending item tap
store.send(.explore(.trendingItemTapped(itemID)))

// Tag tap
store.send(.explore(.tagTapped(tag: "Swift")))
```

---

## Design System Usage

### Colors

```swift
Color.theme.background           // Screen background
Color.theme.backgroundSecondary  // (not used)
Color.theme.surface              // Trending rows, category cards
Color.theme.primary              // Tag text, chip background
Color.theme.textPrimary          // Titles
Color.theme.textSecondary        // Subtitles, rank numbers
Color.theme.textTertiary         // (not used)

// Trend colors
Color.green  // Up trend
Color.red    // Down trend
```

### Typography

```swift
.font(.theme.titleLarge)    // Section titles
.font(.theme.titleMedium)   // Category titles
.font(.theme.bodyLarge)     // Trending titles
.font(.theme.labelMedium)   // Tag chips
.font(.theme.caption)       // Subtitles, percentages
```

### Spacing

```swift
Spacing.xl          // 24pt - Section spacing
Spacing.md          // 12pt - Grid spacing, padding
Spacing.sm          // 8pt - Tag spacing, bottom padding
Spacing.xs          // 4pt - Subtitle spacing
Spacing.viewPadding // Standard view padding
```

### Corner Radius

```swift
CornerRadius.card  // 16pt - Category cards
CornerRadius.md    // 8pt - Trending rows
CornerRadius.chip  // 20pt - Tag chips
```

### Shadows

```swift
.shadow(.md)  // Category cards
```

---

## Best Practices

### 1. Search Debouncing

```swift
// ✅ Good - Debounce search input
@State private var searchTask: Task<Void, Never>?

.onChange(of: searchText) { _, newValue in
    searchTask?.cancel()
    searchTask = Task {
        try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
        await performSearch(query: newValue)
    }
}

// ❌ Bad - Search on every keystroke
.onChange(of: searchText) { _, newValue in
    performSearch(query: newValue)
}
```

### 2. Empty State Handling

```swift
// ✅ Good - Show empty state
if searchResults.isEmpty && !searchText.isEmpty {
    ContentUnavailableView(
        "No Results",
        systemImage: "magnifyingglass",
        description: Text("Try different keywords")
    )
}

// ❌ Bad - Blank screen
if searchResults.isEmpty {
    EmptyView()
}
```

### 3. Loading States

```swift
// ✅ Good - Show loading indicator
if isSearching {
    ProgressView()
} else {
    List(searchResults) { ... }
}

// ❌ Bad - No loading feedback
List(searchResults) { ... }
```

---

## Testing

### Unit Tests

```swift
func testSearchTextBinding() {
    var searchText = ""
    let view = ExploreView(store: AppStore.preview())

    // Test search text updates
}

func testTrendingRowTrend() {
    let upRow = TrendingRow(rank: 1, title: "Test", subtitle: "Cat", trend: .up)
    let downRow = TrendingRow(rank: 2, title: "Test", subtitle: "Cat", trend: .down)

    // Verify trend display
}
```

### UI Tests

```swift
func testExploreSearchBar() throws {
    let app = XCUIApplication()
    app.launch()

    app.tabBars.buttons["Explore"].tap()

    let searchField = app.searchFields["Search..."]
    XCTAssertTrue(searchField.exists)

    searchField.tap()
    searchField.typeText("Swift")

    // Verify search results
}

func testCategoryTap() throws {
    let app = XCUIApplication()
    app.launch()

    app.tabBars.buttons["Explore"].tap()
    app.buttons["Development"].tap()

    // Verify navigation to category
}
```

---

## Preview

```swift
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
```

**Shows**:
- Search bar
- Popular searches
- Categories grid
- Trending list

---

## Future Enhancements

### 1. Search History

```swift
@State private var searchHistory: [String] = []

// Show history when search field focused
if searchText.isEmpty && searchFieldFocused {
    List(searchHistory, id: \.self) { query in
        Button(query) {
            searchText = query
            performSearch(query: query)
        }
    }
}
```

### 2. Filters

```swift
@State private var selectedCategory: Category?
@State private var sortBy: SortOption = .relevance

// Filter controls
Picker("Category", selection: $selectedCategory) {
    // Categories
}

Picker("Sort", selection: $sortBy) {
    Text("Relevance").tag(SortOption.relevance)
    Text("Date").tag(SortOption.date)
    Text("Popularity").tag(SortOption.popularity)
}
```

### 3. Infinite Scroll

```swift
LazyVStack {
    ForEach(searchResults) { result in
        SearchResultRow(result: result)
            .onAppear {
                if result == searchResults.last {
                    loadMoreResults()
                }
            }
    }
}
```

### 4. Search Suggestions

```swift
// Auto-complete suggestions
.searchable(
    text: $searchText,
    prompt: "Search..."
) {
    ForEach(suggestions) { suggestion in
        Text(suggestion.text)
            .searchCompletion(suggestion.text)
    }
}
```

---

## Dependencies

- **SwiftUI**: UI framework
- **ComposableArchitecture**: State management
- **Core/AppState**: Explore state (future)
- **Network**: Search API (future)
- **Design System**: Colors, Typography, Spacing, Shadows

---

## Related Documentation

- [Features/README.md](../README.md) - Features overview
- [Root/README.md](../Root/README.md) - Tab navigation
- [Core/README.md](../../Core/README.md) - AppState
- [Network/README.md](../../Network/README.md) - Search API

---

## TODO Items

**ExploreView.swift**:
- Implement search functionality
- Handle category selection (Line 119)
- Handle trending item tap
- Handle tag chip tap
- Fetch popular searches from API
- Fetch categories from API
- Fetch trending items from API
- Add search results view
- Add empty state
- Add loading states
- Add error handling

**Additional Enhancements**:
- Add search debouncing
- Add search history
- Add filters (category, date, sort)
- Add infinite scroll for results
- Add search suggestions/autocomplete
- Add analytics tracking
- Add pull-to-refresh

---

**Cập nhật**: 2025-11-15
**Maintainer**: iOS Team
