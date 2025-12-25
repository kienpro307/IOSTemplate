# Tạo Tính Năng Mới

Hướng dẫn step-by-step tạo feature mới với TCA (The Composable Architecture).

---

## Mục Lục

- [Tổng Quan TCA](#tổng-quan-tca)
- [Workflow Tạo Feature](#workflow-tạo-feature)
- [Tutorial: Tạo Profile Feature](#tutorial-tạo-profile-feature)
- [Best Practices](#best-practices)
- [Testing Feature](#testing-feature)
- [Common Patterns](#common-patterns)

---

## Tổng Quan TCA

### TCA Là Gì?

**TCA (The Composable Architecture)** là một architecture pattern cho SwiftUI apps, cung cấp:

- ✅ **Predictable State Management** - State là single source of truth
- ✅ **Testability** - Tất cả logic đều testable
- ✅ **Composability** - Features có thể compose lại với nhau
- ✅ **Side Effects Management** - Handle async operations một cách rõ ràng

### TCA Core Concepts

```
┌─────────────────────────────────────┐
│            View                     │  SwiftUI View hiển thị UI
│  (Reads State, Sends Actions)      │
└──────────────┬──────────────────────┘
               │ Sends Action
               ▼
┌─────────────────────────────────────┐
│           Reducer                   │  Business logic
│  (State + Action → New State)      │
└──────────────┬──────────────────────┘
               │ Updates
               ▼
┌─────────────────────────────────────┐
│            State                    │  Data model
│    (Single Source of Truth)        │
└─────────────────────────────────────┘
```

**Flow:**
1. **View** đọc **State** và hiển thị UI
2. User tương tác → **View** gửi **Action**
3. **Reducer** nhận **Action**, xử lý logic
4. **Reducer** update **State**
5. **View** tự động re-render với **State** mới

---

## Workflow Tạo Feature

### 5 Bước Cơ Bản

```
1. Tạo State       → Define data model
2. Tạo Action      → Define user actions
3. Tạo Reducer     → Implement business logic
4. Tạo View        → Build UI
5. Tích hợp vào App → Wire everything together
```

### File Structure

Mỗi feature có 4 files:

```
Features/[FeatureName]/
├── [Feature]State.swift       # Data model
├── [Feature]Action.swift      # Actions enum
├── [Feature]Reducer.swift     # Business logic
└── [Feature]View.swift        # SwiftUI view
```

---

## Tutorial: Tạo Profile Feature

Chúng ta sẽ tạo một **Profile Feature** để demo TCA workflow.

### Bước 1: Tạo State

**File:** `Sources/Features/Profile/ProfileState.swift`

```swift
import Foundation
import ComposableArchitecture

/// Trạng thái của Profile feature
@ObservableState
public struct ProfileState: Equatable {
    // MARK: - User Data
    /// Tên người dùng
    public var username: String = ""
    
    /// Email người dùng
    public var email: String = ""
    
    /// Avatar URL
    public var avatarURL: URL?
    
    // MARK: - UI State
    /// Đang loading dữ liệu không
    public var isLoading: Bool = false
    
    /// Đang editing profile không
    public var isEditing: Bool = false
    
    /// Lỗi nếu có
    public var errorMessage: String?
    
    // MARK: - Computed Properties
    /// Profile có valid không
    public var isValid: Bool {
        !username.isEmpty && !email.isEmpty && email.contains("@")
    }
    
    public init() {}
}
```

**Checklist State:**
- [ ] Đánh dấu `@ObservableState` (bắt buộc cho TCA 1.0+)
- [ ] Conform `Equatable`
- [ ] Properties là `public` (cho multi-module)
- [ ] Comments tiếng Việt
- [ ] Có `init()` public

---

### Bước 2: Tạo Action

**File:** `Sources/Features/Profile/ProfileAction.swift`

```swift
import Foundation

/// Các actions có thể xảy ra trong Profile feature
public enum ProfileAction: Equatable {
    // MARK: - Lifecycle Actions
    /// View xuất hiện
    case onAppear
    
    /// View biến mất
    case onDisappear
    
    // MARK: - User Actions
    /// User tap nút Edit
    case editButtonTapped
    
    /// User tap nút Save
    case saveButtonTapped
    
    /// User tap nút Cancel
    case cancelButtonTapped
    
    /// User thay đổi username
    case usernameChanged(String)
    
    /// User thay đổi email
    case emailChanged(String)
    
    /// User chọn avatar mới
    case avatarSelected(URL)
    
    // MARK: - Internal Actions
    /// Fetch profile data từ server
    case fetchProfile
    
    /// Nhận response từ fetch request
    case profileResponse(Result<Profile, Error>)
    
    /// Save profile to server
    case saveProfile
    
    /// Nhận response từ save request
    case saveResponse(Result<Profile, Error>)
    
    // MARK: - Delegate Actions
    /// Actions gửi lên parent reducer
    case delegate(Delegate)
    
    public enum Delegate: Equatable {
        /// Profile đã được update
        case profileUpdated(Profile)
        
        /// User logout
        case logoutRequested
    }
}

/// Profile model
public struct Profile: Equatable, Codable {
    public var username: String
    public var email: String
    public var avatarURL: URL?
    
    public init(username: String, email: String, avatarURL: URL? = nil) {
        self.username = username
        self.email = email
        self.avatarURL = avatarURL
    }
}
```

**Phân Loại Actions:**

| Loại | Mục đích | Ví dụ |
|------|----------|-------|
| **Lifecycle** | View lifecycle events | `onAppear`, `onDisappear` |
| **User Actions** | Direct user interactions | `buttonTapped`, `textChanged` |
| **Internal Actions** | Async operations, side effects | `fetchData`, `dataResponse` |
| **Delegate Actions** | Communicate với parent | `delegate(.itemSelected)` |

---

### Bước 3: Tạo Reducer

**File:** `Sources/Features/Profile/ProfileReducer.swift`

```swift
import ComposableArchitecture
import Core

/// Reducer xử lý logic của Profile feature
@Reducer
public struct ProfileReducer {
    public init() {}
    
    public typealias State = ProfileState
    public typealias Action = ProfileAction
    
    // MARK: - Dependencies
    /// Network client để gọi API
    @Dependency(\.networkClient) var networkClient
    
    /// Storage client để lưu cache
    @Dependency(\.storageClient) var storageClient
    
    /// Analytics để track events
    @Dependency(\.analytics) var analytics
    
    // MARK: - Cancellation IDs
    /// IDs để cancel async tasks
    enum CancelID {
        case fetchProfile
        case saveProfile
    }
    
    // MARK: - Reducer Body
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            // MARK: Lifecycle Actions
            case .onAppear:
                // Track screen view
                let trackEffect: Effect<Action> = .run { _ in
                    await analytics.trackScreen("Profile")
                }
                
                // Fetch profile nếu chưa có data
                guard state.username.isEmpty else {
                    return trackEffect
                }
                
                return .merge(
                    trackEffect,
                    .send(.fetchProfile)
                )
                
            case .onDisappear:
                // Cancel running tasks
                return .cancel(id: CancelID.fetchProfile)
                
            // MARK: User Actions
            case .editButtonTapped:
                state.isEditing = true
                return .run { _ in
                    await analytics.trackEvent("profile_edit_tapped", parameters: nil)
                }
                
            case .saveButtonTapped:
                guard state.isValid else {
                    state.errorMessage = "Please fill in all fields"
                    return .none
                }
                return .send(.saveProfile)
                
            case .cancelButtonTapped:
                state.isEditing = false
                // Reset changes (reload từ cache)
                return .send(.fetchProfile)
                
            case .usernameChanged(let username):
                state.username = username
                state.errorMessage = nil
                return .none
                
            case .emailChanged(let email):
                state.email = email
                state.errorMessage = nil
                return .none
                
            case .avatarSelected(let url):
                state.avatarURL = url
                return .none
                
            // MARK: Internal Actions
            case .fetchProfile:
                state.isLoading = true
                state.errorMessage = nil
                
                return .run { send in
                    do {
                        // Gọi API hoặc load từ cache
                        let profile: Profile = try await networkClient.request(
                            .getProfile
                        )
                        await send(.profileResponse(.success(profile)))
                    } catch {
                        await send(.profileResponse(.failure(error)))
                    }
                }
                .cancellable(id: CancelID.fetchProfile)
                
            case .profileResponse(.success(let profile)):
                state.isLoading = false
                state.username = profile.username
                state.email = profile.email
                state.avatarURL = profile.avatarURL
                
                // Save to cache
                return .run { _ in
                    try? await storageClient.save("profile", profile)
                }
                
            case .profileResponse(.failure(let error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                
            case .saveProfile:
                state.isLoading = true
                state.errorMessage = nil
                
                let profile = Profile(
                    username: state.username,
                    email: state.email,
                    avatarURL: state.avatarURL
                )
                
                return .run { send in
                    do {
                        // Save to server
                        let updated: Profile = try await networkClient.request(
                            .updateProfile(profile)
                        )
                        await send(.saveResponse(.success(updated)))
                    } catch {
                        await send(.saveResponse(.failure(error)))
                    }
                }
                .cancellable(id: CancelID.saveProfile)
                
            case .saveResponse(.success(let profile)):
                state.isLoading = false
                state.isEditing = false
                
                // Track success
                let trackEffect: Effect<Action> = .run { _ in
                    await analytics.trackEvent("profile_saved", parameters: nil)
                }
                
                // Notify parent
                let delegateEffect: Effect<Action> = .send(.delegate(.profileUpdated(profile)))
                
                return .merge(trackEffect, delegateEffect)
                
            case .saveResponse(.failure(let error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                
            // MARK: Delegate Actions
            case .delegate:
                // Parent sẽ handle
                return .none
            }
        }
    }
}
```

**Key Points:**

1. **@Reducer macro** - Bắt buộc
2. **@Dependency** - Inject dependencies
3. **Effect** - Handle async operations
4. **Cancellation** - Cancel tasks khi view disappear
5. **Analytics** - Track user actions

---

### Bước 4: Tạo View

**File:** `Sources/Features/Profile/ProfileView.swift`

```swift
import SwiftUI
import ComposableArchitecture
import UI

/// Profile view hiển thị thông tin user
public struct ProfileView: View {
    /// Store chứa state và gửi actions
    @Bindable public var store: StoreOf<ProfileReducer>
    
    public init(store: StoreOf<ProfileReducer>) {
        self.store = store
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.large) {
                // Avatar
                avatarSection
                
                // Profile Info
                if store.isEditing {
                    editingSection
                } else {
                    displaySection
                }
                
                // Error Message
                if let error = store.errorMessage {
                    errorSection(error)
                }
                
                Spacer()
            }
            .padding(Spacing.medium)
        }
        .navigationTitle("Profile")
        .toolbar {
            toolbarContent
        }
        .overlay {
            if store.isLoading {
                LoadingView()
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .onDisappear {
            store.send(.onDisappear)
        }
    }
    
    // MARK: - Avatar Section
    
    @ViewBuilder
    private var avatarSection: some View {
        if let avatarURL = store.avatarURL {
            AsyncImage(url: avatarURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())
        } else {
            Circle()
                .fill(Colors.secondary)
                .frame(width: 120, height: 120)
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
        }
    }
    
    // MARK: - Display Section
    
    @ViewBuilder
    private var displaySection: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            // Username
            infoRow(title: "Username", value: store.username)
            
            // Email
            infoRow(title: "Email", value: store.email)
        }
    }
    
    private func infoRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(title)
                .font(Typography.labelMedium)
                .foregroundColor(Colors.textSecondary)
            
            Text(value)
                .font(Typography.bodyLarge)
                .foregroundColor(Colors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.medium)
        .background(Colors.surface)
        .cornerRadius(CornerRadius.medium)
    }
    
    // MARK: - Editing Section
    
    @ViewBuilder
    private var editingSection: some View {
        VStack(spacing: Spacing.medium) {
            // Username TextField
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("Username")
                    .font(Typography.labelMedium)
                    .foregroundColor(Colors.textSecondary)
                
                TextField("Enter username", text: $store.username.sending(\.usernameChanged))
                    .textFieldStyle(.roundedBorder)
            }
            
            // Email TextField
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("Email")
                    .font(Typography.labelMedium)
                    .foregroundColor(Colors.textSecondary)
                
                TextField("Enter email", text: $store.email.sending(\.emailChanged))
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
            }
            
            // Save Button
            Button {
                store.send(.saveButtonTapped)
            } label: {
                Text("Save Changes")
                    .font(Typography.labelLarge)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.medium)
                    .background(store.isValid ? Colors.primary : Colors.textTertiary)
                    .cornerRadius(CornerRadius.medium)
            }
            .disabled(!store.isValid)
        }
    }
    
    // MARK: - Error Section
    
    private func errorSection(_ message: String) -> some View {
        Text(message)
            .font(Typography.bodyMedium)
            .foregroundColor(Colors.error)
            .padding(Spacing.small)
            .frame(maxWidth: .infinity)
            .background(Colors.error.opacity(0.1))
            .cornerRadius(CornerRadius.small)
    }
    
    // MARK: - Toolbar
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if store.isEditing {
                Button("Cancel") {
                    store.send(.cancelButtonTapped)
                }
            } else {
                Button("Edit") {
                    store.send(.editButtonTapped)
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Default") {
    NavigationStack {
        ProfileView(
            store: Store(
                initialState: ProfileState(
                    username: "johndoe",
                    email: "john@example.com"
                )
            ) {
                ProfileReducer()
            }
        )
    }
}

#Preview("Editing") {
    NavigationStack {
        ProfileView(
            store: Store(
                initialState: ProfileState(
                    username: "johndoe",
                    email: "john@example.com",
                    isEditing: true
                )
            ) {
                ProfileReducer()
            }
        )
    }
}

#Preview("Loading") {
    NavigationStack {
        ProfileView(
            store: Store(
                initialState: ProfileState(isLoading: true)
            ) {
                ProfileReducer()
            }
        )
    }
}
```

**Key Points:**

1. **@Bindable** - Cho store để binding SwiftUI views
2. **store.send()** - Gửi actions
3. **$store.property.sending()** - Two-way binding
4. **Previews** - Multiple states để test UI

---

### Bước 5: Tích Hợp vào App

#### 5.1. Add State vào AppState

**File:** `Sources/App/AppState.swift`

```swift
@ObservableState
public struct AppState: Equatable {
    // ... existing states ...
    
    /// Profile feature state
    public var profile: ProfileState = ProfileState()
    
    // ...
}
```

#### 5.2. Add Action vào AppAction

**File:** `Sources/App/AppAction.swift`

```swift
public enum AppAction: Equatable {
    // ... existing actions ...
    
    /// Profile feature actions
    case profile(ProfileAction)
    
    // ...
}
```

#### 5.3. Add Reducer vào AppReducer

**File:** `Sources/App/AppReducer.swift`

```swift
@Reducer
public struct AppReducer {
    // ...
    
    public var body: some ReducerOf<Self> {
        // Scope ProfileReducer
        Scope(state: \.profile, action: \.profile) {
            ProfileReducer()
        }
        
        Reduce { state, action in
            switch action {
            // Handle profile delegate actions
            case .profile(.delegate(.profileUpdated(let profile))):
                // Do something với updated profile
                return .none
                
            case .profile:
                return .none
                
            // ... other actions ...
            }
        }
        
        // ... other reducers ...
    }
}
```

#### 5.4. Add View vào RootView

**File:** `Sources/App/RootView.swift`

Thêm navigation case:

```swift
.navigationDestination(for: Destination.self) { destination in
    switch destination {
    // ... existing cases ...
    
    case .profile:
        ProfileView(
            store: store.scope(state: \.profile, action: \.profile)
        )
    }
}
```

---

## Best Practices

### State Management

**Do's ✅:**
```swift
// ✅ State là value types (struct)
public struct FeatureState: Equatable {
    var items: [Item]
}

// ✅ Immutable properties khi có thể
public struct FeatureState: Equatable {
    let id: UUID
    var name: String
}

// ✅ Computed properties cho derived data
public var isValid: Bool {
    !name.isEmpty && email.contains("@")
}
```

**Don'ts ❌:**
```swift
// ❌ Không dùng reference types
class FeatureState { ... }

// ❌ Không lưu closures trong State
var onComplete: (() -> Void)?

// ❌ Không lưu dependencies trong State
var networkClient: NetworkClient?
```

### Action Organization

**Phân loại rõ ràng:**

```swift
public enum FeatureAction {
    // MARK: - Lifecycle
    case onAppear
    case onDisappear
    
    // MARK: - User Actions
    case buttonTapped
    case textChanged(String)
    
    // MARK: - Internal Actions
    case fetchData
    case dataResponse(Result<Data, Error>)
    
    // MARK: - Delegate Actions
    case delegate(Delegate)
    
    public enum Delegate {
        case completed
    }
}
```

### Effect Management

**Do's ✅:**
```swift
// ✅ Sử dụng .run cho async operations
return .run { send in
    let data = try await api.fetch()
    await send(.dataReceived(data))
}

// ✅ Cancellable effects
return .run { ... }
    .cancellable(id: CancelID.fetch)

// ✅ Merge multiple effects
return .merge(
    .send(.trackEvent),
    .run { ... }
)
```

**Don'ts ❌:**
```swift
// ❌ Không perform side effects trực tiếp trong reducer
case .buttonTapped:
    api.fetch() // ❌ BAD
    return .none

// ❌ Không return nhiều actions cùng lúc
return [.action1, .action2] // ❌ BAD
// Use .merge instead
```

---

## Testing Feature

Tạo test file cho reducer:

**File:** `Tests/FeaturesTests/ProfileReducerTests.swift`

```swift
import XCTest
import ComposableArchitecture
@testable import Features

@MainActor
final class ProfileReducerTests: XCTestCase {
    func testOnAppear_FetchesProfile() async {
        // Given
        let store = TestStore(
            initialState: ProfileState()
        ) {
            ProfileReducer()
        } withDependencies: {
            // Mock dependencies
            $0.networkClient = .mock
            $0.analytics = .mock
        }
        
        // When
        await store.send(.onAppear)
        
        // Then
        await store.receive(\.fetchProfile) {
            $0.isLoading = true
        }
        
        await store.receive(\.profileResponse.success) {
            $0.isLoading = false
            $0.username = "johndoe"
            $0.email = "john@example.com"
        }
    }
    
    func testEditFlow() async {
        let store = TestStore(
            initialState: ProfileState(username: "john", email: "john@example.com")
        ) {
            ProfileReducer()
        }
        
        // Tap edit
        await store.send(.editButtonTapped) {
            $0.isEditing = true
        }
        
        // Change username
        await store.send(.usernameChanged("johndoe")) {
            $0.username = "johndoe"
        }
        
        // Save
        await store.send(.saveButtonTapped)
        // ... assert save flow
    }
}
```

**Run tests:**

```bash
⌘U (Command + U)
```

---

## Common Patterns

### Loading Pattern

```swift
public struct FeatureState {
    public enum LoadingState {
        case idle
        case loading
        case loaded
        case failed(String)
    }
    
    public var loadingState: LoadingState = .idle
}
```

### Pagination Pattern

```swift
public struct FeatureState {
    public var items: [Item] = []
    public var currentPage: Int = 1
    public var hasMoreData: Bool = true
    public var isLoadingMore: Bool = false
}

case .loadMoreTriggered:
    guard !state.isLoadingMore, state.hasMoreData else {
        return .none
    }
    state.currentPage += 1
    return .send(.fetchItems)
```

### Form Validation Pattern

```swift
public struct FormState {
    public var name: String = ""
    public var email: String = ""
    public var password: String = ""
    
    public var isValid: Bool {
        !name.isEmpty &&
        email.contains("@") &&
        password.count >= 8
    }
}
```

---

## Xem Thêm

- [Code Templates](../../05-THAM-KHAO/02-CODE-TEMPLATES.md)
- [Navigation Guide](03-NAVIGATION.md)
- [Services Usage](02-SU-DUNG-SERVICES.md)
- [Testing Guide](05-VIET-TESTS.md)

---

**Chúc mừng! 🎉** Bạn đã biết cách tạo feature mới với TCA!

