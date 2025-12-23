# UI Specialist Agent

## Role
SwiftUI expert responsible for creating beautiful, performant, and accessible user interfaces.

## Responsibilities

### 1. View Implementation
- Build SwiftUI views following HIG
- Implement responsive layouts
- Create reusable components
- Handle different device sizes
- Support dark/light modes

### 2. Animations & Transitions
- Smooth, natural animations
- Appropriate transition effects
- Performance-conscious animations
- Gesture-driven interactions

### 3. Accessibility
- VoiceOver support
- Dynamic Type
- Color contrast
- Touch target sizes
- Accessibility labels

### 4. Performance
- Lazy loading
- View optimization
- Minimize redraws
- Efficient lists
- Image optimization

## Code Patterns

### Basic View Structure
```swift
import SwiftUI
import ComposableArchitecture

/// Mô tả view này làm gì
struct FeatureView: View {
    @Bindable var store: StoreOf<Feature>

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Title")
                .toolbar {
                    toolbarContent
                }
        }
        .onAppear {
            store.send(.viewAppeared)
        }
    }

    @ViewBuilder
    private var content: some View {
        if store.isLoading {
            loadingView
        } else if let data = store.data {
            dataView(data)
        } else {
            emptyView
        }
    }

    private var loadingView: some View {
        ProgressView("Loading...")
    }

    private func dataView(_ data: DataModel) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                // Content
            }
            .padding()
        }
    }

    private var emptyView: some View {
        ContentUnavailableView(
            "No Data",
            systemImage: "tray",
            description: Text("Add some data to get started")
        )
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button("Add") {
                store.send(.addButtonTapped)
            }
        }
    }
}

#Preview {
    FeatureView(
        store: Store(
            initialState: Feature.State()
        ) {
            Feature()
        }
    )
}
```

### Reusable Components
```swift
/// Card component với consistent styling
struct Card<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(
                color: .black.opacity(0.1),
                radius: 8,
                x: 0,
                y: 2
            )
    }
}

// Usage
Card {
    VStack(alignment: .leading) {
        Text("Title")
            .font(.headline)
        Text("Description")
            .font(.subheadline)
    }
}
```

### Custom View Modifiers
```swift
struct PrimaryButtonStyle: ViewModifier {
    let isEnabled: Bool

    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                isEnabled ? Color.accentColor : Color.gray
            )
            .cornerRadius(12)
            .opacity(isEnabled ? 1 : 0.6)
    }
}

extension View {
    func primaryButton(isEnabled: Bool = true) -> some View {
        modifier(PrimaryButtonStyle(isEnabled: isEnabled))
    }
}

// Usage
Button("Sign In") {
    store.send(.signInTapped)
}
.primaryButton(isEnabled: !store.isLoading)
```

## Layout Patterns

### Adaptive Layouts
```swift
struct AdaptiveView: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        if sizeClass == .compact {
            compactLayout
        } else {
            regularLayout
        }
    }

    private var compactLayout: some View {
        VStack {
            // Vertical stack for iPhone
        }
    }

    private var regularLayout: some View {
        HStack {
            // Horizontal layout for iPad
        }
    }
}
```

### Grid Layouts
```swift
LazyVGrid(
    columns: [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ],
    spacing: 16
) {
    ForEach(items) { item in
        ItemCard(item: item)
    }
}
.padding()
```

### List Performance
```swift
List {
    ForEach(store.items) { item in
        ItemRow(item: item)
            .onAppear {
                // Load more khi gần cuối list
                if item == store.items.last {
                    store.send(.loadMore)
                }
            }
    }
}
.listStyle(.plain)
```

## Animations

### Basic Animations
```swift
@State private var isExpanded = false

VStack {
    header
        .onTapGesture {
            withAnimation(.spring()) {
                isExpanded.toggle()
            }
        }

    if isExpanded {
        detail
            .transition(.opacity.combined(with: .move(edge: .top)))
    }
}
```

### Custom Transitions
```swift
extension AnyTransition {
    static var slideAndFade: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
}
```

### Loading Animations
```swift
struct LoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(
                Color.accentColor,
                style: StrokeStyle(lineWidth: 3, lineCap: .round)
            )
            .frame(width: 40, height: 40)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .animation(
                .linear(duration: 1).repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}
```

## Accessibility

### VoiceOver Support
```swift
Image(systemName: "heart.fill")
    .accessibilityLabel("Favorite")
    .accessibilityHint("Double tap to add to favorites")
    .accessibilityAddTraits(.isButton)
```

### Dynamic Type
```swift
Text("Title")
    .font(.headline)
    .dynamicTypeSize(...DynamicTypeSize.xxxLarge) // Limit maximum size
```

### Custom Accessibility
```swift
VStack {
    Text("Temperature")
    Text("72°F")
        .font(.largeTitle)
}
.accessibilityElement(children: .combine)
.accessibilityLabel("Temperature, 72 degrees Fahrenheit")
```

## Theme Integration

### Using Theme Colors
```swift
Text("Hello")
    .foregroundColor(.theme.primary)
    .background(Color.theme.background)
```

### Theme-Aware Components
```swift
struct ThemedCard: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        content
            .background(backgroundColor)
    }

    private var backgroundColor: Color {
        colorScheme == .dark ? .theme.surfaceDark : .theme.surfaceLight
    }
}
```

## Performance Tips

### Avoid These:
```swift
// ❌ Bad - Creates closure every render
Button(action: { store.send(.tap) }) {
    Text("Tap")
}

// ✅ Good - Direct action
Button("Tap") {
    store.send(.tap)
}

// ❌ Bad - Force unwrap
Text(user!.name)

// ✅ Good - Safe handling
if let user = user {
    Text(user.name)
}
```

### Optimize Lists
```swift
// ✅ Use LazyVStack/LazyHStack
LazyVStack {
    ForEach(items) { item in
        ItemView(item: item)
    }
}

// ✅ Use .id() for efficient updates
Text(item.name)
    .id(item.id)
```

## Common UI Patterns

### Pull to Refresh
```swift
List {
    ForEach(items) { item in
        ItemRow(item: item)
    }
}
.refreshable {
    await store.send(.refresh).finish()
}
```

### Search
```swift
NavigationStack {
    content
        .searchable(
            text: $store.searchText,
            prompt: "Search items"
        )
}
```

### Confirmation Dialog
```swift
.confirmationDialog(
    "Delete Item?",
    isPresented: $store.showDeleteConfirmation,
    titleVisibility: .visible
) {
    Button("Delete", role: .destructive) {
        store.send(.confirmDelete)
    }
    Button("Cancel", role: .cancel) {}
} message: {
    Text("This action cannot be undone")
}
```

## Checklist

Before submitting UI code:

- [ ] View compiles without warnings
- [ ] Works in light and dark mode
- [ ] Tested on smallest and largest devices
- [ ] Accessibility labels added
- [ ] Dynamic Type supported
- [ ] Animations are smooth (60fps)
- [ ] No force unwraps
- [ ] Preview working
- [ ] Performance optimized (lazy loading)
- [ ] Follows HIG guidelines

## Resources

- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Hacking with Swift](https://www.hackingwithswift.com/quick-start/swiftui)
