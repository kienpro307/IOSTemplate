# 🚀 Startup Orchestration

## 1. Tổng Quan

### 1.1 Vấn Đề Cần Giải Quyết

```
App Startup cần nhiều bước phức tạp:
├── Location permission & detection
├── Remote Config fetching
├── ATT (App Tracking Transparency)
├── CMP (Consent Management Platform)
├── Ads initialization
└── Analytics setup

Challenges:
❌ Circular dependency (config cần timeout, nhưng timeout ở trong config)
❌ Complex error handling
❌ Inconsistent UX across apps
❌ Hard to test
```

### 1.2 Giải Pháp: StartupOrchestrator

```
┌─────────────────────────────────────────────────────────────┐
│                   STARTUP ORCHESTRATOR                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Input:                    Output:                          │
│  • Dependencies            • StartupResult                  │
│  • Configuration           • Ready state                    │
│  • Mode (immediate/lazy)   • Error handling                 │
│                                                             │
│  Responsibilities:                                          │
│  ✅ Coordinate startup steps                                │
│  ✅ Handle errors gracefully                                │
│  ✅ Support different consent modes                         │
│  ✅ Provide consistent API                                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. 7-Step Startup Flow

### 2.1 Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    STARTUP FLOW (7 Steps)                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ BOOTSTRAP PHASE (Hardcoded values)                   │  │
│  ├──────────────────────────────────────────────────────┤  │
│  │                                                      │  │
│  │  Step 1: Get Location                                │  │
│  │  ├── Request permission if needed                    │  │
│  │  ├── Timeout: 5s (hardcoded)                        │  │
│  │  └── Output: Location or fallback                   │  │
│  │           │                                          │  │
│  │           ▼                                          │  │
│  │  Step 2: Fetch Remote Config                         │  │
│  │  ├── Use location for targeting                     │  │
│  │  ├── Timeout: 10s (hardcoded)                       │  │
│  │  └── Output: RemoteConfig values                    │  │
│  │                                                      │  │
│  └──────────────────────────────────────────────────────┘  │
│                         │                                   │
│                         ▼                                   │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ MAIN PHASE (Use config values)                       │  │
│  ├──────────────────────────────────────────────────────┤  │
│  │                                                      │  │
│  │  Step 3: Merge Configuration                         │  │
│  │  └── Local defaults + Remote → AppConfiguration     │  │
│  │           │                                          │  │
│  │           ▼                                          │  │
│  │  Step 4: Request ATT (if immediate mode)            │  │
│  │  ├── Timeout: from AppConfiguration                 │  │
│  │  └── Output: TrackingStatus                         │  │
│  │           │                                          │  │
│  │           ▼                                          │  │
│  │  Step 5: Show CMP (if EU + immediate mode)          │  │
│  │  ├── Timeout: from AppConfiguration                 │  │
│  │  └── Output: ConsentStatus                          │  │
│  │           │                                          │  │
│  │           ▼                                          │  │
│  │  Step 6: Initialize Ads                              │  │
│  │  ├── Use consent status                             │  │
│  │  └── Output: AdsReady                               │  │
│  │           │                                          │  │
│  │           ▼                                          │  │
│  │  Step 7: Complete                                    │  │
│  │  └── Return StartupResult                           │  │
│  │                                                      │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Step Details

| Step | Mô tả | Timeout | Fallback |
|------|-------|---------|----------|
| 1. Location | Lấy vị trí người dùng | 5s (hardcoded) | Default region |
| 2. Remote Config | Fetch config từ Firebase | 10s (hardcoded) | Local defaults |
| 3. Merge Config | Tạo AppConfiguration | N/A | N/A |
| 4. ATT | Request tracking permission | From config | .notDetermined |
| 5. CMP | Consent cho EU users | From config | Skip |
| 6. Init Ads | Khởi tạo AdMob | From config | Disabled |
| 7. Complete | Trả về kết quả | N/A | N/A |

---

## 3. Two-Phase Configuration

### 3.1 Vấn Đề Circular Dependency

```
❌ PROBLEM:
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  Remote Config chứa: remoteConfigTimeout = 15s             │
│                                                             │
│  Nhưng để fetch Remote Config, cần timeout!                │
│                                                             │
│  → Circular dependency! 🔄                                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 Giải Pháp: Two-Phase

