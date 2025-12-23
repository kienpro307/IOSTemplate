# Performance Optimization Guide

## Overview

This guide covers performance optimization strategies for the iOS Template project, including memory management, launch time optimization, and network performance.

## Table of Contents

1. [Memory Profiling](#memory-profiling)
2. [Launch Time Optimization](#launch-time-optimization)
3. [Network Performance](#network-performance)
4. [UI Performance](#ui-performance)
5. [Battery Optimization](#battery-optimization)
6. [Profiling Tools](#profiling-tools)

---

## Memory Profiling

### Memory Management Goals

- **No memory leaks**: Zero retain cycles
- **Memory warnings handled**: Graceful degradation
- **Image memory optimized**: Proper downsampling
- **Cache limits**: Reasonable memory caps

### Using Instruments

1. **Open Instruments**
   ```
   Xcode → Product → Profile (Cmd + I)
   Select "Leaks" or "Allocations" template
   ```

2. **Memory Leak Detection**
   - Run app through all user flows
   - Check for leaks (red icons)
   - Investigate retain cycles
   - Fix strong reference cycles

3. **Allocation Tracking**
   - Monitor total memory usage
   - Identify memory spikes
   - Check for excessive allocations
   - Profile image loading

### Common Memory Issues

#### Issue 1: Retain Cycles

**Problem:**
```swift
class ViewModel {
    var completion: (() -> Void)?

    func setup() {
        completion = {
            self.doSomething() // Retain cycle!
        }
    }
}
```

**Fix:**
```swift
class ViewModel {
    var completion: (() -> Void)?

    func setup() {
        completion = { [weak self] in
            self?.doSomething()
        }
    }
}
```

#### Issue 2: Large Image Memory

**Problem:**
```swift
// Loading full-resolution image
Image(uiImage: UIImage(named: "large-image")!)
    .resizable()
    .frame(width: 100, height: 100)
```

**Fix:**
```swift
// Downsample before displaying
AsyncImage(url: imageURL) { image in
    image
        .resizable()
        .aspectRatio(contentMode: .fill)
} placeholder: {
    ProgressView()
}
.frame(width: 100, height: 100)
.clipped()
```

#### Issue 3: Unbounded Cache

**Problem:**
```swift
class Cache {
    var items: [String: Data] = [:] // Grows indefinitely!
}
```

**Fix:**
```swift
class Cache {
    private let cache = NSCache<NSString, NSData>()

    init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }
}
```

### Memory Warning Handling

```swift
class ViewModel: ObservableObject {
    private var memoryWarningObserver: NSObjectProtocol?

    init() {
        memoryWarningObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleMemoryWarning()
        }
    }

    func handleMemoryWarning() {
        // Clear caches
        MemoryCache.shared.removeAll()
        DiskCache.shared.removeOldItems()

        // Release large objects
        largeDataSet = nil

        logWarning("Memory warning received - caches cleared")
    }

    deinit {
        if let observer = memoryWarningObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
```

---

## Launch Time Optimization

### Performance Goals

- **Cold launch**: < 2 seconds
- **Warm launch**: < 0.5 seconds
- **First meaningful paint**: < 1 second

### Measuring Launch Time

1. **Using Instruments**
   ```
   Xcode → Product → Profile
   Select "Time Profiler" template
   Filter by "Main Thread"
   ```

2. **Using XCTest**
   ```swift
   func testLaunchPerformance() {
       measure(metrics: [XCTApplicationLaunchMetric()]) {
           app.launch()
       }
   }
   ```

### Optimization Strategies

#### 1. Lazy Loading

**Before:**
```swift
@main
struct MyApp: App {
    init() {
        setupAnalytics()
        setupCrashlytics()
        setupRemoteConfig()
        loadUserPreferences()
        initializeDatabase()
        preloadImages()
    }
}
```

**After:**
```swift
@main
struct MyApp: App {
    init() {
        // Only critical initialization
        setupCrashlytics() // Critical for crash reporting
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .task {
                    // Lazy initialization after first frame
                    await initializeServices()
                }
        }
    }

    private func initializeServices() async {
        // Run in background
        Task {
            await setupAnalytics()
            await setupRemoteConfig()
        }

        Task {
            await loadUserPreferences()
        }

        Task {
            await initializeDatabase()
        }
    }
}
```

#### 2. Optimize App Delegate

```swift
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // ONLY critical setup here
        FirebaseApp.configure()

        // Defer non-critical work
        DispatchQueue.main.async {
            self.setupNonCriticalServices()
        }

        return true
    }

    private func setupNonCriticalServices() {
        // Analytics, etc.
    }
}
```

#### 3. Reduce Dylib Loading

```swift
// Package.swift - Only import what you need
.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
// Don't import entire Firebase
.product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
.product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
```

#### 4. Optimize Asset Loading

```swift
// Use asset catalogs
// Compress images
// Use appropriate formats (HEIC for photos, PDF/SVG for icons)

// Lazy load images
LazyVStack {
    ForEach(items) { item in
        AsyncImage(url: item.imageURL)
    }
}
```

### Launch Time Checklist

- [ ] Minimize work in `init()`
- [ ] Defer analytics initialization
- [ ] Lazy load heavy resources
- [ ] Optimize asset catalog
- [ ] Reduce framework dependencies
- [ ] Use dynamic frameworks sparingly
- [ ] Profile with Time Profiler
- [ ] Test on older devices
- [ ] Monitor app startup time in production

---

## Network Performance

### Performance Goals

- **Request batching**: Group related requests
- **Response compression**: Use gzip/brotli
- **Image optimization**: Serve appropriate sizes
- **Pagination**: Load data in chunks
- **Caching**: Cache responses appropriately

### Request Optimization

#### 1. Request Batching

**Before:**
```swift
// Multiple individual requests
for id in userIDs {
    let user = try await api.fetchUser(id: id)
    users.append(user)
}
```

**After:**
```swift
// Single batch request
let users = try await api.fetchUsers(ids: userIDs)
```

#### 2. Response Compression

```swift
// NetworkService.swift
private func configureSession() -> URLSession {
    let configuration = URLSessionConfiguration.default
    configuration.httpAdditionalHeaders = [
        "Accept-Encoding": "gzip, deflate, br"
    ]
    configuration.requestCachePolicy = .useProtocolCachePolicy
    return URLSession(configuration: configuration)
}
```

#### 3. Request Coalescing

```swift
actor RequestCoalescer<Key: Hashable, Value> {
    private var pending: [Key: Task<Value, Error>] = [:]

    func request(for key: Key, perform: @escaping () async throws -> Value) async throws -> Value {
        // If request is already pending, return same task
        if let existingTask = pending[key] {
            return try await existingTask.value
        }

        // Create new task
        let task = Task {
            defer { pending[key] = nil }
            return try await perform()
        }

        pending[key] = task
        return try await task.value
    }
}

// Usage
let coalescer = RequestCoalescer<String, User>()

// Multiple calls with same ID return same request
let user = try await coalescer.request(for: userID) {
    try await api.fetchUser(id: userID)
}
```

#### 4. Pagination

```swift
struct PaginatedView: View {
    @State private var items: [Item] = []
    @State private var page = 1
    @State private var isLoading = false

    var body: some View {
        List {
            ForEach(items) { item in
                ItemRow(item: item)
                    .onAppear {
                        // Load more when near end
                        if item == items.last {
                            loadMore()
                        }
                    }
            }

            if isLoading {
                ProgressView()
            }
        }
        .task {
            await loadInitial()
        }
    }

    func loadMore() {
        guard !isLoading else { return }

        Task {
            isLoading = true
            defer { isLoading = false }

            let newItems = try await api.fetchItems(page: page)
            items.append(contentsOf: newItems)
            page += 1
        }
    }
}
```

### Image Optimization

#### 1. Serve Appropriate Sizes

```swift
enum ImageSize {
    case thumbnail // 100x100
    case medium // 300x300
    case large // 600x600
    case original

    var queryParam: String {
        switch self {
        case .thumbnail: return "?size=100"
        case .medium: return "?size=300"
        case .large: return "?size=600"
        case .original: return ""
        }
    }
}

// Request appropriate size
AsyncImage(url: URL(string: imageURL + ImageSize.thumbnail.queryParam))
```

#### 2. Progressive Image Loading

```swift
AsyncImage(url: imageURL) { phase in
    switch phase {
    case .empty:
        ProgressView()
    case .success(let image):
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
    case .failure:
        Image(systemName: "photo")
    @unknown default:
        EmptyView()
    }
}
```

### Network Caching

```swift
// Configure URL cache
let cache = URLCache(
    memoryCapacity: 10 * 1024 * 1024, // 10 MB
    diskCapacity: 50 * 1024 * 1024,    // 50 MB
    diskPath: "network-cache"
)
URLCache.shared = cache

// Use cache-control headers
var request = URLRequest(url: url)
request.cachePolicy = .returnCacheDataElseLoad
request.setValue("max-age=3600", forHTTPHeaderField: "Cache-Control")
```

### Network Performance Checklist

- [ ] Batch related API requests
- [ ] Enable response compression
- [ ] Implement request coalescing
- [ ] Use pagination for lists
- [ ] Optimize image sizes
- [ ] Configure URL caching
- [ ] Handle offline scenarios
- [ ] Monitor network metrics
- [ ] Test on slow connections (3G)

---

## UI Performance

### Goals

- **60 FPS**: Smooth scrolling
- **No dropped frames**: Consistent rendering
- **Fast interactions**: < 100ms response time

### SwiftUI Optimization

#### 1. Avoid Expensive Body Calculations

**Problem:**
```swift
struct ContentView: View {
    @State private var items: [Item] = []

    var body: some View {
        List {
            // Expensive calculation on every render!
            ForEach(items.sorted { $0.date > $1.date }) { item in
                ItemRow(item: item)
            }
        }
    }
}
```

**Fix:**
```swift
struct ContentView: View {
    @State private var items: [Item] = []

    var sortedItems: [Item] {
        items.sorted { $0.date > $1.date }
    }

    var body: some View {
        List {
            ForEach(sortedItems) { item in
                ItemRow(item: item)
            }
        }
    }
}

// Or better: sort once when data changes
@State private var sortedItems: [Item] = []

func updateItems(_ newItems: [Item]) {
    sortedItems = newItems.sorted { $0.date > $1.date }
}
```

#### 2. Use Lazy Stacks

```swift
// For long lists
LazyVStack {
    ForEach(items) { item in
        ItemRow(item: item)
    }
}

// For grids
LazyVGrid(columns: columns) {
    ForEach(items) { item in
        GridItem(item: item)
    }
}
```

#### 3. Optimize Identifiable

```swift
// Use stable, unique IDs
struct Item: Identifiable {
    let id: UUID // Good
    // var id: String { name } // Bad - not stable
}
```

#### 4. Minimize State Changes

```swift
// Bad - triggers many updates
@State private var count = 0
Button("Increment") {
    for _ in 0..<100 {
        count += 1 // 100 updates!
    }
}

// Good - single update
@State private var count = 0
Button("Increment") {
    count += 100 // 1 update
}
```

### Profiling UI Performance

```bash
# Run with Metal System Trace
Instruments → Metal System Trace
Check for:
- Frame rate
- GPU usage
- Draw calls
```

---

## Battery Optimization

### Strategies

1. **Reduce location updates**
   ```swift
   locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
   locationManager.distanceFilter = 100 // meters
   ```

2. **Batch network requests**
3. **Use background tasks efficiently**
4. **Minimize animations**
5. **Reduce CPU usage in background**

---

## Profiling Tools

### Xcode Instruments

1. **Time Profiler**: CPU usage
2. **Allocations**: Memory allocation
3. **Leaks**: Memory leaks
4. **Network**: Network activity
5. **Energy Log**: Battery usage
6. **Metal System Trace**: GPU performance

### MetricKit

```swift
import MetricKit

class MetricsManager: NSObject, MXMetricManagerSubscriber {
    override init() {
        super.init()
        MXMetricManager.shared.add(self)
    }

    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            // Analyze metrics
            if let cpuMetrics = payload.cpuMetrics {
                print("CPU time: \(cpuMetrics.cumulativeCPUTime)")
            }

            if let memoryMetrics = payload.memoryMetrics {
                print("Peak memory: \(memoryMetrics.peakMemoryUsage)")
            }

            // Send to analytics
            FirebasePerformanceService.shared.trackCustomMetric(payload)
        }
    }
}
```

---

## Performance Checklist

### Before Release

- [ ] Run Instruments Time Profiler
- [ ] Check for memory leaks
- [ ] Measure launch time on old devices
- [ ] Test on slow network (3G)
- [ ] Profile image loading
- [ ] Check battery usage
- [ ] Monitor FPS during scrolling
- [ ] Test with large datasets
- [ ] Verify cache limits
- [ ] Review network request count

### Continuous Monitoring

- [ ] Track launch time metrics
- [ ] Monitor crash-free rate
- [ ] Track API response times
- [ ] Monitor memory usage
- [ ] Track battery drain
- [ ] Monitor FPS in production
- [ ] Review performance reports

---

## Resources

- [Apple Performance Documentation](https://developer.apple.com/documentation/xcode/improving-your-app-s-performance)
- [WWDC Performance Sessions](https://developer.apple.com/videos/performance)
- [SwiftUI Performance Tips](https://www.swiftbysundell.com/articles/swiftui-performance-tips/)
