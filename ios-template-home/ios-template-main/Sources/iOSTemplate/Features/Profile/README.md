# Profile - User Profile & Activity

## Tổng quan

Thư mục `Profile/` chứa **user profile screen và personal activity**. Đây là nơi users xem thông tin cá nhân, stats, và manage personal content.

### Chức năng chính
- User profile display (avatar, name, email)
- Stats overview (posts, followers, following)
- Profile editing navigation
- Share profile functionality
- Activity sections (favorites, saved, history)
- Personal content management

### Tác động đến toàn bộ app
- **High Impact**: Personal identity trong app
- Display user information
- Access to personal content
- Profile management entry point
- Tab thứ 3 trong MainTabView

---

## Cấu trúc Files

```
Profile/
└── ProfileView.swift        # Profile screen (222 dòng)
```

**Tổng cộng**: 1 file, 222 dòng code

---

## Chi tiết File: ProfileView.swift (222 dòng)

### Component Overview

```swift
public struct ProfileView: View {
    @Bindable var store: StoreOf<AppReducer>

    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                profileHeader
                statsSection
                actionsSection
                contentSection
                Spacer()
            }
            .padding(Spacing.viewPadding)
        }
        .navigationTitle("Profile")
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
}
```

### State Access (dòng 6)

```swift
@Bindable var store: StoreOf<AppReducer>
```

**Read State**:
```swift
store.user.profile?.name   // User name
store.user.profile?.email  // User email
```

---

## UI Sections

### 1. Profile Header (dòng 47-76)

```swift
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
```

#### Visual Structure

```
     ┌─────────┐
     │    J    │  ← Avatar circle (100x100)
     └─────────┘     Gradient background
                     First letter of name

    John Doe         ← Name (headline medium)
 john@example.com    ← Email (body medium)
```

#### Avatar Circle (dòng 50-64)

**Gradient Background**:
- Primary to Secondary color
- Top-left to bottom-right
- 100x100 circle

**Initial Letter**:
```swift
Text(store.user.profile?.name.prefix(1).uppercased() ?? "U")
```
- First character of name
- Uppercased
- 40pt bold font
- White color
- Fallback: "U"

**Example**:
- "John Doe" → "J"
- "Alice Smith" → "A"
- nil → "U"

#### Name and Email (dòng 66-75)

**Name**:
```swift
Text(store.user.profile?.name ?? "User Name")
```
- Headline medium font
- Primary text color
- Fallback: "User Name"

**Email**:
```swift
Text(store.user.profile?.email ?? "user@example.com")
```
- Body medium font
- Secondary text color
- Fallback: "user@example.com"

---

### 2. Stats Section (dòng 78-90)

```swift
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
```

#### Visual Structure

```
┌───────────────────────────────────┐
│   127    │   1.2K   │    345     │
│  Posts   │ Followers│  Following │
└───────────────────────────────────┘
```

**Layout**:
- 3 StatItems horizontal
- Dividers between stats (40pt height)
- Equal width distribution
- Card background with shadow

**Stats** (Mock Data):
- **Posts**: "127"
- **Followers**: "1.2K"
- **Following**: "345"

**Future Enhancement**: Real stats từ API

---

### 3. Actions Section (dòng 92-104)

```swift
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
```

**Visual**:
```
┌──────────────────┐
│  Edit Profile    │  ← Primary button
└──────────────────┘
┌──────────────────┐
│  Share Profile   │  ← Secondary button
└──────────────────┘
```

**Actions**:
1. **Edit Profile**: Primary button → TODO: Handle edit (Line 95)
2. **Share Profile**: Secondary button → TODO: Handle share (Line 100)

---

### 4. Content Section (dòng 106-135)

```swift
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
```

#### Visual Structure

```
Activity

┌──────────────────────────────────┐
│ ❤️   Favorites              ›    │
│      24 items                    │
├──────────────────────────────────┤
│ 🔖   Saved                  ›    │
│      12 items                    │
├──────────────────────────────────┤
│ 🕐   History                ›    │
│      View all                    │
└──────────────────────────────────┘
```

**Menu Items**:

1. **Favorites**
   - Icon: heart.fill (red)
   - Count: "24 items"

2. **Saved**
   - Icon: bookmark.fill (orange)
   - Count: "12 items"

3. **History**
   - Icon: clock.fill (blue)
   - Subtitle: "View all"

