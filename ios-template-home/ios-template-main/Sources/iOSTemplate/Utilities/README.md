# Utilities - Common Tools & Helpers

## Tổng quan

Thư mục `Utilities/` chứa các **utility classes** và **helper functions** được sử dụng across toàn bộ app. Bao gồm logging system và caching infrastructure.

### Chức năng chính
- Unified logging system với multiple levels
- Memory cache với automatic expiration
- Disk cache cho persistent storage
- Combined cache manager (memory + disk)
- File logging và log management
- Thread-safe operations

### Tác động đến toàn bộ app
- **High Impact**: Logging được sử dụng everywhere để debug và monitor
- Cache ảnh hưởng đến performance và offline capability
- Log files giúp troubleshoot production issues
- Thread safety đảm bảo stability
- Memory management optimization

---

## Cấu trúc Files

```
Utilities/
├── Logger.swift                 # Logging system (253 dòng)
└── Cache/
    ├── MemoryCache.swift        # In-memory cache (175 dòng)
    └── DiskCache.swift          # Disk-based cache (250 dòng)
```

**Tổng cộng**: 678 dòng code, 3 files

---

## Chi tiết các Files

### 1. Logger.swift (253 dòng)

**Chức năng**: Unified logging system cho toàn bộ app

##### `Logger` class (dòng 5-219)

Thread-safe singleton logger.

**Properties**:
- `shared: Logger` - Singleton instance
- `osLog: OSLog` - Apple's unified logging system
- `logToFile: Bool` - Enable/disable file logging
- `logFilePath: URL?` - Current log file path
- `minimumLogLevel: LogLevel` - Minimum level to log

##### `LogLevel` enum (dòng 19-49)

```swift
public enum LogLevel: Int, Comparable {
    case verbose = 0
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4

    var emoji: String {
        switch self {
        case .verbose: return "💬"
        case .debug: return "🔍"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        }
    }

    var osLogType: OSLogType {
        switch self {
        case .verbose: return .debug
        case .debug: return .debug
        case .info: return .info
        case .warning: return .default
        case .error: return .error
        }
    }
}
```

**Comparison**: Higher level = more important
```swift
LogLevel.error > LogLevel.warning > LogLevel.info > LogLevel.debug > LogLevel.verbose
```

##### Minimum Log Level (dòng 52-58)

```swift
public var minimumLogLevel: LogLevel = {
    #if DEBUG
    return .verbose  // Log everything in debug
    #else
    return .info     // Only info and above in release
    #endif
}()
```

**Purpose**: Filter out low-priority logs in production.

##### Initialization (dòng 62-65)

```swift
private init() {
    self.osLog = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.iostemplate.app", category: "General")
    setupFileLogging()
}
```

#### LoggingServiceProtocol Implementation (dòng 69-91)

##### `verbose(_:file:function:line:)` (dòng 69-71)
```swift
public func verbose(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    log(message, level: .verbose, file: file, function: function, line: line)
}
```

**Usage**: Detailed debugging information
```swift
Logger.shared.verbose("User tapped button", file: #file, function: #function, line: #line)
```

##### `debug(_:file:function:line:)` (dòng 73-75)
```swift
public func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    log(message, level: .debug, file: file, function: function, line: line)
}
```

**Usage**: Debug information
```swift
Logger.shared.debug("API request: \(endpoint)")
```

##### `info(_:file:function:line:)` (dòng 77-79)
```swift
public func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    log(message, level: .info, file: file, function: function, line: line)
}
```

**Usage**: General information
```swift
Logger.shared.info("User logged in successfully")
```

##### `warning(_:file:function:line:)` (dòng 81-83)
```swift
public func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    log(message, level: .warning, file: file, function: function, line: line)
}
```

**Usage**: Warnings
```swift
Logger.shared.warning("Cache size exceeded limit")
```

##### `error(_:error:file:function:line:)` (dòng 85-91)
```swift
public func error(_ message: String, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) {
    var fullMessage = message
    if let error = error {
        fullMessage += " | Error: \(error.localizedDescription)"
    }
    log(fullMessage, level: .error, file: file, function: function, line: line)
}
```

**Usage**: Errors with optional Error object
```swift
Logger.shared.error("Network request failed", error: networkError)
```

#### Core Logging Logic (dòng 95-128)

##### `log(_:level:file:function:line:)` (dòng 95-122)

Main logging method.

