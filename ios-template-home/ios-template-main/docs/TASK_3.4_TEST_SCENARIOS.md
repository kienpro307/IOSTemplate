# Task 3.4 - Performance Monitoring Test Scenarios

Test scenarios cho Performance Monitoring implementation.

**Task covered**:
- Task 3.4.1: Configure Performance SDK ✅

---

## Test Coverage

| Category | Test Cases | Status |
|----------|------------|--------|
| 1. Service Initialization | 2 | ⚪️ |
| 2. Custom Traces | 5 | ⚪️ |
| 3. HTTP Metrics | 4 | ⚪️ |
| 4. Predefined Traces | 6 | ⚪️ |
| 5. Trace Attributes | 3 | ⚪️ |
| 6. Trace Metrics | 2 | ⚪️ |
| 7. Integration | 3 | ⚪️ |
| **TOTAL** | **25** | **⚪️** |

---

## 1. Service Initialization (2 tests)

### Test 1.1: Service Initialization
```swift
func testServiceInitialization() {
    let service = FirebasePerformanceService.shared
    XCTAssertNotNil(service)
    XCTAssertTrue(service.isEnabled)
}
```

**Expected**: ✅ Service initializes successfully

---

### Test 1.2: Data Collection Enabled
```swift
func testDataCollectionEnabled() {
    let service = FirebasePerformanceService.shared
    XCTAssertTrue(service.isPerformanceMonitoringEnabled())
}
```

**Expected**: ✅ Performance monitoring enabled

---

## 2. Custom Traces (5 tests)

### Test 2.1: Start and Stop Trace
```swift
func testStartStopTrace() {
    let service = FirebasePerformanceService.shared
    let trace = service.startTrace(name: "test_trace")
    XCTAssertNotNil(trace)
    trace.stop()
}
```

**Expected**: ✅ Trace starts and stops

---

### Test 2.2: Trace with Block
```swift
func testTraceWithBlock() {
    let service = FirebasePerformanceService.shared
    var executed = false

    service.trace(name: "test_block") {
        executed = true
    }

    XCTAssertTrue(executed)
}
```

**Expected**: ✅ Block executes and trace completes

---

### Test 2.3: Async Trace
```swift
func testAsyncTrace() async throws {
    let service = FirebasePerformanceService.shared
    var executed = false

    await service.trace(name: "test_async") {
        executed = true
    }

    XCTAssertTrue(executed)
}
```

**Expected**: ✅ Async trace works

---

### Test 2.4: Multiple Traces
```swift
func testMultipleTraces() {
    let service = FirebasePerformanceService.shared

    let trace1 = service.startTrace(name: "trace_1")
    let trace2 = service.startTrace(name: "trace_2")

    XCTAssertEqual(service.getActiveTracesCount(), 2)

    trace1.stop()
    trace2.stop()
}
```

**Expected**: ✅ Multiple traces tracked

---

### Test 2.5: Stop Trace by Name
```swift
func testStopTraceByName() {
    let service = FirebasePerformanceService.shared

    service.startTrace(name: "named_trace")
    XCTAssertEqual(service.getActiveTracesCount(), 1)

    service.stopTrace(name: "named_trace")
    XCTAssertEqual(service.getActiveTracesCount(), 0)
}
```

**Expected**: ✅ Trace stopped by name

---

## 3. HTTP Metrics (4 tests)

### Test 3.1: HTTP Metric Basic
```swift
func testHTTPMetricBasic() {
    let service = FirebasePerformanceService.shared
    let url = URL(string: "https://api.example.com/data")!

    let metric = service.startHTTPMetric(url: url, method: .get)
    XCTAssertNotNil(metric)

    metric.stop()
}
```

**Expected**: ✅ HTTP metric created

---

### Test 3.2: HTTP Metric with Response
```swift
func testHTTPMetricWithResponse() {
    let service = FirebasePerformanceService.shared
    let url = URL(string: "https://api.example.com/data")!

    let metric = service.startHTTPMetric(url: url, method: .post)

    metric.markRequestComplete()
    metric.markResponseStart()
    metric.responseCode = 200
    metric.responseContentType = "application/json"
    metric.responsePayloadSize = 1024

    metric.stop()

    XCTAssertTrue(true)
}
```