**Interaction**: Tap to navigate to detail screens

---

## Toolbar (dòng 34-42)

```swift
.toolbar {
    ToolbarItem(placement: .primaryAction) {
        Button {
            // Edit profile
        } label: {
            Image(systemName: "pencil")
        }
    }
}
```

**Edit Button**:
- Location: Navigation bar trailing (top-right)
- Icon: Pencil
- Action: TODO - Same as "Edit Profile" button (Line 37)

---

## Reusable Components

### StatItem (dòng 140-156)

```swift
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
```

**Visual**:
```
 127      ← Value (title large)
Posts     ← Label (caption)
```

**Layout**:
- Vertical stack
- Value on top (large, bold)
- Label below (small, secondary)
- Full width

**Usage**:
```swift
StatItem(value: "1.2K", label: "Followers")
```

---

### ProfileMenuItem (dòng 160-199)

```swift
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
```

**Visual**:
```
┌──────────────────────────────────┐
│ ┌────┐  Favorites           ›   │
│ │ ❤️  │  24 items               │
│ └────┘                           │
└──────────────────────────────────┘
```

**Layout**:
- Leading: Colored icon square (40x40)
- Center: Title + subtitle (vertical)
- Trailing: Chevron indicator

**Parameters**:
- `icon`: SF Symbol name
- `title`: Menu item title
- `subtitle`: Count or description
- `color`: Icon color and background tint

**Styling**:
- Icon: 40x40 square, 10% opacity background
- Surface background
- Medium corner radius
- Full width button

---

## Integration với Core Layer

### State Dependencies

**Read from AppState**:
```swift
store.user.profile?.name   // User name
store.user.profile?.email  // User email
```

**Potential Future State**:
```swift
store.user.profile?.avatarURL  // Avatar image URL
store.user.profile?.bio        // User bio
store.user.stats.posts         // Posts count
store.user.stats.followers     // Followers count
store.user.stats.following     // Following count
store.user.favorites.count     // Favorites count
store.user.saved.count         // Saved count
```

### Actions Dispatched

**Potential Actions**:
```swift
// Edit profile
store.send(.navigation(.navigateTo(.editProfile)))

// Share profile
store.send(.user(.shareProfile))

// Menu item taps
store.send(.user(.viewFavorites))
store.send(.user(.viewSaved))
store.send(.user(.viewHistory))
```

---

## Design System Usage

### Colors

```swift
Color.theme.background    // Screen background
Color.theme.surface       // Stats card, menu items
Color.theme.primary       // Gradient start
Color.theme.secondary     // Gradient end
Color.theme.textPrimary   // Name, stat values
Color.theme.textSecondary // Email, stat labels
Color.theme.textTertiary  // Chevron

// Menu item colors
Color.red     // Favorites
Color.orange  // Saved
Color.blue    // History
```

### Typography

```swift
.font(.theme.headlineMedium)  // User name
.font(.theme.titleLarge)      // Stat values, "Activity"
.font(.theme.bodyMedium)      // Email
.font(.theme.bodyLarge)       // Menu item titles
.font(.theme.caption)         // Stat labels, subtitles
```

### Spacing

```swift
Spacing.xl          // 24pt - Section spacing
Spacing.lg          // 16pt - Stats padding
Spacing.md          // 12pt - Profile header, menu padding
Spacing.sm          // 8pt - Actions spacing, menu spacing
Spacing.xs          // 4pt - Name/email, stat spacing
Spacing.viewPadding // Standard view padding
```

### Corner Radius

```swift
CornerRadius.card  // 16pt - Stats card
CornerRadius.md    // 8pt - Menu items
CornerRadius.sm    // 4pt - Icon squares
```

### Shadows

```swift
.shadow(.md)  // Stats card shadow
```

### Button Styles

```swift
.primaryButton()    // Edit Profile
.secondaryButton()  // Share Profile
```

---

## Best Practices

### 1. Null Safety

```swift
// ✅ Good - Provide fallbacks
Text(store.user.profile?.name ?? "User Name")

// ❌ Bad - Force unwrap
Text(store.user.profile!.name)
```

### 2. State Dependency

```swift
// ✅ Good - Read from AppState
store.user.profile?.name

// ❌ Bad - Local duplicate
@State private var userName: String = ""
```

### 3. Avatar Display