```swift
private func log(
    _ message: String,
    level: LogLevel,
    file: String,
    function: String,
    line: Int
) {
    // 1. Check minimum log level
    guard level >= minimumLogLevel else { return }

    let fileName = (file as NSString).lastPathComponent
    let timestamp = dateFormatter.string(from: Date())

    let logMessage = "\(level.emoji) [\(timestamp)] [\(fileName):\(line)] \(function) - \(message)"

    // 2. Log to console (DEBUG only)
    #if DEBUG
    print(logMessage)
    #endif

    // 3. Log to OS Logger
    os_log("%{public}@", log: osLog, type: level.osLogType, logMessage)

    // 4. Log to file
    if logToFile {
        writeToFile(logMessage)
    }
}
```

**Log format**:
```
💬 [2025-11-15 10:30:45.123] [HomeView.swift:45] buttonTapped() - User tapped login button
```

**Output destinations**:
1. **Console** (DEBUG builds only) - via `print()`
2. **OS Logger** (always) - System logs, viewable in Console.app
3. **File** (production) - For crash reports

##### Date Formatter (dòng 124-128)

```swift
private lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    return formatter
}()
```

**Format**: `2025-11-15 10:30:45.123` (includes milliseconds)

#### File Logging (dòng 132-198)

##### `setupFileLogging()` (dòng 132-158)

Initialize file logging.

```swift
private func setupFileLogging() {
    #if DEBUG
    logToFile = false // Disable in debug (use console instead)
    #else
    logToFile = true  // Enable in production
    #endif

    guard logToFile else { return }

    // Setup log file path
    let fileManager = FileManager.default
    guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
        return
    }

    let logsDirectory = documentsDirectory.appendingPathComponent("Logs", isDirectory: true)

    // Create logs directory if needed
    try? fileManager.createDirectory(at: logsDirectory, withIntermediateDirectories: true)

    // Create log file with date
    let dateString = DateFormatter.logFileName.string(from: Date())
    logFilePath = logsDirectory.appendingPathComponent("log_\(dateString).txt")

    // Clean old logs (keep last 7 days)
    cleanOldLogs(in: logsDirectory)
}
```

**Log file naming**: `log_2025-11-15.txt` (one file per day)

**Location**: `~/Documents/Logs/`

##### `writeToFile(_:)` (dòng 160-178)

Append log message to file.

```swift
private func writeToFile(_ message: String) {
    guard let filePath = logFilePath else { return }

    let messageWithNewline = message + "\n"

    if let data = messageWithNewline.data(using: .utf8) {
        if FileManager.default.fileExists(atPath: filePath.path) {
            // Append to existing file
            if let fileHandle = try? FileHandle(forWritingTo: filePath) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
        } else {
            // Create new file
            try? data.write(to: filePath)
        }
    }
}
```

**Thread safety**: Called from `log()` which can be called from any thread. Consider adding dispatch queue for true thread safety.

##### `cleanOldLogs(in:)` (dòng 180-198)

Delete logs older than 7 days.

```swift
private func cleanOldLogs(in directory: URL) {
    let fileManager = FileManager.default
    guard let files = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.creationDateKey]) else {
        return
    }

    let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!

    for file in files where file.pathExtension == "txt" {
        guard let attributes = try? fileManager.attributesOfItem(atPath: file.path),
              let creationDate = attributes[.creationDate] as? Date else {
            continue
        }

        if creationDate < sevenDaysAgo {
            try? fileManager.removeItem(at: file)
        }
    }
}
```

**Retention**: 7 days (configurable)

#### Public Utilities (dòng 202-219)

##### `getLogs()` (dòng 203-206)

```swift
public func getLogs() -> String? {
    guard let filePath = logFilePath else { return nil }
    return try? String(contentsOf: filePath, encoding: .utf8)
}
```

**Usage**: Get log file contents for crash reports
```swift
if let logs = Logger.shared.getLogs() {
    sendCrashReport(logs: logs)
}
```

##### `clearLogs()` (dòng 209-213)

```swift
public func clearLogs() {
    guard let filePath = logFilePath else { return }
    try? FileManager.default.removeItem(at: filePath)
    setupFileLogging()
}
```

##### `getLogFileURL()` (dòng 216-218)

```swift
public func getLogFileURL() -> URL? {
    logFilePath
}
```

**Usage**: Share log file
```swift
if let url = Logger.shared.getLogFileURL() {
    let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
    present(activityVC, animated: true)
}
```

#### Global Functions (dòng 234-252)

Convenience functions.

```swift
public func logVerbose(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.verbose(message, file: file, function: function, line: line)
}

public func logDebug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.debug(message, file: file, function: function, line: line)
}

public func logInfo(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.info(message, file: file, function: function, line: line)
}

public func logWarning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.warning(message, file: file, function: function, line: line)
}

public func logError(_ message: String, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.error(message, error: error, file: file, function: function, line: line)
}
```

