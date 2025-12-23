# 📴 Hỗ Trợ Ngoại Tuyến (Offline Support)

## Strategy
```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Online    │────►│   Cache     │────►│  Offline    │
│   Request   │     │   First     │     │  Fallback   │
└─────────────┘     └─────────────┘     └─────────────┘
```

## Implementation
1. Check network connectivity
2. If online: Fetch from API, cache response
3. If offline: Return cached data
4. Queue write operations for sync

## Components
- Network monitor (NWPathMonitor)
- Request queue
- Cache manager
- Sync manager

## State
```swift
var coKetNoiMang: Bool
var cacYeuCauChoXuLy: [YeuCau]
```