```swift
// Current: Gradient with initial
// ✅ Better - Load avatar image if available
if let avatarURL = store.user.profile?.avatarURL {
    AsyncImage(url: avatarURL) { image in
        image.resizable()
    } placeholder: {
        InitialAvatar(name: store.user.profile?.name)
    }
} else {
    InitialAvatar(name: store.user.profile?.name)
}
```

---

## Testing

### Unit Tests

```swift
func testProfileDisplaysUserInfo() {
    let profile = UserProfile(
        id: "123",
        email: "john@example.com",
        name: "John Doe"
    )

    let store = AppStore.preview(
        state: AppState(
            user: UserState(profile: profile)
        )
    )

    let view = ProfileView(store: store)
    // Test that name and email are displayed
}

func testProfileInitial() {
    let profile = UserProfile(
        id: "123",
        email: "alice@example.com",
        name: "Alice Smith"
    )

    let initial = profile.name.prefix(1).uppercased()
    XCTAssertEqual(initial, "A")
}
```

### UI Tests

```swift
func testProfileElements() throws {
    let app = XCUIApplication()
    app.launch()

    app.tabBars.buttons["Profile"].tap()

    // Verify elements
    XCTAssertTrue(app.staticTexts["John Doe"].exists)
    XCTAssertTrue(app.staticTexts["john.doe@example.com"].exists)
    XCTAssertTrue(app.buttons["Edit Profile"].exists)
    XCTAssertTrue(app.buttons["Share Profile"].exists)
}
```

---

## Preview

```swift
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
```

**Shows**:
- Profile with "John Doe"
- Email: "john.doe@example.com"
- Avatar with "J"
- Mock stats
- Menu items

---

## Future Enhancements

### 1. Avatar Upload

```swift
@State private var showImagePicker = false
@State private var selectedImage: UIImage?

Button {
    showImagePicker = true
} label: {
    Circle()
        .overlay(
            Image(systemName: "camera.fill")
                .foregroundColor(.white)
                .padding(8)
                .background(Color.theme.primary)
                .clipShape(Circle())
            , alignment: .bottomTrailing
        )
}
.sheet(isPresented: $showImagePicker) {
    ImagePicker(image: $selectedImage)
}
```

### 2. Pull to Refresh

```swift
ScrollView {
    // Content
}
.refreshable {
    await refreshProfile()
}

private func refreshProfile() async {
    // Fetch latest profile data
}
```

### 3. Real Stats from API

```swift
@State private var stats: UserStats?

.task {
    stats = try? await networkService.request(.getUserStats(userID))
}

// Display real stats
StatItem(value: "\(stats?.posts ?? 0)", label: "Posts")
```

### 4. Bio Section

```swift
if let bio = store.user.profile?.bio {
    Text(bio)
        .font(.theme.bodyMedium)
        .foregroundColor(.theme.textSecondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
}
```

### 5. QR Code Sharing

```swift
Button("Share Profile") {
    generateQRCode(profileURL: profileURL)
    showShareSheet = true
}
.sheet(isPresented: $showShareSheet) {
    ShareSheet(items: [qrCodeImage, profileURL])
}
```

---

## Dependencies

- **SwiftUI**: UI framework
- **ComposableArchitecture**: State management
- **Core/AppState**: UserProfile, UserState
- **Design System**: Colors, Typography, Spacing, Shadows, Buttons
- **Assets**: Icons, Images

---

## Related Documentation

- [Features/README.md](../README.md) - Features overview
- [Root/README.md](../Root/README.md) - Tab navigation
- [Core/README.md](../../Core/README.md) - UserState, UserProfile
- [Settings/README.md](../Settings/README.md) - Edit profile settings

---

## TODO Items

**ProfileView.swift**:
- **Dòng 37**: Implement edit profile navigation
- **Dòng 95**: Handle edit profile action
- **Dòng 100**: Implement share profile functionality
- Implement menu item navigation (Favorites, Saved, History)

**Additional Enhancements**:
- Add avatar upload/edit functionality
- Load avatar from URL if available
- Fetch real stats from API
- Add bio section
- Add website/social links
- Add pull-to-refresh
- Add QR code sharing
- Add follow/unfollow for other users
- Add activity feed for user
- Add profile completion indicator

---

**Cập nhật**: 2025-11-15
**Maintainer**: iOS Team