**Usage**:
```swift
logInfo("App launched")
logError("Failed to load data", error: error)
```

---

### 2. Cache/MemoryCache.swift (175 dòng)

**Chức năng**: In-memory cache using NSCache với expiration

##### `MemoryCache<Key: Hashable, Value>` (dòng 4-129)

Generic memory cache.

**Properties**:
- `cache: NSCache<WrappedKey, Entry>` - Underlying NSCache
- `dateProvider: () -> Date` - For testing (injectable)
- `entryLifetime: TimeInterval` - TTL for entries
- `keyTracker: KeyTracker` - Tracks keys for enumeration

**Initialization** (dòng 15-24):

```swift
public init(
    dateProvider: @escaping () -> Date = Date.init,
    entryLifetime: TimeInterval = 12 * 60 * 60, // 12 hours default
    maximumEntryCount: Int = 50
) {
    self.dateProvider = dateProvider
    self.entryLifetime = entryLifetime
    cache.countLimit = maximumEntryCount
    cache.delegate = keyTracker
}
```

**Default settings**:
- TTL: 12 hours
- Max entries: 50
- Auto-eviction khi limit reached

#### Public Methods (dòng 28-81)

##### `insert(_:forKey:)` (dòng 29-34)

```swift
public func insert(_ value: Value, forKey key: Key) {
    let date = dateProvider().addingTimeInterval(entryLifetime)
    let entry = Entry(key: key, value: value, expirationDate: date)
    cache.setObject(entry, forKey: WrappedKey(key))
    keyTracker.keys.insert(key)
}
```

**Flow**:
1. Calculate expiration date (now + lifetime)
2. Create Entry wrapper
3. Store in NSCache
4. Track key

##### `value(forKey:)` (dòng 37-49)

```swift
public func value(forKey key: Key) -> Value? {
    guard let entry = cache.object(forKey: WrappedKey(key)) else {
        return nil
    }

    // Check expiration
    guard dateProvider() < entry.expirationDate else {
        removeValue(forKey: key)
        return nil
    }

    return entry.value
}
```

**Expiration check**: Automatically removes expired entries.

##### `removeValue(forKey:)` (dòng 52-54)

```swift
public func removeValue(forKey key: Key) {
    cache.removeObject(forKey: WrappedKey(key))
}
```

##### `removeAll()` (dòng 57-59)

```swift
public func removeAll() {
    cache.removeAllObjects()
}
```

##### `contains(_:)` (dòng 62-64)

```swift
public func contains(_ key: Key) -> Bool {
    value(forKey: key) != nil
}
```

**Note**: Checks expiration, not just existence.

##### `allKeys()` (dòng 67-69)

```swift
public func allKeys() -> Set<Key> {
    keyTracker.keys
}
```

##### Subscript (dòng 72-81)

```swift
public subscript(key: Key) -> Value? {
    get { value(forKey: key) }
    set {
        guard let value = newValue else {
            removeValue(forKey: key)
            return
        }
        insert(value, forKey: key)
    }
}
```

**Usage**:
```swift
cache["user123"] = userData
let user = cache["user123"]
cache["user123"] = nil // Remove
```

#### Private Types (dòng 85-128)

##### `WrappedKey` (dòng 85-102)

NSObject wrapper cho generic Key.

```swift
private final class WrappedKey: NSObject {
    let key: Key

    init(_ key: Key) {
        self.key = key
    }

    override var hash: Int {
        key.hashValue
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? WrappedKey else {
            return false
        }
        return key == other.key
    }
}
```

**Purpose**: NSCache requires NSObject keys.

##### `Entry` (dòng 104-114)

Cache entry với expiration.

```swift
private final class Entry {
    let key: Key
    let value: Value
    let expirationDate: Date

    init(key: Key, value: Value, expirationDate: Date) {
        self.key = key
        self.value = value
        self.expirationDate = expirationDate
    }
}
```

##### `KeyTracker` (dòng 116-128)

NSCacheDelegate to track keys.

```swift
private final class KeyTracker: NSObject, NSCacheDelegate {
    var keys = Set<Key>()

    func cache(
        _ cache: NSCache<AnyObject, AnyObject>,
        willEvictObject object: Any
    ) {
        guard let entry = object as? Entry else {
            return
        }
        keys.remove(entry.key)
    }
}
```

**Purpose**: NSCache doesn't provide key enumeration. KeyTracker maintains key set.

#### Codable Support (dòng 133-174)

##### Encode/Decode (dòng 133-174)