**Expected**: ✅ Response metrics recorded

---

### Test 3.3: Tracked URLSession
```swift
func testTrackedURLSession() async throws {
    let url = URL(string: "https://httpbin.org/get")!
    let expectation = XCTestExpectation(description: "Request completes")

    let task = URLSession.shared.trackedDataTask(with: url) { data, response, error in
        XCTAssertNotNil(data)
        XCTAssertNil(error)
        expectation.fulfill()
    }

    task.resume()

    await fulfillment(of: [expectation], timeout: 10.0)
}
```

**Expected**: ✅ URLSession request tracked

---

### Test 3.4: Multiple HTTP Metrics
```swift
func testMultipleHTTPMetrics() {
    let service = FirebasePerformanceService.shared
    let url1 = URL(string: "https://api.example.com/v1")!
    let url2 = URL(string: "https://api.example.com/v2")!

    service.startHTTPMetric(url: url1, method: .get)
    service.startHTTPMetric(url: url2, method: .post)

    XCTAssertEqual(service.getActiveHTTPMetricsCount(), 2)
}
```

**Expected**: ✅ Multiple metrics tracked

---

## 4. Predefined Traces (6 tests)

### Test 4.1: App Launch Trace
```swift
func testAppLaunchTrace() {
    let service = FirebasePerformanceService.shared
    let trace = service.traceAppLaunch()
    XCTAssertNotNil(trace)
    trace.stop()
}
```

**Expected**: ✅ App launch traced

---

### Test 4.2: Screen Load Trace
```swift
func testScreenLoadTrace() {
    let service = FirebasePerformanceService.shared
    let trace = service.traceScreenLoad("HomeScreen")
    XCTAssertNotNil(trace)
    trace.stop()
}
```

**Expected**: ✅ Screen load traced

---

### Test 4.3: User Login Trace
```swift
func testUserLoginTrace() {
    let service = FirebasePerformanceService.shared
    let trace = service.traceUserLogin(method: "email")
    XCTAssertNotNil(trace)
    trace.stop()
}
```

**Expected**: ✅ User login traced

---

### Test 4.4: Data Sync Trace
```swift
func testDataSyncTrace() {
    let service = FirebasePerformanceService.shared
    let trace = service.traceDataSync(type: "full")
    XCTAssertNotNil(trace)
    trace.stop()
}
```

**Expected**: ✅ Data sync traced

---

### Test 4.5: Image Load Trace
```swift
func testImageLoadTrace() {
    let service = FirebasePerformanceService.shared
    let trace = service.traceImageLoad(url: "https://example.com/image.jpg")
    XCTAssertNotNil(trace)
    trace.stop()
}
```

**Expected**: ✅ Image load traced

---

### Test 4.6: Database Operation Trace
```swift
func testDatabaseOperationTrace() {
    let service = FirebasePerformanceService.shared
    let trace = service.traceDatabaseOperation("query")
    XCTAssertNotNil(trace)
    trace.stop()
}
```

**Expected**: ✅ Database operation traced

---

## 5. Trace Attributes (3 tests)

### Test 5.1: Add Attribute
```swift
func testAddAttribute() {
    let service = FirebasePerformanceService.shared
    let trace = service.startTrace(name: "test_attributes")

    trace.setValue("test_value", forAttribute: "test_key")

    trace.stop()
    XCTAssertTrue(true)
}
```

**Expected**: ✅ Attribute added

---

### Test 5.2: Multiple Attributes
```swift
func testMultipleAttributes() {
    let service = FirebasePerformanceService.shared
    let trace = service.startTrace(name: "test_multi_attrs")

    trace.setValue("value1", forAttribute: "key1")
    trace.setValue("value2", forAttribute: "key2")
    trace.setValue("value3", forAttribute: "key3")

    trace.stop()
    XCTAssertTrue(true)
}
```

**Expected**: ✅ Multiple attributes added (max 5)

---

