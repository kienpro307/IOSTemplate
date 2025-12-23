# Storage - Data Persistence Layer

## Tổng quan

Thư mục `Storage/` cung cấp abstraction layer cho tất cả data persistence trong app. Bao gồm **UserDefaults**, **Keychain**, và **File Storage** với type-safe interfaces và Codable support.

### Chức năng chính
- UserDefaults wrapper với type safety và Codable
- Keychain integration cho secure storage (tokens, credentials)
- File storage cho documents, cache, temporary files
- Protocol-based abstraction cho testing
- Property wrapper cho convenient access
- Support biometric authentication

### Tác động đến toàn bộ app
- **Critical Impact**: Tất cả data persistence operations phụ thuộc vào layer này
- Quản lý sensitive data (tokens, passwords) securely
- Cache management và file operations
- Ảnh hưởng đến app performance (cache hits/misses)
- Enable offline functionality với local storage

---

## Cấu trúc Files

```
Storage/
├── StorageProtocols.swift      # Storage interfaces (92 dòng)
├── UserDefaultsStorage.swift   # UserDefaults wrapper (166 dòng)
├── KeychainStorage.swift       # Keychain secure storage (183 dòng)
└── FileStorage.swift           # File operations (314 dòng)
```

**Tổng cộng**: 755 dòng code, 4 files

---

## Chi tiết các Files

### 1. StorageProtocols.swift (92 dòng)

**Chức năng**: Định nghĩa protocol contracts cho storage operations

#### Các protocol chính:

##### `StorageServiceProtocol` (dòng 5-20)
Protocol cho general storage (UserDefaults).

**Methods**:

1. **`save<T: Codable>(_ value: T, forKey: String) throws`**:
   - Save any Codable type
   - Automatically encodes to JSON if needed
   - Throws `StorageError` on failure

2. **`load<T: Codable>(forKey: String) throws -> T?`**:
   - Load and decode Codable type
   - Returns nil if key doesn't exist
   - Throws on decoding errors

3. **`remove(forKey: String)`**:
   - Remove specific key

4. **`clearAll()`**:
   - Remove all stored data

5. **`exists(forKey: String) -> Bool`**:
   - Check if key exists

**Usage**:
```swift
let storage: StorageServiceProtocol = UserDefaultsStorage()

// Save
try storage.save(userProfile, forKey: StorageKey.userProfile)

// Load
let profile: UserProfile? = try storage.load(forKey: StorageKey.userProfile)

// Remove
storage.remove(forKey: StorageKey.userProfile)

// Check existence
if storage.exists(forKey: StorageKey.userProfile) {
    print("Profile exists")
}
```

##### `SecureStorageProtocol` (dòng 23-35)
Protocol cho secure storage (Keychain).

**Methods**:

1. **`saveSecure(_ value: String, forKey: String) throws`**:
   - Save string securely to Keychain
   - Encrypted by iOS automatically

2. **`loadSecure(forKey: String) throws -> String?`**:
   - Load string from Keychain
   - Returns nil if not found

3. **`removeSecure(forKey: String) throws`**:
   - Remove secure value

4. **`clearAllSecure() throws`**:
   - Clear all Keychain data for app

**Usage**:
```swift
let keychain: SecureStorageProtocol = KeychainStorage()

// Save token
try keychain.saveSecure("my-access-token", forKey: SecureStorageKey.accessToken)

// Load token
let token = try keychain.loadSecure(forKey: SecureStorageKey.accessToken)

// Remove token
try keychain.removeSecure(forKey: SecureStorageKey.accessToken)
```

##### `FileStorageProtocol` (dòng 38-59)
Protocol cho file operations.

**Methods**:

1. **`saveFile(_ data: Data, fileName: String) throws -> URL`**:
   - Save data to file
   - Returns file URL
   - Creates directories if needed

2. **`loadFile(fileName: String) throws -> Data`**:
   - Load file data
   - Throws if file not found

3. **`deleteFile(fileName: String) throws`**:
   - Delete specific file

4. **`fileExists(fileName: String) -> Bool`**:
   - Check file existence

5. **`fileURL(fileName: String) -> URL`**:
   - Get file URL

6. **`directorySize() throws -> Int64`**:
   - Calculate total directory size in bytes

7. **`clearDirectory() throws`**:
   - Delete all files in directory

**Usage**:
```swift
let fileStorage: FileStorageProtocol = FileStorage.documents

// Save file
let data = "Hello".data(using: .utf8)!
let url = try fileStorage.saveFile(data, fileName: "greeting.txt")

// Load file
let loadedData = try fileStorage.loadFile(fileName: "greeting.txt")

// Check size
let size = try fileStorage.directorySize()
print("Directory size: \(size.formattedFileSize)")
```

#### `StorageError` (dòng 64-91)
Errors cho storage operations.

**Cases**:
- `.encodingFailed` - Failed to encode Codable object
- `.decodingFailed` - Failed to decode data
- `.notFound` - Data/file not found
- `.invalidData` - Invalid data format
- `.accessDenied` - Access denied (permissions)
- `.diskFull` - Disk is full
- `.unknown(Error)` - Wrapped error