```swift
extension MemoryCache: Codable where Key: Codable, Value: Codable {
    private struct CodableEntry: Codable {
        let key: Key
        let value: Value
        let expirationDate: Date
    }

    public convenience init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.container(keyedBy: CodingKeys.self)
        let entries = try container.decode([CodableEntry].self, forKey: .entries)

        entries.forEach { entry in
            let date = entry.expirationDate
            let cacheEntry = Entry(key: entry.key, value: entry.value, expirationDate: date)
            cache.setObject(cacheEntry, forKey: WrappedKey(entry.key))
            keyTracker.keys.insert(entry.key)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let entries = keyTracker.keys.compactMap { key -> CodableEntry? in
            guard let entry = cache.object(forKey: WrappedKey(key)) else {
                return nil
            }
            return CodableEntry(
                key: key,
                value: entry.value,
                expirationDate: entry.expirationDate
            )
        }

        try container.encode(entries, forKey: .entries)
    }
}
```

**Usage**: Persist memory cache to disk
```swift
let cache = MemoryCache<String, User>()
let data = try JSONEncoder().encode(cache)
try data.write(to: fileURL)
```

---

### 3. Cache/DiskCache.swift (250 dòng)

**Chức năng**: Persistent disk cache với expiration

##### `DiskCache<Key: Hashable & Codable, Value: Codable>` (dòng 4-164)

Generic disk cache.

**Properties**:
- `fileManager: FileManager` - File operations
- `cacheDirectory: URL` - Cache directory path
- `dateProvider: () -> Date` - For testing
- `entryLifetime: TimeInterval` - TTL for entries
- `queue: DispatchQueue` - Thread safety

**Initialization** (dòng 16-39):

```swift
public init(
    name: String = "DiskCache",
    dateProvider: @escaping () -> Date = Date.init,
    entryLifetime: TimeInterval = 7 * 24 * 60 * 60, // 7 days default
    fileManager: FileManager = .default
) throws {
    self.fileManager = fileManager
    self.dateProvider = dateProvider
    self.entryLifetime = entryLifetime

    // Setup cache directory
    guard let cachesDirectory = fileManager.urls(
        for: .cachesDirectory,
        in: .userDomainMask
    ).first else {
        throw StorageError.accessDenied
    }

    self.cacheDirectory = cachesDirectory
        .appendingPathComponent("DiskCache", isDirectory: true)
        .appendingPathComponent(name, isDirectory: true)

    try createCacheDirectoryIfNeeded()
}
```

**Directory structure**:
```
~/Library/Caches/
  └── DiskCache/
      └── [name]/
          ├── key1_encoded
          ├── key2_encoded
          └── ...
```

**Default TTL**: 7 days (longer than memory cache)

#### Public Methods (dòng 43-138)

##### `insert(_:forKey:)` (dòng 44-52)

Thread-safe insert.

```swift
public func insert(_ value: Value, forKey key: Key) throws {
    let entry = Entry(value: value, expirationDate: dateProvider().addingTimeInterval(entryLifetime))
    let data = try JSONEncoder().encode(entry)
    let fileURL = cacheFileURL(for: key)

    try queue.sync(flags: .barrier) {
        try data.write(to: fileURL)
    }
}
```

**Barrier flag**: Ensures exclusive write access.

##### `value(forKey:)` (dòng 55-74)

Thread-safe read with expiration check.

```swift
public func value(forKey key: Key) throws -> Value? {
    try queue.sync {
        let fileURL = cacheFileURL(for: key)

        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        let data = try Data(contentsOf: fileURL)
        let entry = try JSONDecoder().decode(Entry.self, from: data)

        // Check expiration
        guard dateProvider() < entry.expirationDate else {
            try? removeValue(forKey: key)
            return nil
        }

        return entry.value
    }
}
```

**Automatic cleanup**: Removes expired entries on read.

##### `removeValue(forKey:)` (dòng 77-82)

```swift
public func removeValue(forKey key: Key) throws {
    try queue.sync(flags: .barrier) {
        let fileURL = cacheFileURL(for: key)
        try fileManager.removeItem(at: fileURL)
    }
}
```

##### `removeAll()` (dòng 85-96)

```swift
public func removeAll() throws {
    try queue.sync(flags: .barrier) {
        let contents = try fileManager.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: nil
        )

        for fileURL in contents {
            try fileManager.removeItem(at: fileURL)
        }
    }
}
```

##### `cacheSize()` (dòng 99-117)

Calculate total cache size.

```swift
public func cacheSize() throws -> Int64 {
    try queue.sync {
        var totalSize: Int64 = 0

        let contents = try fileManager.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: [.fileSizeKey]
        )

        for fileURL in contents {
            let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
            if let fileSize = attributes[.size] as? Int64 {
                totalSize += fileSize
            }
        }

        return totalSize
    }
}
```