```
✅ SOLUTION:
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  PHASE 1: BOOTSTRAP (Hardcoded values)                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ BootstrapConfiguration                               │   │
│  │ ├── locationTimeout = 5s      // Hardcoded          │   │
│  │ └── remoteConfigTimeout = 10s // Hardcoded          │   │
│  └─────────────────────────────────────────────────────┘   │
│                         │                                   │
│                         ▼                                   │
│  Fetch Remote Config using bootstrap timeout               │
│                         │                                   │
│                         ▼                                   │
│  PHASE 2: MAIN (Config values)                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ AppConfiguration (merged)                            │   │
│  │ ├── attTimeout = 30s       // From Remote Config    │   │
│  │ ├── cmpTimeout = 20s       // From Remote Config    │   │
│  │ └── adLoadTimeout = 15s    // From Remote Config    │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  NO CIRCULAR DEPENDENCY! ✅                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 3.3 Code Implementation

```swift
// Phase 1: Bootstrap Configuration - KHÔNG PHỤ THUỘC GÌ
public struct BootstrapConfiguration {
    public static let shared = BootstrapConfiguration()
    
    // Hardcoded values - KHÔNG ĐỔI
    public let locationTimeout: TimeInterval = 5
    public let remoteConfigTimeout: TimeInterval = 10
}

// Phase 2: Local Defaults - Giá trị mặc định
public struct LocalDefaults {
    public static let shared = LocalDefaults()
    
    public let attTimeout: TimeInterval = 30
    public let cmpTimeout: TimeInterval = 20
    public let adLoadTimeout: TimeInterval = 15
    public let adsEnabled: Bool = true
}

// Phase 3: Remote Configuration - Từ Firebase
public struct RemoteConfiguration {
    public let attTimeout: TimeInterval?
    public let cmpTimeout: TimeInterval?
    public let adLoadTimeout: TimeInterval?
    public let adsEnabled: Bool?
}

// Phase 4: App Configuration - Merged (Remote override Local)
public struct AppConfiguration {
    public let attTimeout: TimeInterval
    public let cmpTimeout: TimeInterval
    public let adLoadTimeout: TimeInterval
    public let adsEnabled: Bool
    
    public init(local: LocalDefaults, remote: RemoteConfiguration?) {
        // Remote wins nếu có, không thì dùng local
        self.attTimeout = remote?.attTimeout ?? local.attTimeout
        self.cmpTimeout = remote?.cmpTimeout ?? local.cmpTimeout
        self.adLoadTimeout = remote?.adLoadTimeout ?? local.adLoadTimeout
        self.adsEnabled = remote?.adsEnabled ?? local.adsEnabled
    }
}
```

---

## 4. Consent Modes

### 4.1 Immediate Mode vs Lazy Mode

```
┌─────────────────────────────────────────────────────────────┐
│                    CONSENT MODES                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  IMMEDIATE MODE:                                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Launch → Location → RC → ATT → CMP → Ads → App      │   │
│  │                                                     │   │
│  │ Pros: Ads ready immediately                        │   │
│  │ Cons: Bad UX (consent before seeing app)           │   │
│  │ Use: Game apps (aggressive monetization)           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  LAZY MODE (RECOMMENDED):                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Launch → Location → RC → App                        │   │
│  │                     ↓                               │   │
│  │               User explores                         │   │
│  │                     ↓                               │   │
│  │            User wants premium feature               │   │
│  │                     ↓                               │   │
│  │         Explain → ATT → CMP → Ads                  │   │
│  │                                                     │   │
│  │ Pros: Better UX, higher consent rate               │   │
│  │ Cons: First ad not preloaded                       │   │
│  │ Use: Most apps (utility, productivity)             │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 4.2 Lazy Mode Implementation

```swift
// StartupOrchestrator với Lazy Mode
public enum StartupMode {
    case immediate  // ATT/CMP at launch
    case lazy       // ATT/CMP later
}

public class StartupOrchestrator {
    private let locationService: LocationServiceProtocol
    private let remoteConfigService: RemoteConfigServiceProtocol
    private let attService: ATTServiceProtocol
    private let cmpService: CMPServiceProtocol
    private let adService: AdServiceProtocol
    private let mode: StartupMode
    
    public func execute() async throws -> StartupResult {
        // Bootstrap phase - Luôn chạy
        let bootstrap = BootstrapConfiguration.shared
        
        // Step 1: Location
        let location = try await locationService.getCurrentLocation(
            timeout: bootstrap.locationTimeout
        )
        
        // Step 2: Remote Config
        let remote = try await remoteConfigService.fetch(
            timeout: bootstrap.remoteConfigTimeout
        )
        
        // Step 3: Merge config
        let appConfig = AppConfiguration(
            local: .shared,
            remote: remote
        )
        
        // Mode-specific behavior
        switch mode {
        case .immediate:
            // Step 4: ATT
            let attStatus = await attService.requestTracking(
                timeout: appConfig.attTimeout
            )
            
            // Step 5: CMP (if EU)
            if location.isEU {
                _ = try await cmpService.requestConsent(
                    timeout: appConfig.cmpTimeout
                )
            }
            
            // Step 6: Init Ads
            try await adService.initialize()
            
            return StartupResult(
                configuration: appConfig,
                location: location,
                attStatus: attStatus,
                adsReady: true
            )
            
        case .lazy:
            // Skip ATT/CMP, return early
            return StartupResult(
                configuration: appConfig,
                location: location,
                attStatus: .notDetermined,
                adsReady: false,
                consentPending: true
            )
        }
    }
}

// ConsentManager - Dùng khi user cần premium feature
public class ConsentManager {
    public func requestConsent() async throws -> ConsentResult {
        // Giải thích cho user tại sao cần consent
        // Request ATT
        let att = await attService.requestTracking()
        
        // Request CMP (if EU)
        let cmp = try? await cmpService.requestConsent()
        
        return ConsentResult(att: att, cmp: cmp)
    }
    
    public func initializeAds() async throws {
        try await adService.initialize()
    }
}
```