**Localized descriptions**:
```swift
public var errorDescription: String? {
    switch self {
    case .encodingFailed:
        return "Failed to encode data"
    case .decodingFailed:
        return "Failed to decode data"
    case .notFound:
        return "Data not found"
    // ...
    }
}
```

---

### 2. UserDefaultsStorage.swift (166 dòng)

**Chức năng**: Type-safe UserDefaults wrapper với Codable support

##### `UserDefaultsStorage` (dòng 4-88)
Main implementation.

**Properties**:
- `defaults: UserDefaults` - UserDefaults instance (default: .standard)
- `encoder: JSONEncoder` - For encoding Codable objects
- `decoder: JSONDecoder` - For decoding Codable objects

**Initialization** (dòng 14-22):
```swift
public init(
    defaults: UserDefaults = .standard,
    encoder: JSONEncoder = JSONEncoder(),
    decoder: JSONDecoder = JSONDecoder()
) {
    self.defaults = defaults
    self.encoder = encoder
    self.decoder = decoder
}
```

#### StorageServiceProtocol Implementation

##### `save<T: Codable>` (dòng 26-46)
Smart save với primitive type optimization.

**Flow**:
1. Check if value is primitive type (String, Int, Bool, Double)
2. If primitive → Save directly without encoding
3. If complex → Encode to JSON → Save Data
4. Call `synchronize()` to persist

**Implementation**:
```swift
public func save<T: Codable>(_ value: T, forKey key: String) throws {
    do {
        // Primitive types - save directly
        if let stringValue = value as? String {
            defaults.set(stringValue, forKey: key)
        } else if let intValue = value as? Int {
            defaults.set(intValue, forKey: key)
        } else if let boolValue = value as? Bool {
            defaults.set(boolValue, forKey: key)
        } else if let doubleValue = value as? Double {
            defaults.set(doubleValue, forKey: key)
        } else {
            // Complex types - encode to JSON
            let data = try encoder.encode(value)
            defaults.set(data, forKey: key)
        }
        defaults.synchronize()
    } catch {
        throw StorageError.encodingFailed
    }
}
```

**Optimization**: Primitive types không cần encode/decode, faster performance.

##### `load<T: Codable>` (dòng 48-71)
Smart load với type checking.

**Flow**:
1. Check if T is primitive type
2. If primitive → Return directly casted value
3. If complex → Load Data → Decode JSON
4. Return decoded object

**Implementation**:
```swift
public func load<T: Codable>(forKey key: String) throws -> T? {
    // Try primitive types first
    if T.self == String.self {
        return defaults.string(forKey: key) as? T
    } else if T.self == Int.self {
        return defaults.integer(forKey: key) as? T
    } else if T.self == Bool.self {
        return defaults.bool(forKey: key) as? T
    } else if T.self == Double.self {
        return defaults.double(forKey: key) as? T
    }

    // Try to decode from Data
    guard let data = defaults.data(forKey: key) else {
        return nil
    }

    do {
        let value = try decoder.decode(T.self, from: data)
        return value
    } catch {
        throw StorageError.decodingFailed
    }
}
```

##### `remove(forKey:)` (dòng 73-76)
```swift
public func remove(forKey key: String) {
    defaults.removeObject(forKey: key)
    defaults.synchronize()
}
```

##### `clearAll()` (dòng 78-83)
Remove entire persistent domain.

```swift
public func clearAll() {
    if let bundleID = Bundle.main.bundleIdentifier {
        defaults.removePersistentDomain(forName: bundleID)
    }
    defaults.synchronize()
}
```

##### `exists(forKey:)` (dòng 85-87)
```swift
public func exists(forKey key: String) -> Bool {
    defaults.object(forKey: key) != nil
}
```

#### `StorageKey` (dòng 93-114)
Centralized storage keys.

**User Keys**:
- `userProfile` - "user.profile"
- `userPreferences` - "user.preferences"

**Settings Keys**:
- `themeMode` - "settings.theme_mode"
- `languageCode` - "settings.language_code"
- `notificationsEnabled` - "settings.notifications_enabled"

**Onboarding Keys**:
- `hasCompletedOnboarding` - "onboarding.completed"
- `onboardingVersion` - "onboarding.version"

**App State Keys**:
- `lastAppVersion` - "app.last_version"
- `lastLaunchDate` - "app.last_launch_date"
- `launchCount` - "app.launch_count"

**Cache Keys**:
- `lastCacheCleanupDate` - "cache.last_cleanup"

**Usage**:
```swift
try storage.save(userProfile, forKey: StorageKey.userProfile)
let profile: UserProfile? = try storage.load(forKey: StorageKey.userProfile)
```

#### `@UserDefault` Property Wrapper (dòng 119-143)
Convenient property wrapper cho UserDefaults.

**Implementation**:
```swift
@propertyWrapper
public struct UserDefault<T: Codable> {
    private let key: String
    private let defaultValue: T
    private let storage: UserDefaultsStorage

    public init(
        key: String,
        defaultValue: T,
        storage: UserDefaultsStorage = UserDefaultsStorage()
    ) {
        self.key = key
        self.defaultValue = defaultValue
        self.storage = storage
    }

    public var wrappedValue: T {
        get {
            (try? storage.load(forKey: key)) ?? defaultValue
        }
        set {
            try? storage.save(newValue, forKey: key)
        }
    }
}
```

