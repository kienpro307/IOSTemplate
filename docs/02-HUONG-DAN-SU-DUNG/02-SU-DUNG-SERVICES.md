# Sử Dụng Services

Hướng dẫn sử dụng các services trong iOS Template.

---

## Network Client

### Basic Usage

```swift
@Dependency(\.networkClient) var networkClient

case .fetchData:
    return .run { send in
        do {
            let data: MyData = try await networkClient.request(.getData)
            await send(.dataReceived(data))
        } catch {
            await send(.error(error))
        }
    }
```

### Define API Endpoints

**File:** `Sources/Core/Dependencies/APITarget.swift`

```swift
extension APITarget {
    static func getData() -> APITarget {
        APITarget(
            path: "/api/data",
            method: .get,
            task: .requestPlain
        )
    }
    
    static func postData(_ data: MyData) -> APITarget {
        APITarget(
            path: "/api/data",
            method: .post,
            task: .requestJSONEncodable(data)
        )
    }
}
```

---

## Storage Client

### Save & Load Data

```swift
@Dependency(\.storageClient) var storageClient

// Save
try await storageClient.save("key", value)

// Load
let value: MyType? = try? await storageClient.load("key")

// Delete
try await storageClient.delete("key")
```

---

## Keychain Client

### Secure Storage

```swift
@Dependency(\.keychainClient) var keychainClient

// Save token
try await keychainClient.save("access_token", token)

// Load token
let token = try? await keychainClient.load("access_token")

// Delete token
try await keychainClient.delete("access_token")
```

---

## Cache Client

### Memory + Disk Cache

```swift
@Dependency(\.cacheClient) var cacheClient

// Save to cache
try await cacheClient.save("key", data, expiration: .hours(24))

// Load from cache
let data: Data? = try? await cacheClient.load("key")

// Clear cache
try await cacheClient.clear()
```

---

## Logger Client

### Logging

```swift
@Dependency(\.logger) var logger

await logger.verbose("Verbose message")
await logger.debug("Debug message")
await logger.info("Info message")
await logger.warning("Warning message")
await logger.error("Error message")
```

---

## Xem Thêm

- [Tạo Feature Mới](01-TAO-TINH-NANG-MOI.md)
- [Firebase](../03-TINH-NANG-CO-SAN/04-FIREBASE.md)