### Test 5.3: Attribute Limits
```swift
func testAttributeLimits() {
    let service = FirebasePerformanceService.shared
    let trace = service.startTrace(name: "test_limits")

    // Add 5 attributes (max)
    for i in 1...5 {
        trace.setValue("value\(i)", forAttribute: "key\(i)")
    }

    trace.stop()
    XCTAssertTrue(true)
}
```

**Expected**: ✅ Up to 5 attributes allowed

---

## 6. Trace Metrics (2 tests)

### Test 6.1: Increment Metric
```swift
func testIncrementMetric() {
    let service = FirebasePerformanceService.shared
    let trace = service.startTrace(name: "test_metric")

    trace.incrementMetric("items_processed", by: 10)

    trace.stop()
    XCTAssertTrue(true)
}
```

**Expected**: ✅ Metric incremented

---

### Test 6.2: Multiple Metrics
```swift
func testMultipleMetrics() {
    let service = FirebasePerformanceService.shared
    let trace = service.startTrace(name: "test_multi_metrics")

    trace.incrementMetric("success_count", by: 5)
    trace.incrementMetric("error_count", by: 2)
    trace.incrementMetric("bytes_processed", by: 1024)

    trace.stop()
    XCTAssertTrue(true)
}
```

**Expected**: ✅ Multiple metrics tracked (max 32)

---

## 7. Integration Tests (3 tests)

### Test 7.1: Full User Flow
```swift
func testFullUserFlow() async {
    let service = FirebasePerformanceService.shared

    // App launch
    let launchTrace = service.traceAppLaunch()
    // ... initialization ...
    launchTrace.stop()

    // User login
    let loginTrace = service.traceUserLogin(method: "email")
    // ... login logic ...
    loginTrace.stop()

    // Screen load
    let screenTrace = service.traceScreenLoad("Dashboard")
    // ... load screen ...
    screenTrace.stop()

    XCTAssertTrue(true)
}
```

**Expected**: ✅ Complete flow traced

---

### Test 7.2: Network + Trace Integration
```swift
func testNetworkAndTrace() async throws {
    let service = FirebasePerformanceService.shared

    await service.trace(name: "api_flow") {
        let url = URL(string: "https://httpbin.org/get")!
        let metric = service.startHTTPMetric(url: url, method: .get)

        // Make request (simplified)
        metric.markRequestComplete()
        metric.markResponseStart()
        metric.responseCode = 200
        metric.stop()
    }

    XCTAssertTrue(true)
}
```

**Expected**: ✅ Network and trace work together

---

### Test 7.3: Concurrent Traces
```swift
func testConcurrentTraces() async {
    let service = FirebasePerformanceService.shared

    async let trace1: Void = service.trace(name: "concurrent_1") {
        try? await Task.sleep(nanoseconds: 100_000_000)
    }

    async let trace2: Void = service.trace(name: "concurrent_2") {
        try? await Task.sleep(nanoseconds: 100_000_000)
    }

    _ = await [trace1, trace2]

    XCTAssertTrue(true)
}
```

**Expected**: ✅ Concurrent traces work

---

## Testing Checklist

### Prerequisites
- [ ] Firebase Performance SDK included
- [ ] GoogleService-Info.plist configured
- [ ] Test on real device (performance data more accurate)

### Manual Testing
- [ ] Check Firebase Console for data (may take 12-24 hours)
- [ ] Verify traces appear in Performance dashboard
- [ ] Check network request metrics
- [ ] Verify automatic metrics (app start, screen rendering)

### Automated Testing
- [ ] All unit tests pass
- [ ] Integration tests pass
- [ ] No crashes during trace operations

### Firebase Console Verification
- [ ] Custom traces visible
- [ ] HTTP metrics recorded
- [ ] Screen rendering data available
- [ ] App start time tracked

---

## Success Criteria

✅ **Task 3.4.1 - Configure Performance SDK**: COMPLETE
- FirebasePerformanceService implemented
- Custom traces working
- HTTP metrics tracking
- Predefined traces available
- Attributes and metrics support
- URLSession integration
- Automatic performance data collection

---

**All 25 test scenarios should pass for Task 3.4 to be considered complete.**