**Usage** (dòng 148-165):
```swift
class SettingsManager {
    @UserDefault(key: StorageKey.themeMode, defaultValue: "auto")
    var themeMode: String

    @UserDefault(key: StorageKey.notificationsEnabled, defaultValue: true)
    var notificationsEnabled: Bool

    @UserDefault(key: StorageKey.launchCount, defaultValue: 0)
    var launchCount: Int
}

let settings = SettingsManager()
settings.themeMode = "dark"
print(settings.themeMode) // "dark"
settings.launchCount += 1
```

**Advantages**:
- Type-safe access
- No manual key management
- Automatic save on set
- Default value handling

---

### 3. KeychainStorage.swift (183 dòng)

**Chức năng**: Secure storage sử dụng iOS Keychain via KeychainAccess framework

##### `KeychainStorage` (dòng 5-86)
Main Keychain wrapper.

**Properties**:
- `keychain: Keychain` - KeychainAccess instance

**Initialization** (dòng 13-16):
```swift
public init(service: String = Bundle.main.bundleIdentifier ?? "com.iostemplate.app") {
    self.keychain = Keychain(service: service)
        .accessibility(.afterFirstUnlock)
}
```

**Accessibility**: `.afterFirstUnlock`
- Data accessible sau khi device unlock lần đầu
- Balance giữa security và availability
- Recommended for most use cases

#### SecureStorageProtocol Implementation

##### `saveSecure` (dòng 20-26):
```swift
public func saveSecure(_ value: String, forKey key: String) throws {
    do {
        try keychain.set(value, key: key)
    } catch {
        throw StorageError.unknown(error)
    }
}
```

##### `loadSecure` (dòng 28-34):
```swift
public func loadSecure(forKey key: String) throws -> String? {
    do {
        return try keychain.getString(key)
    } catch {
        throw StorageError.unknown(error)
    }
}
```

##### `removeSecure` (dòng 36-42):
```swift
public func removeSecure(forKey key: String) throws {
    do {
        try keychain.remove(key)
    } catch {
        throw StorageError.unknown(error)
    }
}
```

##### `clearAllSecure` (dòng 44-50):
```swift
public func clearAllSecure() throws {
    do {
        try keychain.removeAll()
    } catch {
        throw StorageError.unknown(error)
    }
}
```

#### Additional Methods

##### `saveSecure<T: Codable>` (dòng 55-63)
Save Codable objects securely.

```swift
public func saveSecure<T: Codable>(_ value: T, forKey key: String) throws {
    let encoder = JSONEncoder()
    do {
        let data = try encoder.encode(value)
        try keychain.set(data, key: key)
    } catch {
        throw StorageError.encodingFailed
    }
}
```

**Usage**:
```swift
struct Credentials: Codable {
    let username: String
    let password: String
}

let creds = Credentials(username: "user", password: "pass")
try keychain.saveSecure(creds, forKey: "user.credentials")
```

##### `loadSecure<T: Codable>` (dòng 66-76)
Load Codable objects securely.

```swift
public func loadSecure<T: Codable>(forKey key: String) throws -> T? {
    let decoder = JSONDecoder()
    do {
        guard let data = try keychain.getData(key) else {
            return nil
        }
        return try decoder.decode(T.self, from: data)
    } catch {
        throw StorageError.decodingFailed
    }
}
```

##### `existsSecure` (dòng 79-85):
```swift
public func existsSecure(forKey key: String) -> Bool {
    do {
        return try keychain.contains(key)
    } catch {
        return false
    }
}
```

#### `SecureStorageKey` (dòng 91-107)
Predefined keys cho secure storage.

**Authentication Keys**:
- `accessToken` - "auth.access_token"
- `refreshToken` - "auth.refresh_token"
- `userID` - "auth.user_id"

**Biometric Keys**:
- `biometricEnabled` - "biometric.enabled"

**API Keys**:
- `apiKey` - "api.key"
- `apiSecret` - "api.secret"

**Credentials Keys**:
- `savedEmail` - "credentials.email"
- `savedPassword` - "credentials.password" (Only if explicitly allowed)

**⚠️ Security Warning**: Saving passwords trong Keychain chỉ nên dùng khi absolutely necessary và với user consent.

#### Biometric Authentication Extension (dòng 111-151)

Available khi `LocalAuthentication` framework có sẵn.

##### `saveBiometric` (dòng 116-133)
Save với biometric protection.

```swift
public func saveBiometric(_ value: String, forKey key: String) throws {
    let context = LAContext()
    var error: NSError?

    guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
        throw StorageError.accessDenied
    }

    // Create keychain with biometric protection
    let protectedKeychain = Keychain(service: keychain.service)
        .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)

    do {
        try protectedKeychain.set(value, key: key)
    } catch {
        throw StorageError.unknown(error)
    }
}
```

