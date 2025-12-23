import Foundation

/// Disk-based cache cho persistent storage
/// Hỗ trợ generic Key và Value (phải Codable)
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
        entryLifetime: TimeInterval = 7 * 24 * 60 * 60, // 7 ngày mặc định
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
            throw DataError.databaseError("Không thể truy cập caches directory")
        }
        
        self.cacheDirectory = cachesDirectory
            .appendingPathComponent("DiskCache", isDirectory: true)
            .appendingPathComponent(name, isDirectory: true)
        
        try createCacheDirectoryIfNeeded()
    }
    
    // MARK: - Public Methods
    
    /// Thêm giá trị vào cache
    public func insert(_ value: Value, forKey key: Key) throws {
        let entry = Entry(value: value, expirationDate: dateProvider().addingTimeInterval(entryLifetime))
        let data = try JSONEncoder().encode(entry)
        let fileURL = cacheFileURL(for: key)
        
        try queue.sync(flags: .barrier) {
            try data.write(to: fileURL)
        }
    }
    
    /// Lấy giá trị từ cache
    public func value(forKey key: Key) throws -> Value? {
        try queue.sync {
            let fileURL = cacheFileURL(for: key)
            
            guard fileManager.fileExists(atPath: fileURL.path) else {
                return nil
            }
            
            let data = try Data(contentsOf: fileURL)
            let entry = try JSONDecoder().decode(Entry.self, from: data)
            
            // Kiểm tra expiration
            guard dateProvider() < entry.expirationDate else {
                try? removeValue(forKey: key)
                return nil
            }
            
            return entry.value
        }
    }
    
    /// Xóa giá trị theo key
    public func removeValue(forKey key: Key) throws {
        try queue.sync(flags: .barrier) {
            let fileURL = cacheFileURL(for: key)
            try fileManager.removeItem(at: fileURL)
        }
    }
    
    /// Xóa tất cả giá trị
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
    
    /// Lấy kích thước cache tính bằng bytes
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
    
    /// Dọn dẹp các entry đã hết hạn
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