**Usage**:
```swift
let size = try diskCache.cacheSize()
print("Cache size: \(size.formattedFileSize)")
```

##### `cleanExpiredEntries()` (dòng 120-138)

Remove all expired entries.

```swift
public func cleanExpiredEntries() throws {
    try queue.sync(flags: .barrier) {
        let contents = try fileManager.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: nil
        )

        for fileURL in contents {
            guard let data = try? Data(contentsOf: fileURL),
                  let entry = try? JSONDecoder().decode(Entry.self, from: data) else {
                continue
            }

            if dateProvider() >= entry.expirationDate {
                try? fileManager.removeItem(at: fileURL)
            }
        }
    }
}
```

**Usage**: Call periodically (e.g., on app launch)
```swift
try diskCache.cleanExpiredEntries()
```

#### Private Methods (dòng 142-164)

##### `createCacheDirectoryIfNeeded()` (dòng 142-151)

```swift
private func createCacheDirectoryIfNeeded() throws {
    guard !fileManager.fileExists(atPath: cacheDirectory.path) else {
        return
    }

    try fileManager.createDirectory(
        at: cacheDirectory,
        withIntermediateDirectories: true
    )
}
```

##### `cacheFileURL(for:)` (dòng 153-156)

```swift
private func cacheFileURL(for key: Key) -> URL {
    let fileName = String(describing: key).addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "unknown"
    return cacheDirectory.appendingPathComponent(fileName)
}
```

**Key encoding**: Convert key to filename-safe string.

##### `Entry` struct (dòng 160-163)

```swift
private struct Entry: Codable {
    let value: Value
    let expirationDate: Date
}
```

#### CacheManager (dòng 169-249)

Combined memory + disk cache.

##### `CacheManager<Key, Value>` (dòng 169-249)

Two-tier cache system.

**Properties**:
- `memoryCache: MemoryCache<Key, Value>` - L1 cache
- `diskCache: DiskCache<Key, Value>?` - L2 cache

**Initialization** (dòng 178-186):

```swift
public init(
    name: String = "DefaultCache",
    memoryEntryLifetime: TimeInterval = 12 * 60 * 60,
    diskEntryLifetime: TimeInterval = 7 * 24 * 60 * 60,
    useDiskCache: Bool = true
) {
    self.memoryCache = MemoryCache(entryLifetime: memoryEntryLifetime)
    self.diskCache = useDiskCache ? try? DiskCache(name: name, entryLifetime: diskEntryLifetime) : nil
}
```

##### `insert(_:forKey:)` (dòng 191-197)

```swift
public func insert(_ value: Value, forKey key: Key) {
    // Insert to memory cache
    memoryCache.insert(value, forKey: key)

    // Insert to disk cache
    try? diskCache?.insert(value, forKey: key)
}
```

**Write-through**: Write to both caches.

##### `value(forKey:)` (dòng 200-214)

```swift
public func value(forKey key: Key) -> Value? {
    // Check memory cache first
    if let value = memoryCache.value(forKey: key) {
        return value
    }

    // Check disk cache
    if let value = try? diskCache?.value(forKey: key) {
        // Restore to memory cache
        memoryCache.insert(value, forKey: key)
        return value
    }

    return nil
}
```

**Cache hierarchy**:
1. Check memory (fast)
2. If miss, check disk (slower)
3. If found on disk, populate memory
4. Return value

##### Other methods (dòng 217-248)

```swift
public func removeValue(forKey key: Key) {
    memoryCache.removeValue(forKey: key)
    try? diskCache?.removeValue(forKey: key)
}

public func removeAll() {
    memoryCache.removeAll()
    try? diskCache?.removeAll()
}

public func totalCacheSize() -> Int64 {
    (try? diskCache?.cacheSize()) ?? 0
}

public func cleanExpired() {
    try? diskCache?.cleanExpiredEntries()
}

public subscript(key: Key) -> Value? {
    get { value(forKey: key) }
    set {
        guard let value = newValue else {
            removeValue(forKey: key)
            return
        }
        insert(value, forKey: key)
    }
}
```

---

## Cách các Files hoạt động cùng nhau

### Logging Architecture