**Security Level**:
- `.whenPasscodeSetThisDeviceOnly` - Chỉ accessible khi có passcode
- `authenticationPolicy: .userPresence` - Require Face ID/Touch ID

##### `loadBiometric` (dòng 136-149)
Load với biometric authentication.

```swift
public func loadBiometric(forKey key: String, prompt: String = "Authenticate to access") throws -> String? {
    let context = LAContext()
    context.localizedReason = prompt

    let protectedKeychain = Keychain(service: keychain.service)
        .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
        .authenticationPrompt(prompt)

    do {
        return try protectedKeychain.getString(key)
    } catch {
        throw StorageError.accessDenied
    }
}
```

**User Experience**: iOS tự động hiển thị biometric prompt với custom message.

**Example Usage** (dòng 156-182):
```swift
let keychain = KeychainStorage()

// Basic usage
try keychain.saveSecure("my-access-token", forKey: SecureStorageKey.accessToken)
let token = try keychain.loadSecure(forKey: SecureStorageKey.accessToken)

// Biometric protected
try keychain.saveBiometric("sensitive-data", forKey: "sensitive.key")
let data = try keychain.loadBiometric(forKey: "sensitive.key", prompt: "Unlock app")

// Codable object
struct User: Codable {
    let id: String
    let name: String
}
let user = User(id: "123", name: "John")
try keychain.saveSecure(user, forKey: "user.data")
let loadedUser: User? = try keychain.loadSecure(forKey: "user.data")
```

---

### 4. FileStorage.swift (314 dòng)

**Chức năng**: File operations cho documents, cache, temporary directories

##### `FileStorage` (dòng 4-240)
Main file storage implementation.

**Properties**:
- `fileManager: FileManager` - File manager instance
- `directory: Directory` - Target directory type

##### `Directory` enum (dòng 12-27)
Storage directory types.

**Cases**:
- `.documents` - Documents directory (backed up by iCloud)
- `.cache` - Caches directory (not backed up, can be purged)
- `.temporary` - Temporary directory (purged by system when needed)

**Search path mapping**:
```swift
var searchPathDirectory: FileManager.SearchPathDirectory {
    switch self {
    case .documents:
        return .documentDirectory
    case .cache:
        return .cachesDirectory
    case .temporary:
        return .documentDirectory // temp uses documentDirectory base
    }
}
```

**Initialization** (dòng 31-37):
```swift
public init(
    directory: Directory = .documents,
    fileManager: FileManager = .default
) {
    self.directory = directory
    self.fileManager = fileManager
}
```

#### Private Helpers

##### `baseURL()` (dòng 41-54)
Get base URL for directory.

```swift
private func baseURL() throws -> URL {
    switch directory {
    case .temporary:
        return URL(fileURLWithPath: NSTemporaryDirectory())
    case .documents, .cache:
        guard let url = fileManager.urls(
            for: directory.searchPathDirectory,
            in: .userDomainMask
        ).first else {
            throw StorageError.accessDenied
        }
        return url
    }
}
```

#### FileStorageProtocol Implementation

##### `fileURL(fileName:)` (dòng 58-63)
```swift
public func fileURL(fileName: String) -> URL {
    guard let baseURL = try? baseURL() else {
        return URL(fileURLWithPath: fileName)
    }
    return baseURL.appendingPathComponent(fileName)
}
```

##### `saveFile` (dòng 65-85)
Save data to file với automatic directory creation.

```swift
public func saveFile(_ data: Data, fileName: String) throws -> URL {
    let url = fileURL(fileName: fileName)

    // Create intermediate directories if needed
    let directoryURL = url.deletingLastPathComponent()
    try fileManager.createDirectory(
        at: directoryURL,
        withIntermediateDirectories: true,
        attributes: nil
    )

    do {
        try data.write(to: url, options: .atomic)
        return url
    } catch {
        if (error as NSError).code == NSFileWriteOutOfSpaceError {
            throw StorageError.diskFull
        }
        throw StorageError.unknown(error)
    }
}
```

**Features**:
- Atomic write (prevent corruption)
- Automatic directory creation
- Disk full error handling

##### `loadFile` (dòng 87-99)
```swift
public func loadFile(fileName: String) throws -> Data {
    let url = fileURL(fileName: fileName)

    guard fileManager.fileExists(atPath: url.path) else {
        throw StorageError.notFound
    }

    do {
        return try Data(contentsOf: url)
    } catch {
        throw StorageError.unknown(error)
    }
}
```

##### `deleteFile` (dòng 101-113)
```swift
public func deleteFile(fileName: String) throws {
    let url = fileURL(fileName: fileName)

    guard fileManager.fileExists(atPath: url.path) else {
        throw StorageError.notFound
    }

    do {
        try fileManager.removeItem(at: url)
    } catch {
        throw StorageError.unknown(error)
    }
}
```

##### `fileExists` (dòng 115-118)
```swift
public func fileExists(fileName: String) -> Bool {
    let url = fileURL(fileName: fileName)
    return fileManager.fileExists(atPath: url.path)
}
```

##### `directorySize()` (dòng 120-143)
Calculate total directory size.

