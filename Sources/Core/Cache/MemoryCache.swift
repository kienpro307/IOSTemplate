import Foundation

/// Memory cache sử dụng NSCache
/// Hỗ trợ generic Key và Value
public final class MemoryCache<Key: Hashable, Value> {
    
    // MARK: - Properties
    
    private let cache = NSCache<WrappedKey, Entry>()
    private let dateProvider: () -> Date
    private let entryLifetime: TimeInterval
    private let keyTracker = KeyTracker()
    
    // MARK: - Initialization
    
    public init(
        dateProvider: @escaping () -> Date = Date.init,
        entryLifetime: TimeInterval = 12 * 60 * 60, // 12 giờ mặc định
        maximumEntryCount: Int = 50
    ) {
        self.dateProvider = dateProvider
        self.entryLifetime = entryLifetime
        cache.countLimit = maximumEntryCount
        cache.delegate = keyTracker
    }
    
    // MARK: - Public Methods
    
    /// Thêm giá trị vào cache
    public func insert(_ value: Value, forKey key: Key) {
        let date = dateProvider().addingTimeInterval(entryLifetime)
        let entry = Entry(key: key, value: value, expirationDate: date)
        cache.setObject(entry, forKey: WrappedKey(key))
        keyTracker.keys.insert(key)
    }
    
    /// Lấy giá trị từ cache
    public func value(forKey key: Key) -> Value? {
        guard let entry = cache.object(forKey: WrappedKey(key)) else {
            return nil
        }
        
        // Kiểm tra expiration
        guard dateProvider() < entry.expirationDate else {
            removeValue(forKey: key)
            return nil
        }
        
        return entry.value
    }
    
    /// Xóa giá trị theo key
    public func removeValue(forKey key: Key) {
        cache.removeObject(forKey: WrappedKey(key))
        keyTracker.keys.remove(key)
    }
    
    /// Xóa tất cả giá trị
    public func removeAll() {
        cache.removeAllObjects()
        keyTracker.keys.removeAll()
    }
    
    /// Kiểm tra key có tồn tại không
    public func contains(_ key: Key) -> Bool {
        value(forKey: key) != nil
    }
    
    /// Lấy tất cả keys
    public func allKeys() -> Set<Key> {
        keyTracker.keys
    }
    
    /// Subscript access
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
    
    // MARK: - Private Types
    
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
}