```
┌─────────────────────────────────────────────────────┐
│         Application Code (Any Layer)                 │
│    ViewModels, Services, Reducers, etc.             │
└────────────────────┬────────────────────────────────┘
                     │ Call logging functions
                     ▼
┌─────────────────────────────────────────────────────┐
│           Global Logging Functions                   │
│  logInfo(), logError(), logDebug(), etc.            │
└────────────────────┬────────────────────────────────┘
                     │ Forward to Logger.shared
                     ▼
┌─────────────────────────────────────────────────────┐
│              Logger.shared (Singleton)               │
│                                                      │
│  1. Check minimumLogLevel                           │
│  2. Format message with metadata                    │
│  3. Output to multiple destinations                 │
└──┬──────────────┬──────────────┬────────────────────┘
   │              │              │
   ▼              ▼              ▼
┌────────┐  ┌──────────┐  ┌─────────────┐
│Console │  │ OS Logger│  │ File Logger │
│(DEBUG) │  │(Always)  │  │(Production) │
└────────┘  └──────────┘  └─────────────┘
```

### Cache Architecture

```
┌─────────────────────────────────────────────────────┐
│              Application Layer                       │
│         (Services using caching)                    │
└────────────────────┬────────────────────────────────┘
                     │ Use CacheManager
                     ▼
┌─────────────────────────────────────────────────────┐
│              CacheManager<Key, Value>                │
│           (Orchestrates both caches)                │
└────────────────────┬────────────────────────────────┘
                     │
      ┌──────────────┴──────────────┐
      │                             │
      ▼                             ▼
┌──────────────┐            ┌──────────────────┐
│MemoryCache   │            │ DiskCache        │
│              │            │                  │
│• Fast (RAM)  │            │• Persistent      │
│• Small size  │            │• Larger size     │
│• 12h TTL     │            │• 7 days TTL      │
│• 50 entries  │            │• Unlimited       │
└──────────────┘            └──────────────────┘
```

**Read flow**:
1. Check MemoryCache (L1)
2. If hit → return value
3. If miss → Check DiskCache (L2)
4. If hit → Populate MemoryCache + return value
5. If miss → return nil

**Write flow**:
1. Write to MemoryCache (sync)
2. Write to DiskCache (async)

---

## Usage Examples

### Example 1: Logging Throughout App

```swift
// App launch
class AppDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        logInfo("App launched with options: \(String(describing: launchOptions))")

        // Setup
        setupServices()

        return true
    }

    private func setupServices() {
        logDebug("Setting up services")

        do {
            try setupNetwork()
            logInfo("Network service initialized")
        } catch {
            logError("Failed to setup network", error: error)
        }
    }
}

// In ViewModel
class HomeViewModel {
    func loadData() {
        logVerbose("Starting data load")

        Task {
            do {
                let data = try await networkService.request(...)
                logInfo("Data loaded successfully: \(data.count) items")
            } catch NetworkError.noConnection {
                logWarning("No internet connection")
                showOfflineBanner()
            } catch {
                logError("Failed to load data", error: error)
                showErrorAlert()
            }
        }
    }
}

// In Service
class AuthService {
    func login(email: String, password: String) async throws {
        logDebug("Login attempt for email: \(email)")

        let response = try await networkService.request(.login(email: email, password: password))

        logInfo("Login successful for user: \(response.userID)")

        // Save tokens
        try keychain.saveSecure(response.accessToken, forKey: SecureStorageKey.accessToken)
        logDebug("Access token saved to keychain")
    }
}
```

### Example 2: Image Cache Service

```swift
class ImageCacheService: ImageCacheServiceProtocol {
    private let cache: CacheManager<String, Data>

    init() {
        self.cache = CacheManager(
            name: "ImageCache",
            memoryEntryLifetime: 60 * 60,        // 1 hour
            diskEntryLifetime: 7 * 24 * 60 * 60, // 7 days
            useDiskCache: true
        )

        logInfo("Image cache initialized")
    }

    func cacheImage(_ data: Data, forKey key: String) {
        logVerbose("Caching image: \(key), size: \(data.count) bytes")

        cache.insert(data, forKey: key)

        // Log cache stats
        let totalSize = cache.totalCacheSize()
        logDebug("Cache size after insert: \(totalSize.formattedFileSize)")
    }

    func getCachedImage(forKey key: String) -> Data? {
        logVerbose("Retrieving cached image: \(key)")

        if let data = cache.value(forKey: key) {
            logDebug("Cache hit for image: \(key)")
            return data
        } else {
            logDebug("Cache miss for image: \(key)")
            return nil
        }
    }

    func clearCache() {
        logInfo("Clearing image cache")

        let sizeBefore = cache.totalCacheSize()
        cache.removeAll()
        logInfo("Cleared \(sizeBefore.formattedFileSize) from cache")
    }

    func cleanupExpiredEntries() {
        logDebug("Cleaning expired cache entries")

        cache.cleanExpired()
    }
}
```