```swift
public func directorySize() throws -> Int64 {
    let baseURL = try baseURL()
    var totalSize: Int64 = 0

    guard let enumerator = fileManager.enumerator(
        at: baseURL,
        includingPropertiesForKeys: [.fileSizeKey],
        options: [.skipsHiddenFiles]
    ) else {
        return 0
    }

    for case let fileURL as URL in enumerator {
        guard let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path) else {
            continue
        }

        if let fileSize = attributes[.size] as? Int64 {
            totalSize += fileSize
        }
    }

    return totalSize
}
```

##### `clearDirectory()` (dòng 145-159)
Remove all files in directory.

```swift
public func clearDirectory() throws {
    let baseURL = try baseURL()

    guard let enumerator = fileManager.enumerator(
        at: baseURL,
        includingPropertiesForKeys: nil,
        options: [.skipsHiddenFiles]
    ) else {
        return
    }

    for case let fileURL as URL in enumerator {
        try? fileManager.removeItem(at: fileURL)
    }
}
```

#### Additional Utilities

##### `listFiles()` (dòng 164-178)
List all files in directory.

```swift
public func listFiles() throws -> [String] {
    let baseURL = try baseURL()

    let contents = try fileManager.contentsOfDirectory(
        at: baseURL,
        includingPropertiesForKeys: [.isRegularFileKey],
        options: [.skipsHiddenFiles]
    )

    return contents
        .filter { url in
            (try? url.resourceValues(forKeys: [.isRegularFileKey]))?.isRegularFile == true
        }
        .map { $0.lastPathComponent }
}
```

##### `fileSize(fileName:)` (dòng 181-190)
Get specific file size.

```swift
public func fileSize(fileName: String) throws -> Int64 {
    let url = fileURL(fileName: fileName)

    guard fileManager.fileExists(atPath: url.path) else {
        throw StorageError.notFound
    }

    let attributes = try fileManager.attributesOfItem(atPath: url.path)
    return attributes[.size] as? Int64 ?? 0
}
```

##### `saveObject<T: Codable>` (dòng 193-203)
Save Codable object to JSON file.

```swift
public func saveObject<T: Codable>(_ object: T, fileName: String) throws -> URL {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted

    do {
        let data = try encoder.encode(object)
        return try saveFile(data, fileName: fileName)
    } catch {
        throw StorageError.encodingFailed
    }
}
```

##### `loadObject<T: Codable>` (dòng 206-215)
Load Codable object from JSON file.

```swift
public func loadObject<T: Codable>(fileName: String) throws -> T {
    let data = try loadFile(fileName: fileName)
    let decoder = JSONDecoder()

    do {
        return try decoder.decode(T.self, from: data)
    } catch {
        throw StorageError.decodingFailed
    }
}
```

##### `copyFile` (dòng 218-227)
```swift
public func copyFile(from source: String, to destination: String) throws {
    let sourceURL = fileURL(fileName: source)
    let destURL = fileURL(fileName: destination)

    guard fileManager.fileExists(atPath: sourceURL.path) else {
        throw StorageError.notFound
    }

    try fileManager.copyItem(at: sourceURL, to: destURL)
}
```

##### `moveFile` (dòng 230-239)
```swift
public func moveFile(from source: String, to destination: String) throws {
    let sourceURL = fileURL(fileName: source)
    let destURL = fileURL(fileName: destination)

    guard fileManager.fileExists(atPath: sourceURL.path) else {
        throw StorageError.notFound
    }

    try fileManager.moveItem(at: sourceURL, to: destURL)
}
```

#### Convenience Extensions (dòng 244-259)

```swift
public extension FileStorage {
    /// Documents directory storage
    static var documents: FileStorage {
        FileStorage(directory: .documents)
    }

    /// Cache directory storage
    static var cache: FileStorage {
        FileStorage(directory: .cache)
    }

    /// Temporary directory storage
    static var temporary: FileStorage {
        FileStorage(directory: .temporary)
    }
}
```

**Usage**:
```swift
let docs = FileStorage.documents
let cache = FileStorage.cache
let temp = FileStorage.temporary
```

#### File Size Formatting (dòng 263-271)

```swift
public extension Int64 {
    /// Format file size to human readable string
    var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: self)
    }
}
```

**Usage**:
```swift
let size: Int64 = 1_500_000
print(size.formattedFileSize) // "1.5 MB"
```

**Example Usage** (dòng 276-313):
```swift
let fileStorage = FileStorage.documents

// Save data
let data = "Hello, World!".data(using: .utf8)!
let url = try fileStorage.saveFile(data, fileName: "hello.txt")

// Load data
let loadedData = try fileStorage.loadFile(fileName: "hello.txt")
let text = String(data: loadedData, encoding: .utf8)

// Save Codable object
struct User: Codable {
    let name: String
    let age: Int
}
let user = User(name: "John", age: 30)
try fileStorage.saveObject(user, fileName: "user.json")

// Load Codable object
let loadedUser: User = try fileStorage.loadObject(fileName: "user.json")

// Check file size
let size = try fileStorage.fileSize(fileName: "user.json")
print(size.formattedFileSize) // "234 bytes"

// List all files
let files = try fileStorage.listFiles()

// Get directory size
let totalSize = try fileStorage.directorySize()
print(totalSize.formattedFileSize) // "1.5 MB"

// Clear cache
let cache = FileStorage.cache
try cache.clearDirectory()
```

