# Performance Monitoring Guide

Hướng dẫn toàn diện về Firebase Performance Monitoring trong iOS Template Project.

---

## 📋 Overview

Firebase Performance Monitoring tự động thu thập metrics về app performance:
- **App start time**: Thời gian khởi động app
- **Screen rendering**: Frame rate, slow/frozen frames
- **Network requests**: Response time, payload size, success rate
- **Custom traces**: Track specific operations

---

## Quick Start

### 1. Basic Usage

```swift
import iOSTemplate

// Track custom operation
let trace = FirebasePerformanceService.shared.startTrace(name: "user_login")
// ... perform login ...
trace.stop()

// Convenience method
FirebasePerformanceService.shared.trace(name: "process_data") {
    // ... process data ...
}

// Async version
await FirebasePerformanceService.shared.trace(name: "fetch_data") {
    let data = try await api.fetchData()
}
```

### 2. Track Network Requests

```swift
// Manual tracking
let metric = FirebasePerformanceService.shared.startHTTPMetric(
    url: url,
    method: .post
)

metric.markRequestComplete()
metric.markResponseStart()
metric.responseCode = 200
metric.responseContentType = "application/json"
metric.stop()

// Automatic tracking (URLSession extension)
let task = URLSession.shared.trackedDataTask(with: url) { data, response, error in
    // Handle response
}
task.resume()
```

### 3. Predefined Traces

```swift
// App launch
let trace = FirebasePerformanceService.shared.traceAppLaunch()
// ... initialization ...
trace.stop()

// Screen load
let trace = service.traceScreenLoad("HomeScreen")
// ... load screen ...
trace.stop()

// User login
let trace = service.traceUserLogin(method: "email")
// ... login logic ...
trace.stop()
```

---

## Available Traces

### Predefined Traces

```swift
// App lifecycle
traceAppLaunch()

// User flows
traceUserLogin(method: "email")

// Data operations
traceDataSync(type: "full")
traceDatabaseOperation("query")

// Media
traceImageLoad(url: imageURL)

// File operations
// traceFileUpload()
// traceFileDownload()
```

### Custom Traces

```swift
// Simple trace
let trace = service.startTrace(name: "custom_operation")
trace.stop()

// With attributes (max 5)
let trace = service.startTrace(name: "checkout")
trace.setValue("credit_card", forAttribute: "payment_method")
trace.setValue("express", forAttribute: "shipping_method")
trace.stop()

// With metrics (max 32)
let trace = service.startTrace(name: "batch_process")
trace.incrementMetric("items_processed", by: 100)
trace.incrementMetric("errors_encountered", by: 2)
trace.stop()
```

---

## Best Practices

### ✅ DO

1. **Track key user flows**
   ```swift
   let trace = service.traceUserLogin(method: loginMethod)
   // Login logic
   trace.stop()
   ```

2. **Add meaningful attributes**
   ```swift
   trace.setValue(paymentMethod, forAttribute: "payment_type")
   ```

3. **Stop traces after operations complete**
   ```swift
   defer { trace.stop() }
   ```

4. **Use predefined traces when available**
   ```swift
   service.traceAppLaunch() // Instead of custom "app_start"
   ```

### ❌ DON'T

1. **Don't track too many operations** (adds overhead)
2. **Don't leave traces running indefinitely**
3. **Don't add sensitive data to attributes**
4. **Don't exceed limits**: 5 attributes, 32 metrics per trace

---

## Firebase Console

View performance data:
1. Firebase Console → Performance
2. Dashboard shows:
   - App start time
   - Network requests
   - Custom traces
   - Screen rendering
3. Filter by:
   - Time range
   - App version
   - Device type
   - OS version

---

**Next**: See [TASK_3.4_TEST_SCENARIOS.md](TASK_3.4_TEST_SCENARIOS.md) for testing checklist.
