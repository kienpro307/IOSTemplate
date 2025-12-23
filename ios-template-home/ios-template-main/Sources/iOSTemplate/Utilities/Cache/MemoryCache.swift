import Foundation

/// Memory cache using NSCache
public final class MemoryCache<Key: Hashable, Value> {

    // MARK: - Properties

    private let cache = NSCache<WrappedKey, Entry>()
    private let dateProvider: () -> Date
    private let entryLifetime: TimeInterval
    private let keyTracker = KeyTracker()

    // MARK: - Initialization

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

    // MARK: - Public Methods

    /// Insert value for key
    public func insert(_ value: Value, forKey key: Key) {
        let date = dateProvider().addingTimeInterval(entryLifetime)
        let entry = Entry(key: key, value: value, expirationDate: date)
        cache.setObject(entry, forKey: WrappedKey(key))
        keyTracker.keys.insert(key)
    }

    /// Get value for key
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

    /// Remove value for key
    public func removeValue(forKey key: Key) {
        cache.removeObject(forKey: WrappedKey(key))
    }

    /// Remove all values
    public func removeAll() {
        cache.removeAllObjects()
    }

    /// Check if key exists
    public func contains(_ key: Key) -> Bool {
        value(forKey: key) != nil
    }

    /// Get all keys
    public func allKeys() -> Set<Key> {
        keyTracker.keys
    }

    /// Subscribe to cache changes
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

// MARK: - Codable Support

extension MemoryCache: Codable where Key: Codable, Value: Codable {
    private enum CodingKeys: String, CodingKey {
        case entries
    }

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