---

## Cách các Files hoạt động cùng nhau

### Storage Layer Architecture

```
┌─────────────────────────────────────────────────────┐
│              Application Layer                       │
│        (ViewModels, Features, Services)             │
└────────────────────┬────────────────────────────────┘
                     │ Use storage via protocols
                     ▼
┌─────────────────────────────────────────────────────┐
│            Storage Protocol Layer                    │
│  ┌──────────────┬───────────────┬────────────────┐ │
│  │StorageService│SecureStorage  │FileStorage     │ │
│  │Protocol      │Protocol       │Protocol        │ │
│  └──────────────┴───────────────┴────────────────┘ │
└─────┬──────────────┬────────────────┬──────────────┘
      │              │                │
      │ Implemented by                │
      ▼              ▼                ▼
┌─────────────┬──────────────┬───────────────────────┐
│UserDefaults │  Keychain    │   FileStorage         │
│Storage      │  Storage     │                       │
│             │              │  ┌─────────────────┐  │
│• Primitives │• Tokens      │  │• Documents      │  │
│• Codable    │• Credentials │  │• Cache          │  │
│• Settings   │• API Keys    │  │• Temporary      │  │
│             │• Biometric   │  └─────────────────┘  │
└─────────────┴──────────────┴───────────────────────┘
```

### Data Flow Examples

#### Example 1: Save User Profile

```swift
// 1. Feature calls storage
class ProfileViewModel {
    @Injected(StorageServiceProtocol.self)
    var storage: StorageServiceProtocol

    func saveProfile(_ profile: UserProfile) {
        do {
            // 2. Storage protocol method
            try storage.save(profile, forKey: StorageKey.userProfile)

            // 3. UserDefaultsStorage encodes to JSON
            // encoder.encode(profile) → Data
            // defaults.set(data, forKey: "user.profile")
            // defaults.synchronize()

            print("Profile saved")
        } catch {
            print("Error: \(error)")
        }
    }

    func loadProfile() -> UserProfile? {
        do {
            // Load from storage
            let profile: UserProfile? = try storage.load(forKey: StorageKey.userProfile)

            // UserDefaultsStorage:
            // data = defaults.data(forKey: "user.profile")
            // decoder.decode(UserProfile.self, from: data)

            return profile
        } catch {
            return nil
        }
    }
}
```

#### Example 2: Secure Token Management

```swift
// 1. AuthService manages tokens
class AuthService: AuthServiceProtocol {
    @Injected(SecureStorageProtocol.self)
    var keychain: SecureStorageProtocol

    @Injected(NetworkServiceProtocol.self)
    var network: NetworkServiceProtocol

    func login(email: String, password: String) async throws -> AuthResponse {
        // 2. Call network API
        let response: AuthResponse = try await network.request(
            endpoint: "/v1/auth/login",
            method: .post,
            parameters: ["email": email, "password": password],
            headers: nil
        )

        // 3. Save tokens securely to Keychain
        try keychain.saveSecure(response.accessToken, forKey: SecureStorageKey.accessToken)
        try keychain.saveSecure(response.refreshToken, forKey: SecureStorageKey.refreshToken)

        // KeychainStorage:
        // keychain.set(accessToken, key: "auth.access_token")
        // → iOS Keychain (encrypted)

        return response
    }

    func getAccessToken() -> String? {
        // Load token from Keychain
        try? keychain.loadSecure(forKey: SecureStorageKey.accessToken)

        // KeychainStorage:
        // keychain.getString("auth.access_token")
        // → Decrypted by iOS
    }
}
```

#### Example 3: File Caching

```swift
class ImageCacheService: ImageCacheServiceProtocol {
    @Injected(FileStorageProtocol.self, name: "cache")
    var fileStorage: FileStorageProtocol

    func cacheImage(_ data: Data, forKey key: String) {
        let fileName = "\(key).jpg"

        do {
            // Save to cache directory
            let url = try fileStorage.saveFile(data, fileName: fileName)

            // FileStorage:
            // baseURL = ~/Library/Caches/
            // url = ~/Library/Caches/image123.jpg
            // data.write(to: url, options: .atomic)

            print("Cached at: \(url)")
        } catch {
            print("Cache failed: \(error)")
        }
    }

    func getCachedImage(forKey key: String) -> Data? {
        let fileName = "\(key).jpg"

        do {
            return try fileStorage.loadFile(fileName: fileName)

            // FileStorage:
            // url = ~/Library/Caches/image123.jpg
            // Data(contentsOf: url)
        } catch {
            return nil
        }
    }

    func clearCache() {
        try? fileStorage.clearDirectory()

        // FileStorage:
        // enumerator = fileManager.enumerator(at: ~/Library/Caches/)
        // for file in files { fileManager.removeItem(at: file) }
    }

    func cacheSize() -> Int64 {
        (try? fileStorage.directorySize()) ?? 0

        // FileStorage:
        // totalSize = sum of all file sizes in directory
    }
}
```

