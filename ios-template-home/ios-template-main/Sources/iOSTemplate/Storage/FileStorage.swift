import Foundation

/// File storage manager cho documents, cache, temp files
public final class FileStorage: FileStorageProtocol {

    // MARK: - Properties

    private let fileManager: FileManager
    private let directory: Directory

    /// Storage directories
    public enum Directory {
        case documents
        case cache
        case temporary

        var searchPathDirectory: FileManager.SearchPathDirectory {
            switch self {
            case .documents:
                return .documentDirectory
            case .cache:
                return .cachesDirectory
            case .temporary:
                return .documentDirectory // temp uses documentDirectory base
            }
        }
    }

    // MARK: - Initialization

    public init(
        directory: Directory = .documents,
        fileManager: FileManager = .default
    ) {
        self.directory = directory
        self.fileManager = fileManager
    }

    // MARK: - Private Helpers

    private func baseURL() throws -> URL {
        switch directory {
        case .temporary:
            return URL(fileURLWithPath: NSTemporaryDirectory())
        case .documents, .cache:
            guard let url = fileManager.urls(
                for: directory.searchPathDirectory,
                in: .userDomainMask
            ).first else {
                throw StorageError.accessDenied
            }
            return url
        }
    }

    // MARK: - FileStorageProtocol

    public func fileURL(for fileName: String) -> URL {
        guard let baseURL = try? baseURL() else {
            return URL(fileURLWithPath: fileName)
        }
        return baseURL.appendingPathComponent(fileName)
    }

    public func save(_ data: Data, fileName: String) throws {
        let url = fileURL(for: fileName)

        // Create intermediate directories if needed
        let directoryURL = url.deletingLastPathComponent()
        try fileManager.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true,
            attributes: nil
        )

        do {
            try data.write(to: url, options: .atomic)
        } catch {
            if (error as NSError).code == NSFileWriteOutOfSpaceError {
                throw StorageError.diskFull
            }
            throw StorageError.unknown(error)
        }
    }

    public func load(fileName: String) throws -> Data? {
        let url = fileURL(for: fileName)

        guard fileManager.fileExists(atPath: url.path) else {
            throw StorageError.notFound
        }

        do {
            return try Data(contentsOf: url)
        } catch {
            throw StorageError.unknown(error)
        }
    }

    public func delete(fileName: String) throws {
        let url = fileURL(for: fileName)

        guard fileManager.fileExists(atPath: url.path) else {
            throw StorageError.notFound
        }

        do {
            try fileManager.removeItem(at: url)
        } catch {
            throw StorageError.unknown(error)
        }
    }

    public func exists(fileName: String) -> Bool {
        let url = fileURL(for: fileName)
        return fileManager.fileExists(atPath: url.path)
    }

    public func directorySize() throws -> Int64 {
        let baseURL = try baseURL()
        var totalSize: Int64 = 0

        guard let enumerator = fileManager.enumerator(
            at: baseURL,
            includingPropertiesForKeys: [.fileSizeKey],
            options: [.skipsHiddenFiles]
        ) else {
            return 0
        }

        for case let fileURL as URL in enumerator {
            guard let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path) else {
                continue
            }

            if let fileSize = attributes[.size] as? Int64 {
                totalSize += fileSize
            }
        }

        return totalSize
    }

    public func clearDirectory() throws {
        let baseURL = try baseURL()

        guard let enumerator = fileManager.enumerator(
            at: baseURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else {
            return
        }

        for case let fileURL as URL in enumerator {
            try? fileManager.removeItem(at: fileURL)
        }
    }

    // MARK: - Additional Utilities

    /// List all files in directory
    public func listFiles() throws -> [String] {
        let baseURL = try baseURL()

        let contents = try fileManager.contentsOfDirectory(
            at: baseURL,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )

        return contents
            .filter { url in
                (try? url.resourceValues(forKeys: [.isRegularFileKey]))?.isRegularFile == true
            }
            .map { $0.lastPathComponent }
    }

    /// Get file size
    public func fileSize(fileName: String) throws -> Int64 {
        let url = fileURL(for: fileName)

        guard fileManager.fileExists(atPath: url.path) else {
            throw StorageError.notFound
        }

        let attributes = try fileManager.attributesOfItem(atPath: url.path)
        return attributes[.size] as? Int64 ?? 0
    }

    /// Save Codable object to file
    public func saveObject<T: Codable>(_ object: T, fileName: String) throws -> URL {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let data = try encoder.encode(object)
            try save(data, fileName: fileName)
            return fileURL(for: fileName)
        } catch {
            throw StorageError.encodingFailed
        }
    }

    /// Load Codable object from file
    public func loadObject<T: Codable>(fileName: String) throws -> T {
        guard let data = try load(fileName: fileName) else {
            throw StorageError.notFound
        }
        let decoder = JSONDecoder()

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw StorageError.decodingFailed
        }
    }

    /// Copy file from one location to another
    public func copyFile(from source: String, to destination: String) throws {
        let sourceURL = fileURL(for: source)
        let destURL = fileURL(for: destination)

        guard fileManager.fileExists(atPath: sourceURL.path) else {
            throw StorageError.notFound
        }

        try fileManager.copyItem(at: sourceURL, to: destURL)
    }

    /// Move file from one location to another
    public func moveFile(from source: String, to destination: String) throws {
        let sourceURL = fileURL(for: source)
        let destURL = fileURL(for: destination)

        guard fileManager.fileExists(atPath: sourceURL.path) else {
            throw StorageError.notFound
        }

        try fileManager.moveItem(at: sourceURL, to: destURL)
    }
}

// MARK: - Convenience Extensions

public extension FileStorage {
    /// Documents directory storage
    static var documents: FileStorage {
        FileStorage(directory: .documents)
    }

    /// Cache directory storage
    static var cache: FileStorage {
        FileStorage(directory: .cache)
    }

    /// Temporary directory storage
    static var temporary: FileStorage {
        FileStorage(directory: .temporary)
    }
}

// MARK: - File Size Formatting

public extension Int64 {
    /// Format file size to human readable string
    var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: self)
    }
}

// MARK: - Example Usage

/*
 Usage Example:

 let fileStorage = FileStorage.documents

 // Save data
 let data = "Hello, World!".data(using: .utf8)!
 try fileStorage.save(data, fileName: "hello.txt")

 // Load data
 let loadedData = try fileStorage.load(fileName: "hello.txt")
 let text = loadedData.flatMap { String(data: $0, encoding: .utf8) }

 // Save Codable object
 struct User: Codable {
     let name: String
     let age: Int
 }
 let user = User(name: "John", age: 30)
 try fileStorage.saveObject(user, fileName: "user.json")

 // Load Codable object
 let loadedUser: User = try fileStorage.loadObject(fileName: "user.json")

 // Check file size
 let size = try fileStorage.fileSize(fileName: "user.json")
 print(size.formattedFileSize) // "234 bytes"

 // List all files
 let files = try fileStorage.listFiles()

 // Get directory size
 let totalSize = try fileStorage.directorySize()
 print(totalSize.formattedFileSize) // "1.5 MB"

 // Clear cache
 let cache = FileStorage.cache
 try cache.clearDirectory()
 */
