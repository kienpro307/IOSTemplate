import Foundation
import OSLog
import ComposableArchitecture

/// Protocol cho các thao tác logging
public protocol LoggerClientProtocol: Sendable {
    /// Log verbose message
    func verbose(_ message: String, file: String, function: String, line: Int)
    
    /// Log debug message
    func debug(_ message: String, file: String, function: String, line: Int)
    
    /// Log info message
    func info(_ message: String, file: String, function: String, line: Int)
    
    /// Log warning message
    func warning(_ message: String, file: String, function: String, line: Int)
    
    /// Log error message
    func error(_ message: String, error: Error?, file: String, function: String, line: Int)
}

// MARK: - Log Level

/// Mức độ log
public enum LogLevel: Int, Comparable, Sendable {
    case verbose = 0
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4
    
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
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

// MARK: - Triển khai thực tế

/// Triển khai thực tế với OSLog và file logging
/// Thread-safe với OSLog và FileManager
public final class LiveLoggerClient: LoggerClientProtocol, @unchecked Sendable {
    private let osLog: OSLog
    private let logToFile: Bool
    private let minimumLogLevel: LogLevel
    
    // Thread-safe access với serial queue
    private let fileLoggingQueue = DispatchQueue(label: "com.iostemplate.logger.file", qos: .utility)
    private var logFilePath: URL?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    public init(
        subsystem: String? = nil,
        category: String = "General",
        minimumLogLevel: LogLevel? = nil,
        enableFileLogging: Bool? = nil
    ) {
        let bundleID = Bundle.main.bundleIdentifier ?? "com.iostemplate.app"
        self.osLog = OSLog(subsystem: subsystem ?? bundleID, category: category)
        
        // Set minimum log level
        #if DEBUG
        self.minimumLogLevel = minimumLogLevel ?? .verbose
        #else
        self.minimumLogLevel = minimumLogLevel ?? .info
        #endif
        
        // Setup file logging
        #if DEBUG
        self.logToFile = enableFileLogging ?? false
        #else
        self.logToFile = enableFileLogging ?? true
        #endif
        
        if self.logToFile {
            setupFileLogging()
        }
    }
    
    public func verbose(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .verbose, file: file, function: function, line: line)
    }
    
    public func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    public func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    public func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    public func error(_ message: String, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        var fullMessage = message
        if let error = error {
            fullMessage += " | Error: \(error.localizedDescription)"
        }
        log(fullMessage, level: .error, file: file, function: function, line: line)
    }
    
    // MARK: - Private Methods
    
    private func log(
        _ message: String,
        level: LogLevel,
        file: String,
        function: String,
        line: Int
    ) {
        // Kiểm tra minimum log level
        guard level >= minimumLogLevel else { return }
        
        let fileName = (file as NSString).lastPathComponent
        let timestamp = dateFormatter.string(from: Date())
        
        let logMessage = "\(level.emoji) [\(timestamp)] [\(fileName):\(line)] \(function) - \(message)"
        
        // Log to console (DEBUG only)
        #if DEBUG
        print(logMessage)
        #endif
        
        // Log to OS Logger
        os_log("%{public}@", log: osLog, type: level.osLogType, logMessage)
        
        // Log to file (thread-safe)
        if logToFile {
            fileLoggingQueue.async { [weak self] in
                self?.writeToFile(logMessage)
            }
        }
        
        // Note: Crashlytics tự động capture logs từ OSLog
        // Không cần log trực tiếp từ đây
    }
    
    // MARK: - File Logging
    
    private func setupFileLogging() {
        guard logToFile else { return }
        
        fileLoggingQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Setup log file path
            let fileManager = FileManager.default
            guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
            }
            
            let logsDirectory = documentsDirectory.appendingPathComponent("Logs", isDirectory: true)
            
            // Create logs directory if needed
            try? fileManager.createDirectory(at: logsDirectory, withIntermediateDirectories: true)
            
            // Create log file
            let dateString = DateFormatter.logFileName.string(from: Date())
            self.logFilePath = logsDirectory.appendingPathComponent("log_\(dateString).txt")
            
            // Clean old logs (keep last 7 days)
            self.cleanOldLogs(in: logsDirectory)
        }
    }
    
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
}

// MARK: - DateFormatter Extension

private extension DateFormatter {
    static let logFileName: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

// MARK: - Triển khai Mock (cho tests & previews)

/// Triển khai giả lập cho testing
public final class MockLoggerClient: LoggerClientProtocol, @unchecked Sendable {
    public struct LogEntry: Sendable {
        let level: LogLevel
        let message: String
        let file: String
        let function: String
        let line: Int
        let error: Error?
        let timestamp: Date
    }
    
    // Thread-safe access với serial queue
    private let queue = DispatchQueue(label: "com.iostemplate.logger.mock", qos: .utility)
    private var _logs: [LogEntry] = []
    public var shouldLog: Bool = true
    
    public init() {}
    
    public var logs: [LogEntry] {
        queue.sync { _logs }
    }
    
    public func verbose(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        guard shouldLog else { return }
        queue.async { [weak self] in
            self?._logs.append(LogEntry(
                level: .verbose,
                message: message,
                file: file,
                function: function,
                line: line,
                error: nil,
                timestamp: Date()
            ))
        }
    }
    
    public func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        guard shouldLog else { return }
        queue.async { [weak self] in
            self?._logs.append(LogEntry(
                level: .debug,
                message: message,
                file: file,
                function: function,
                line: line,
                error: nil,
                timestamp: Date()
            ))
        }
    }
    
    public func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        guard shouldLog else { return }
        queue.async { [weak self] in
            self?._logs.append(LogEntry(
                level: .info,
                message: message,
                file: file,
                function: function,
                line: line,
                error: nil,
                timestamp: Date()
            ))
        }
    }
    
    public func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        guard shouldLog else { return }
        queue.async { [weak self] in
            self?._logs.append(LogEntry(
                level: .warning,
                message: message,
                file: file,
                function: function,
                line: line,
                error: nil,
                timestamp: Date()
            ))
        }
    }
    
    public func error(_ message: String, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        guard shouldLog else { return }
        queue.async { [weak self] in
            self?._logs.append(LogEntry(
                level: .error,
                message: message,
                file: file,
                function: function,
                line: line,
                error: error,
                timestamp: Date()
            ))
        }
    }
    
    /// Clear all logs (useful for testing)
    public func clearLogs() {
        queue.async { [weak self] in
            self?._logs.removeAll()
        }
    }
}

// MARK: - Khóa Dependency

private enum LoggerClientKey: DependencyKey {
    static let liveValue: LoggerClientProtocol = LiveLoggerClient()
    static let testValue: LoggerClientProtocol = MockLoggerClient()
    static let previewValue: LoggerClientProtocol = MockLoggerClient()
}

extension DependencyValues {
    public var loggerClient: LoggerClientProtocol {
        get { self[LoggerClientKey.self] }
        set { self[LoggerClientKey.self] = newValue }
    }
}