---

## Integration Patterns

### Pattern 1: UserDefaults Property Wrapper

```swift
class AppSettings {
    @UserDefault(key: StorageKey.themeMode, defaultValue: "auto")
    var themeMode: String

    @UserDefault(key: StorageKey.notificationsEnabled, defaultValue: true)
    var notificationsEnabled: Bool

    @UserDefault(key: StorageKey.languageCode, defaultValue: "en")
    var languageCode: String

    func applyTheme() {
        switch themeMode {
        case "dark":
            // Apply dark theme
            break
        case "light":
            // Apply light theme
            break
        default:
            // Auto mode
            break
        }
    }
}

// Usage
let settings = AppSettings()
settings.themeMode = "dark" // Automatically saved
print(settings.themeMode)    // Automatically loaded
```

### Pattern 2: Multi-Layer Storage Strategy

```swift
class DataManager {
    @Injected(StorageServiceProtocol.self)
    var userDefaults: StorageServiceProtocol

    @Injected(SecureStorageProtocol.self)
    var keychain: SecureStorageProtocol

    @Injected(FileStorageProtocol.self)
    var fileStorage: FileStorageProtocol

    func saveUserData(_ user: User) throws {
        // 1. Save sensitive data to Keychain
        if let token = user.authToken {
            try keychain.saveSecure(token, forKey: SecureStorageKey.accessToken)
        }

        // 2. Save profile to UserDefaults
        try userDefaults.save(user.profile, forKey: StorageKey.userProfile)

        // 3. Save large data (avatar image) to File Storage
        if let avatarData = user.avatarImage {
            _ = try fileStorage.saveFile(avatarData, fileName: "avatar.jpg")
        }
    }

    func loadUserData() -> User? {
        // Load from different storages
        guard let profile: UserProfile = try? userDefaults.load(forKey: StorageKey.userProfile) else {
            return nil
        }

        let token = try? keychain.loadSecure(forKey: SecureStorageKey.accessToken)
        let avatarData = try? fileStorage.loadFile(fileName: "avatar.jpg")

        return User(profile: profile, authToken: token, avatarImage: avatarData)
    }
}
```

### Pattern 3: Biometric Protected Storage

```swift
class SecureVaultService {
    let keychain = KeychainStorage()

    func savePassword(_ password: String, forAccount account: String) throws {
        // Save with biometric protection
        try keychain.saveBiometric(password, forKey: "password.\(account)")
    }

    func getPassword(forAccount account: String) throws -> String? {
        // Requires Face ID/Touch ID
        try keychain.loadBiometric(
            forKey: "password.\(account)",
            prompt: "Authenticate to view password"
        )
    }
}
```

---

## Testing Strategies

### 1. Mock Storage Implementations

```swift
class MockStorage: StorageServiceProtocol {
    private var storage: [String: Any] = [:]

    func save<T: Codable>(_ value: T, forKey key: String) throws {
        storage[key] = value
    }

    func load<T: Codable>(forKey key: String) throws -> T? {
        storage[key] as? T
    }

    func remove(forKey key: String) {
        storage.removeValue(forKey: key)
    }

    func clearAll() {
        storage.removeAll()
    }

    func exists(forKey key: String) -> Bool {
        storage[key] != nil
    }
}

// Usage in tests
func testProfileSave() {
    let mockStorage = MockStorage()
    DIContainer.shared.register(StorageServiceProtocol.self) { _ in mockStorage }

    let viewModel = ProfileViewModel()
    viewModel.saveProfile(testProfile)

    let saved: UserProfile? = try? mockStorage.load(forKey: StorageKey.userProfile)
    XCTAssertEqual(saved?.id, testProfile.id)
}
```

### 2. Keychain Testing

```swift
class KeychainStorageTests: XCTestCase {
    var keychain: KeychainStorage!

    override func setUp() {
        super.setUp()
        keychain = KeychainStorage(service: "com.test.keychain")
    }

    override func tearDown() {
        try? keychain.clearAllSecure()
        super.tearDown()
    }

    func testSaveAndLoad() throws {
        try keychain.saveSecure("test-token", forKey: "test.key")
        let loaded = try keychain.loadSecure(forKey: "test.key")
        XCTAssertEqual(loaded, "test-token")
    }

    func testRemove() throws {
        try keychain.saveSecure("test-token", forKey: "test.key")
        try keychain.removeSecure(forKey: "test.key")

        let loaded = try? keychain.loadSecure(forKey: "test.key")
        XCTAssertNil(loaded)
    }
}
```

### 3. File Storage Testing

