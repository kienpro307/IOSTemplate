import Foundation

/// Disk-based cache for persistent storage
public final class DiskCache<Key: Hashable & Codable, Value: Codable> {

    // MARK: - Properties

    private let fileManager: FileManager
    private let cacheDirectory: URL
    private let dateProvider: () -> Date
    private let entryLifetime: TimeInterval
    private let queue = DispatchQueue(label: "com.iostemplate.diskcache", attributes: .concurrent)

    // MARK: - Initialization

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

    // MARK: - Public Methods

    /// Insert value for key
    public func insert(_ value: Value, forKey key: Key) throws {
        let entry = Entry(value: value, expirationDate: dateProvider().addingTimeInterval(entryLifetime))
        let data = try JSONEncoder().encode(entry)
        let fileURL = cacheFileURL(for: key)

        try queue.sync(flags: .barrier) {
            try data.write(to: fileURL)
        }
    }

    /// Get value for key
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

    /// Remove value for key
    public func removeValue(forKey key: Key) throws {
        try queue.sync(flags: .barrier) {
            let fileURL = cacheFileURL(for: key)
            try fileManager.removeItem(at: fileURL)
        }
    }

    /// Remove all values
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

    /// Get cache size in bytes
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

    /// Clean expired entries
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

    // MARK: - Private Methods

    private func createCacheDirectoryIfNeeded() throws {
        guard !fileManager.fileExists(atPath: cacheDirectory.path) else {
            return
        }

        try fileManager.createDirectory(
            at: cacheDirectory,
            withIntermediateDirectories: true
        )
    }

    private func cacheFileURL(for key: Key) -> URL {
        let fileName = String(describing: key).addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "unknown"
        return cacheDirectory.appendingPathComponent(fileName)
    }

    // MARK: - Entry

    private struct Entry: Codable {
        let value: Value
        let expirationDate: Date
    }
}

// MARK: - CacheManager

/// Combined memory and disk cache manager
public final class CacheManager<Key: Hashable & Codable, Value: Codable> {

    // MARK: - Properties

    private let memoryCache: MemoryCache<Key, Value>
    private let diskCache: DiskCache<Key, Value>?

    // MARK: - Initialization

    public init(
        name: String = "DefaultCache",
        memoryEntryLifetime: TimeInterval = 12 * 60 * 60,
        diskEntryLifetime: TimeInterval = 7 * 24 * 60 * 60,
        useDiskCache: Bool = true
    ) {
        self.memoryCache = MemoryCache(entryLifetime: memoryEntryLifetime)
        self.diskCache = useDiskCache ? try? DiskCache(name: name, entryLifetime: diskEntryLifetime) : nil
    }

    // MARK: - Public Methods

    /// Insert value for key (both memory and disk)
    public func insert(_ value: Value, forKey key: Key) {
        // Insert to memory cache
        memoryCache.insert(value, forKey: key)

        // Insert to disk cache
        try? diskCache?.insert(value, forKey: key)
    }

    /// Get value for key (check memory first, then disk)
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

    /// Remove value for key
    public func removeValue(forKey key: Key) {
        memoryCache.removeValue(forKey: key)
        try? diskCache?.removeValue(forKey: key)
    }

    /// Remove all values
    public func removeAll() {
        memoryCache.removeAll()
        try? diskCache?.removeAll()
    }

    /// Get total cache size
    public func totalCacheSize() -> Int64 {
        (try? diskCache?.cacheSize()) ?? 0
    }

    /// Clean expired entries
    public func cleanExpired() {
        try? diskCache?.cleanExpiredEntries()
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
}