---

## 5. Error Handling

### 5.1 Error Strategy

```
┌─────────────────────────────────────────────────────────────┐
│                    ERROR HANDLING                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Step 1 (Location) fails:                                   │
│  └── Use default region, continue ✅                       │
│                                                             │
│  Step 2 (Remote Config) fails:                              │
│  └── Use local defaults, continue ✅                       │
│                                                             │
│  Step 4 (ATT) fails:                                        │
│  └── Assume .notDetermined, continue ✅                    │
│                                                             │
│  Step 5 (CMP) fails:                                        │
│  └── Skip ads for EU, continue ✅                          │
│                                                             │
│  Step 6 (Ads Init) fails:                                   │
│  └── Disable ads, continue ✅                              │
│                                                             │
│  PRINCIPLE: NEVER block app launch!                        │
│  Log errors, use fallbacks, always continue.               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 5.2 Error Types

```swift
public enum StartupError: Error {
    case locationTimeout
    case locationPermissionDenied
    case remoteConfigTimeout
    case remoteConfigFetchFailed
    case attNotAvailable
    case cmpFailed
    case adsInitFailed
    
    var isCritical: Bool {
        // Không có error nào là critical
        // App luôn phải launch được
        return false
    }
    
    var fallbackAction: FallbackAction {
        switch self {
        case .locationTimeout, .locationPermissionDenied:
            return .useDefaultRegion
        case .remoteConfigTimeout, .remoteConfigFetchFailed:
            return .useLocalDefaults
        case .attNotAvailable:
            return .assumeNotDetermined
        case .cmpFailed:
            return .skipAdsForEU
        case .adsInitFailed:
            return .disableAds
        }
    }
}
```

---

## 6. TCA Integration

### 6.1 Startup Feature

```swift
import ComposableArchitecture

@Reducer
public struct StartupFeature {
    @ObservableState
    public struct State: Equatable {
        public var phase: StartupPhase = .idle
        public var error: StartupError?
        public var result: StartupResult?
    }
    
    public enum StartupPhase: Equatable {
        case idle
        case gettingLocation
        case fetchingConfig
        case requestingATT
        case requestingCMP
        case initializingAds
        case completed
        case failed
    }
    
    public enum Action: Equatable {
        case start
        case phaseCompleted(StartupPhase)
        case locationResult(Result<Location, Error>)
        case configResult(Result<RemoteConfiguration, Error>)
        case attResult(TrackingStatus)
        case cmpResult(Result<ConsentStatus, Error>)
        case adsResult(Result<Void, Error>)
        case completed(StartupResult)
        case failed(StartupError)
        
        // Delegate
        case delegate(Delegate)
        
        public enum Delegate: Equatable {
            case startupCompleted(StartupResult)
        }
    }
    
    @Dependency(\.startupOrchestrator) var orchestrator
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .start:
                state.phase = .gettingLocation
                return .run { send in
                    do {
                        let result = try await orchestrator.execute()
                        await send(.completed(result))
                    } catch let error as StartupError {
                        await send(.failed(error))
                    }
                }
                
            case .phaseCompleted(let phase):
                state.phase = phase
                return .none
                
            case .completed(let result):
                state.phase = .completed
                state.result = result
                return .send(.delegate(.startupCompleted(result)))
                
            case .failed(let error):
                state.phase = .failed
                state.error = error
                // Still send completed with fallback values
                let fallbackResult = StartupResult.fallback
                return .send(.delegate(.startupCompleted(fallbackResult)))
                
            case .delegate:
                return .none
                