```swift
class FileStorageTests: XCTestCase {
    var fileStorage: FileStorage!

    override func setUp() {
        super.setUp()
        fileStorage = FileStorage.temporary
    }

    override func tearDown() {
        try? fileStorage.clearDirectory()
        super.tearDown()
    }

    func testSaveAndLoad() throws {
        let data = "Test content".data(using: .utf8)!
        let url = try fileStorage.saveFile(data, fileName: "test.txt")

        XCTAssertTrue(fileStorage.fileExists(fileName: "test.txt"))

        let loaded = try fileStorage.loadFile(fileName: "test.txt")
        XCTAssertEqual(loaded, data)
    }

    func testDirectorySize() throws {
        let data = Data(repeating: 0, count: 1000)
        _ = try fileStorage.saveFile(data, fileName: "file1.bin")
        _ = try fileStorage.saveFile(data, fileName: "file2.bin")

        let size = try fileStorage.directorySize()
        XCTAssertGreaterThan(size, 2000)
    }
}
```

---

## Best Practices

### 1. Choose the Right Storage

```swift
// ✅ UserDefaults - Small, non-sensitive data
try storage.save(themeMode, forKey: StorageKey.themeMode)
try storage.save(userPreferences, forKey: StorageKey.userPreferences)

// ✅ Keychain - Sensitive data
try keychain.saveSecure(accessToken, forKey: SecureStorageKey.accessToken)
try keychain.saveSecure(apiKey, forKey: SecureStorageKey.apiKey)

// ✅ File Storage - Large data
try fileStorage.saveFile(imageData, fileName: "avatar.jpg")
try fileStorage.saveObject(largeDataset, fileName: "data.json")

// ❌ Wrong - Don't save large data in UserDefaults
try storage.save(imageData, forKey: "image") // Bad performance

// ❌ Wrong - Don't save tokens in UserDefaults
try storage.save(accessToken, forKey: "token") // Insecure
```

### 2. Use Protocols for Testability

```swift
// ✅ Good - Depend on protocol
class MyService {
    @Injected(StorageServiceProtocol.self)
    var storage: StorageServiceProtocol
}

// ❌ Bad - Depend on concrete type
class MyService {
    let storage = UserDefaultsStorage()
}
```

### 3. Handle Errors Appropriately

```swift
// ✅ Good - Handle specific errors
func loadProfile() -> UserProfile? {
    do {
        return try storage.load(forKey: StorageKey.userProfile)
    } catch StorageError.decodingFailed {
        // Corrupted data - clear and retry
        storage.remove(forKey: StorageKey.userProfile)
        return nil
    } catch {
        // Unknown error - log it
        Logger.shared.error("Failed to load profile", error: error)
        return nil
    }
}

// ❌ Bad - Silent failure
func loadProfile() -> UserProfile? {
    try? storage.load(forKey: StorageKey.userProfile)
}
```

### 4. Clean Up Cache Regularly

```swift
class CacheManager {
    let cache = FileStorage.cache

    func cleanupIfNeeded() {
        let lastCleanup: Date? = try? storage.load(forKey: StorageKey.lastCacheCleanupDate)

        // Clean if > 7 days
        if let lastCleanup = lastCleanup,
           Date().timeIntervalSince(lastCleanup) < 7 * 24 * 60 * 60 {
            return
        }

        // Clean cache
        try? cache.clearDirectory()
        try? storage.save(Date(), forKey: StorageKey.lastCacheCleanupDate)
    }
}
```

### 5. Use Centralized Keys

```swift
// ✅ Good - Use StorageKey enum
try storage.save(value, forKey: StorageKey.userProfile)

// ❌ Bad - Magic strings
try storage.save(value, forKey: "user.profile")
```

---

## Performance Considerations

### 1. UserDefaults Performance

- **Fast** for small data (<100KB)
- **Slow** for large data or frequent writes
- **Synchronize** is automatic on iOS 12+

```swift
// ✅ Good - Batch updates
var settings = loadAllSettings()
settings.theme = "dark"
settings.language = "en"
saveAllSettings(settings)

// ❌ Bad - Multiple individual writes
storage.save("dark", forKey: "theme")
storage.save("en", forKey: "language")
```

### 2. Keychain Performance

- **Slower** than UserDefaults
- **Use sparingly** for sensitive data only
- **Cache** frequently accessed values

```swift
// Cache token in memory
class AuthManager {
    private var cachedToken: String?

    func getToken() -> String? {
        if let cached = cachedToken {
            return cached
        }

        cachedToken = try? keychain.loadSecure(forKey: SecureStorageKey.accessToken)
        return cachedToken
    }
}
```

### 3. File Storage Performance

- **Use cache directory** for temporary data
- **Implement size limits**
- **Clean up regularly**

```swift
class ImageCache {
    let maxCacheSize: Int64 = 50 * 1024 * 1024 // 50 MB

    func checkCacheSize() {
        guard let size = try? fileStorage.directorySize(),
              size > maxCacheSize else {
            return
        }

        // Clear cache if exceeded
        try? fileStorage.clearDirectory()
    }
}
```

---

## Dependencies

- **Foundation**: Swift standard library
- **KeychainAccess**: Keychain wrapper library

---

## Related Documentation

- [Services Layer](/Sources/iOSTemplate/Services/README.md) - DI and service protocols
- [Network Layer](/Sources/iOSTemplate/Network/README.md) - Network service using storage
- [Core Layer](/Sources/iOSTemplate/Core/README.md) - App state persistence

---

**Cập nhật**: 2025-11-15
**Maintainer**: iOS Team