### Example 3: API Response Cache

```swift
class APIResponseCache {
    private let cache: CacheManager<String, APIResponse>

    init() {
        self.cache = CacheManager(
            name: "APIResponseCache",
            memoryEntryLifetime: 5 * 60,         // 5 minutes
            diskEntryLifetime: 30 * 60,          // 30 minutes
            useDiskCache: true
        )
    }

    func cacheResponse<T: Codable>(_ response: T, forEndpoint endpoint: String) {
        let cacheKey = makeCacheKey(endpoint: endpoint)

        do {
            let data = try JSONEncoder().encode(response)
            cache.insert(data, forKey: cacheKey)
            logDebug("Cached API response for: \(endpoint)")
        } catch {
            logError("Failed to cache API response", error: error)
        }
    }

    func getCachedResponse<T: Codable>(forEndpoint endpoint: String) -> T? {
        let cacheKey = makeCacheKey(endpoint: endpoint)

        guard let data = cache.value(forKey: cacheKey) else {
            logDebug("No cached response for: \(endpoint)")
            return nil
        }

        do {
            let response = try JSONDecoder().decode(T.self, from: data)
            logDebug("Using cached response for: \(endpoint)")
            return response
        } catch {
            logError("Failed to decode cached response", error: error)
            return nil
        }
    }

    private func makeCacheKey(endpoint: String) -> String {
        endpoint.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? endpoint
    }
}

// Usage in NetworkService
class NetworkService {
    let responseCache = APIResponseCache()

    func request<T: Codable>(_ endpoint: String) async throws -> T {
        // Check cache first
        if let cached: T = responseCache.getCachedResponse(forEndpoint: endpoint) {
            logInfo("Returning cached response for: \(endpoint)")
            return cached
        }

        // Fetch from network
        logDebug("Fetching from network: \(endpoint)")
        let response: T = try await performNetworkRequest(endpoint)

        // Cache response
        responseCache.cacheResponse(response, forEndpoint: endpoint)

        return response
    }
}
```

### Example 4: User Session Cache

```swift
struct UserSession: Codable {
    let userID: String
    let accessToken: String
    let expiresAt: Date
}

class SessionManager {
    private let memoryCache = MemoryCache<String, UserSession>(
        entryLifetime: 30 * 60 // 30 minutes
    )

    func cacheSession(_ session: UserSession) {
        memoryCache.insert(session, forKey: "current_session")
        logInfo("Cached user session for user: \(session.userID)")
    }

    func getCurrentSession() -> UserSession? {
        if let session = memoryCache.value(forKey: "current_session") {
            // Check if token expired
            if session.expiresAt > Date() {
                logDebug("Valid session found")
                return session
            } else {
                logWarning("Session expired")
                clearSession()
            }
        }

        logDebug("No valid session")
        return nil
    }

    func clearSession() {
        memoryCache.removeValue(forKey: "current_session")
        logInfo("Session cleared")
    }
}
```

---

## Best Practices

### 1. Use Appropriate Log Levels

```swift
// ✅ Good - Use correct levels
logVerbose("Button tap coordinates: \(x), \(y)")   // Very detailed
logDebug("API request: GET /users/123")            // Debug info
logInfo("User logged in successfully")             // Important events
logWarning("Cache size exceeded 50MB")             // Potential issues
logError("Network request failed", error: error)   // Errors

// ❌ Bad - Wrong levels
logError("Button tapped") // Not an error
logInfo("Variable x = 5") // Too verbose for info
```

### 2. Include Context in Logs

```swift
// ✅ Good - Descriptive logs
logInfo("Login successful for user: \(userID)")
logError("Failed to decode JSON from endpoint: \(endpoint)", error: error)

// ❌ Bad - Vague logs
logInfo("Success")
logError("Error")
```

### 3. Choose Right Cache Type

```swift
// ✅ MemoryCache - Frequently accessed, small data
let iconCache = MemoryCache<String, UIImage>(
    entryLifetime: 60 * 60,     // 1 hour
    maximumEntryCount: 100       // Limit memory usage
)

// ✅ DiskCache - Larger data, persistent
let imageCache = try DiskCache<String, Data>(
    name: "Images",
    entryLifetime: 7 * 24 * 60 * 60 // 7 days
)

// ✅ CacheManager - Best of both
let apiCache = CacheManager<String, APIResponse>(
    name: "APICache",
    memoryEntryLifetime: 5 * 60,     // 5 min in memory
    diskEntryLifetime: 30 * 60       // 30 min on disk
)
```

### 4. Clean Cache Regularly