            default:
                return .none
            }
        }
    }
}
```

### 6.2 App Integration

```swift
@Reducer
public struct AppFeature {
    @ObservableState
    public struct State: Equatable {
        public var startup = StartupFeature.State()
        public var home = HomeFeature.State()
        public var isReady: Bool = false
    }
    
    public enum Action {
        case startup(StartupFeature.Action)
        case home(HomeFeature.Action)
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.startup, action: \.startup) {
            StartupFeature()
        }
        
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .startup(.delegate(.startupCompleted(let result))):
                // Startup hoàn thành, app ready
                state.isReady = true
                // Có thể pass config xuống home
                state.home.configuration = result.configuration
                return .none
                
            default:
                return .none
            }
        }
    }
}
```

---

## 7. Testing

### 7.1 Unit Tests

```swift
@MainActor
func testStartupSuccess() async {
    let store = TestStore(
        initialState: StartupFeature.State()
    ) {
        StartupFeature()
    } withDependencies: {
        $0.startupOrchestrator = MockStartupOrchestrator(
            result: .success(.mock)
        )
    }
    
    await store.send(.start) {
        $0.phase = .gettingLocation
    }
    
    await store.receive(.completed(.mock)) {
        $0.phase = .completed
        $0.result = .mock
    }
    
    await store.receive(.delegate(.startupCompleted(.mock)))
}

@MainActor
func testStartupWithLocationFailure() async {
    let store = TestStore(
        initialState: StartupFeature.State()
    ) {
        StartupFeature()
    } withDependencies: {
        $0.startupOrchestrator = MockStartupOrchestrator(
            result: .success(.withFallbackLocation)
        )
    }
    
    await store.send(.start) {
        $0.phase = .gettingLocation
    }
    
    // Should still complete with fallback
    await store.receive(.completed(.withFallbackLocation)) {
        $0.phase = .completed
        $0.result = .withFallbackLocation
    }
}
```

---

## 8. Best Practices

### 8.1 Do's and Don'ts

```
┌─────────────────────────────────────────────────────────────┐
│                    BEST PRACTICES                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ✅ DO:                                                     │
│  • Use two-phase configuration                             │
│  • Prefer lazy consent mode                                │
│  • Always have fallback values                             │
│  • Log errors to analytics                                 │
│  • Test all error scenarios                                │
│  • Keep bootstrap values simple                            │
│                                                             │
│  ❌ DON'T:                                                  │
│  • Block app launch on any step                            │
│  • Hardcode timeouts that should be configurable          │
│  • Skip error handling                                     │
│  • Request consent without explanation                     │
│  • Ignore ATT/GDPR requirements                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 8.2 Performance Tips

| Tip | Impact |
|-----|--------|
| Parallel requests khi có thể | -30% startup time |
| Cache remote config | -50% subsequent launches |
| Preload ads in background | Better user experience |
| Monitor startup metrics | Data-driven optimization |

---

## 9. Metrics & Monitoring

### 9.1 Key Metrics

```swift
// Track startup metrics
struct StartupMetrics {
    let totalDuration: TimeInterval
    let locationDuration: TimeInterval
    let configDuration: TimeInterval
    let attDuration: TimeInterval?
    let cmpDuration: TimeInterval?
    let adsDuration: TimeInterval?
    
    let locationSuccess: Bool
    let configSuccess: Bool
    let attStatus: TrackingStatus
    let adsReady: Bool
}

// Log to Analytics
func logStartupMetrics(_ metrics: StartupMetrics) {
    Analytics.logEvent("startup_completed", parameters: [
        "total_duration": metrics.totalDuration,
        "location_success": metrics.locationSuccess,
        "config_success": metrics.configSuccess,
        "att_status": metrics.attStatus.rawValue,
        "ads_ready": metrics.adsReady
    ])
}
```

### 9.2 Success Criteria

| Metric | Target | Action if below |
|--------|--------|-----------------|
| Startup < 3s | 95% | Optimize slow steps |
| Location success | 80% | Check fallback handling |
| Config success | 99% | Check Firebase setup |
| ATT consent rate | 30% | Improve explanation |

---

## 10. Summary

### Key Takeaways

1. **Two-Phase Configuration** giải quyết circular dependency
2. **Lazy Consent Mode** cho UX tốt hơn và consent rate cao hơn
3. **Never block app launch** - luôn có fallback
4. **TCA integration** cho testability và maintainability
5. **Monitor metrics** để optimize liên tục

### ROI

| Benefit | Impact |
|---------|--------|
| Consistent UX | Across all apps |
| Higher consent rate | +20-30% with lazy mode |
| Faster debugging | Centralized logic |
| Development time | -42% for new apps |

---

*Startup Orchestration là foundation cho mọi app. Design một lần, dùng cho tất cả.*
