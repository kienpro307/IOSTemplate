import Foundation
import ComposableArchitecture

/// Protocol cho các thao tác cache
public protocol CacheClientProtocol: Sendable {
    /// Thêm giá trị vào cache (memory và disk)
    func insert<Key: Hashable & Codable, Value: Codable>(_ value: Value, forKey key: Key) async throws
    
    /// Lấy giá trị từ cache (kiểm tra memory trước, sau đó disk)
    func value<Key: Hashable & Codable, Value: Codable>(forKey key: Key) async throws -> Value?
    
    /// Xóa giá trị theo key
    func removeValue<Key: Hashable & Codable>(forKey key: Key) async throws
    
    /// Xóa tất cả giá trị
    func removeAll() async throws
    
    /// Lấy kích thước cache tính bằng bytes
    func cacheSize() async throws -> Int64
    
    /// Dọn dẹp các entry đã hết hạn
    func cleanExpired() async throws
}

// MARK: - Triển khai thực tế
/// Triển khai thực tế với MemoryCache và DiskCache
/// Sử dụng type-erased approach để hỗ trợ generic types
public actor LiveCacheClient: CacheClientProtocol {
    private struct CacheEntry: Codable {
        let data: Data
        let typeName: String
    }
    
    private let memoryCache: MemoryCache<String, CacheEntry>
    private let diskCache: DiskCache<String, CacheEntry>?
    
    public init(
        name: String = "DefaultCache",
        memoryEntryLifetime: TimeInterval = 12 * 60 * 60, // 12 giờ
        diskEntryLifetime: TimeInterval = 7 * 24 * 60 * 60, // 7 ngày
        useDiskCache: Bool = true
    ) {
        self.memoryCache = MemoryCache(entryLifetime: memoryEntryLifetime)
        self.diskCache = useDiskCache ? try? DiskCache(name: name, entryLifetime: diskEntryLifetime) : nil
    }
    
    public func insert<Key: Hashable & Codable, Value: Codable>(_ value: Value, forKey key: Key) async throws {
        let keyString = try encodeKey(key)
        let data = try JSONEncoder().encode(value)
        let typeName = String(describing: Value.self)
        let entry = CacheEntry(data: data, typeName: typeName)
        
        // Insert vào memory cache
        memoryCache.insert(entry, forKey: keyString)
        
        // Insert vào disk cache
        try? diskCache?.insert(entry, forKey: keyString)
    }
    
    public func value<Key: Hashable & Codable, Value: Codable>(forKey key: Key) async throws -> Value? {
        let keyString = try encodeKey(key)
        
        // Kiểm tra memory cache trước
        if let cachedEntry = memoryCache.value(forKey: keyString) {
            return try decodeValue(from: cachedEntry)
        }
        
        // Kiểm tra disk cache
        if let diskEntry = try? diskCache?.value(forKey: keyString) {
            // Restore vào memory cache
            memoryCache.insert(diskEntry, forKey: keyString)
            return try decodeValue(from: diskEntry)
        }
        
        return nil
    }
    
    public func removeValue<Key: Hashable & Codable>(forKey key: Key) async throws {
        let keyString = try encodeKey(key)
        memoryCache.removeValue(forKey: keyString)
        try? diskCache?.removeValue(forKey: keyString)
    }
    
    public func removeAll() async throws {
        memoryCache.removeAll()
        try? diskCache?.removeAll()
    }
    
    public func cacheSize() async throws -> Int64 {
        try diskCache?.cacheSize() ?? 0
    }
    
    public func cleanExpired() async throws {
        try? diskCache?.cleanExpiredEntries()
    }
    
    // MARK: - Private Helpers
    
    /// Encode key thành String để dùng trong cache
    private func encodeKey<Key: Hashable & Codable>(_ key: Key) throws -> String {
        let data = try JSONEncoder().encode(key)
        return data.base64EncodedString()
    }
    
    /// Decode value từ CacheEntry
    private func decodeValue<Value: Codable>(from entry: CacheEntry) throws -> Value? {
        let decoder = JSONDecoder()
        return try decoder.decode(Value.self, from: entry.data)
    }
}

// MARK: - Triển khai Mock (cho tests & previews)
/// Triển khai giả lập cho testing
public actor MockCacheClient: CacheClientProtocol {
    private struct CacheEntry: Codable {
        let data: Data
        let typeName: String
    }
    
    private var storage: [String: CacheEntry] = [:]
    public var shouldFail = false
    public var mockError: Error?
    
    public init() {}
    
    public func insert<Key: Hashable & Codable, Value: Codable>(_ value: Value, forKey key: Key) async throws {
        if shouldFail {
            throw mockError ?? DataError.databaseError("Mock cache insert failed")
        }
        let keyString = try encodeKey(key)
        let data = try JSONEncoder().encode(value)
        let typeName = String(describing: Value.self)
        let entry = CacheEntry(data: data, typeName: typeName)
        storage[keyString] = entry
    }
    
    public func value<Key: Hashable & Codable, Value: Codable>(forKey key: Key) async throws -> Value? {
        if shouldFail {
            throw mockError ?? DataError.databaseError("Mock cache get failed")
        }
        let keyString = try encodeKey(key)
        guard let entry = storage[keyString] else {
            return nil
        }
        return try decodeValue(from: entry)
    }
    
    public func removeValue<Key: Hashable & Codable>(forKey key: Key) async throws {
        if shouldFail {
            throw mockError ?? DataError.databaseError("Mock cache remove failed")
        }
        let keyString = try encodeKey(key)
        storage.removeValue(forKey: keyString)
    }
    
    public func removeAll() async throws {
        if shouldFail {
            throw mockError ?? DataError.databaseError("Mock cache removeAll failed")
        }
        storage.removeAll()
    }
    
    public func cacheSize() async throws -> Int64 {
        return 0
    }
    
    public func cleanExpired() async throws {
        // Mock: không làm gì
    }
    
    // MARK: - Private Helpers
    
    private func encodeKey<Key: Hashable & Codable>(_ key: Key) throws -> String {
        let data = try JSONEncoder().encode(key)
        return data.base64EncodedString()
    }
    
    /// Decode value từ CacheEntry
    private func decodeValue<Value: Codable>(from entry: CacheEntry) throws -> Value? {
        let decoder = JSONDecoder()
        return try decoder.decode(Value.self, from: entry.data)
    }
}

// MARK: - Khóa Dependency
private enum CacheClientKey: DependencyKey {
    static let liveValue: CacheClientProtocol = LiveCacheClient()
    static let testValue: CacheClientProtocol = MockCacheClient()
    static let previewValue: CacheClientProtocol = MockCacheClient()
}

extension DependencyValues {
    public var cacheClient: CacheClientProtocol {
        get { self[CacheClientKey.self] }
        set { self[CacheClientKey.self] = newValue }
    }
}