```swift
class CacheMaintenanceService {
    let imageCache: CacheManager<String, Data>

    func performMaintenance() {
        logInfo("Starting cache maintenance")

        // Clean expired entries
        imageCache.cleanExpired()

        // Check size
        let size = imageCache.totalCacheSize()
        logInfo("Cache size: \(size.formattedFileSize)")

        // Clear if too large
        if size > 100 * 1024 * 1024 { // 100 MB
            logWarning("Cache size exceeded limit, clearing")
            imageCache.removeAll()
        }
    }
}

// Run on app launch
func application(_ application: UIApplication, didFinishLaunchingWithOptions...) -> Bool {
    let maintenance = CacheMaintenanceService()
    maintenance.performMaintenance()
}
```

### 5. Handle Cache Errors Gracefully

```swift
// ✅ Good - Handle cache errors
func loadImage(url: URL) async -> UIImage? {
    let cacheKey = url.absoluteString

    // Try cache first
    if let cachedData = imageCache.value(forKey: cacheKey),
       let image = UIImage(data: cachedData) {
        return image
    }

    // Download
    do {
        let (data, _) = try await URLSession.shared.data(from: url)

        // Cache for next time
        imageCache.insert(data, forKey: cacheKey)

        return UIImage(data: data)
    } catch {
        logError("Failed to download image", error: error)
        return nil
    }
}

// ❌ Bad - Crash on cache failure
func loadImage(url: URL) async -> UIImage {
    let data = try! imageCache.value(forKey: url.absoluteString)!
    return UIImage(data: data)!
}
```

---

## Performance Considerations

### 1. Logger Performance

- **Console logging** (DEBUG only): Minimal overhead
- **OS Logger**: Very efficient, async
- **File logging**: Has I/O overhead, use in production only

**Optimization**: Disable verbose logs in production
```swift
Logger.shared.minimumLogLevel = .info
```

### 2. Memory Cache Performance

- **O(1)** access time (NSCache hash table)
- **Automatic eviction** when memory pressure
- **Thread-safe** (NSCache is thread-safe)

**Optimization**: Set appropriate `maximumEntryCount`
```swift
let cache = MemoryCache<String, Data>(
    maximumEntryCount: 50 // Adjust based on data size
)
```

### 3. Disk Cache Performance

- **I/O overhead**: Slower than memory
- **Thread-safe**: Uses dispatch queue
- **Barrier writes**: Exclusive access for writes

**Optimization**: Use memory cache for hot data
```swift
// Frequently accessed data
let sessionCache = MemoryCache<String, Session>()

// Infrequently accessed data
let historicalCache = try DiskCache<String, HistoricalData>()
```

### 4. Cache Size Management

```swift
class CacheMonitor {
    func checkCacheHealth() {
        let size = cache.totalCacheSize()

        if size > 100 * 1024 * 1024 { // 100 MB
            logWarning("Large cache size: \(size.formattedFileSize)")

            // Clean old entries
            cache.cleanExpired()

            // If still large, clear all
            if cache.totalCacheSize() > 100 * 1024 * 1024 {
                logWarning("Clearing entire cache")
                cache.removeAll()
            }
        }
    }
}
```

---

## Thread Safety

### Logger Thread Safety

**Current state**: Not fully thread-safe
- `print()` is thread-safe
- `os_log()` is thread-safe
- `writeToFile()` is NOT thread-safe

**Recommendation**: Add serial queue
```swift
private let logQueue = DispatchQueue(label: "com.iostemplate.logger", qos: .utility)

private func log(_ message: String, ...) {
    logQueue.async {
        // All logging operations
    }
}
```

### Cache Thread Safety

**MemoryCache**:
- NSCache is thread-safe
- KeyTracker uses NSCacheDelegate (thread-safe)

**DiskCache**:
- Uses concurrent queue with barriers
- Reads: concurrent
- Writes: exclusive (barrier)

**Thread-safe usage**:
```swift
// Multiple threads can safely access
DispatchQueue.global().async {
    cache.insert(data1, forKey: "key1")
}

DispatchQueue.global().async {
    cache.insert(data2, forKey: "key2")
}

DispatchQueue.global().async {
    let value = cache.value(forKey: "key1")
}
```

---

## Dependencies

- **Foundation**: Swift standard library
- **OSLog**: Apple's unified logging

---

## Related Documentation

- [Services Layer](/Sources/iOSTemplate/Services/README.md) - LoggingServiceProtocol
- [Storage Layer](/Sources/iOSTemplate/Storage/README.md) - Storage alternatives

---

**Cập nhật**: 2025-11-15
**Maintainer**: iOS Team
