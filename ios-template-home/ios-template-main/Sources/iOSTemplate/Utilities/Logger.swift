import Foundation
import OSLog

/// Unified logging system cho app
public final class Logger: LoggingServiceProtocol {

    // MARK: - Singleton

    public static let shared = Logger()

    // MARK: - Properties

    private let osLog: OSLog
    private var logToFile: Bool = false
    private var logFilePath: URL?

    // MARK: - Log Level

    public enum LogLevel: Int, Comparable {
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

    // Current log level (chỉ log messages >= level này)
    public var minimumLogLevel: LogLevel = {
        #if DEBUG
        return .verbose
        #else
        return .info
        #endif
    }()

    // MARK: - Initialization

    private init() {
        self.osLog = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.iostemplate.app", category: "General")
        setupFileLogging()
    }

    // MARK: - LoggingServiceProtocol

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
        // Check minimum log level
        guard level >= minimumLogLevel else { return }

        let fileName = (file as NSString).lastPathComponent
        let timestamp = dateFormatter.string(from: Date())

        let logMessage = "\(level.emoji) [\(timestamp)] [\(fileName):\(line)] \(function) - \(message)"

        // Log to console
        #if DEBUG
        print(logMessage)
        #endif

        // Log to OS Logger
        os_log("%{public}@", log: osLog, type: level.osLogType, logMessage)

        // Log to file
        if logToFile {
            writeToFile(logMessage)
        }
    }

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()

    // MARK: - File Logging

    private func setupFileLogging() {
        #if DEBUG
        logToFile = false // Disable file logging in debug
        #else
        logToFile = true
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

        // Create log file
        let dateString = DateFormatter.logFileName.string(from: Date())
        logFilePath = logsDirectory.appendingPathComponent("log_\(dateString).txt")

        // Clean old logs (keep last 7 days)
        cleanOldLogs(in: logsDirectory)
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

    // MARK: - Public Utilities

    /// Get logs from file
    public func getLogs() -> String? {
        guard let filePath = logFilePath else { return nil }
        return try? String(contentsOf: filePath, encoding: .utf8)
    }

    /// Clear all logs
    public func clearLogs() {
        guard let filePath = logFilePath else { return }
        try? FileManager.default.removeItem(at: filePath)
        setupFileLogging()
    }

    /// Get log file URL
    public func getLogFileURL() -> URL? {
        logFilePath
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

// MARK: - Global Log Functions

/// Global logging functions for convenience
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
