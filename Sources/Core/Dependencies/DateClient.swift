import Foundation
import ComposableArchitecture

/// Protocol cho Date operations (dễ test với mock date)
public protocol DateClientProtocol: Sendable {
    /// Lấy date hiện tại
    func now() -> Date
    
    /// Tạo date từ string
    func date(from string: String, format: String) -> Date?
}

// MARK: - Live Implementation
public struct LiveDateClient: DateClientProtocol {
    public init() {}
    
    public func now() -> Date {
        Date()
    }
    
    public func date(from string: String, format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: string)
    }
}

// MARK: - Mock Implementation (fixed date for testing)
public struct MockDateClient: DateClientProtocol {
    public var mockDate: Date
    
    public init(mockDate: Date = Date()) {
        self.mockDate = mockDate
    }
    
    public func now() -> Date {
        mockDate
    }
    
    public func date(from string: String, format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: string)
    }
}

// MARK: - Dependency Key
private enum DateClientKey: DependencyKey {
    static let liveValue: DateClientProtocol = LiveDateClient()
    static let testValue: DateClientProtocol = MockDateClient()
    static let previewValue: DateClientProtocol = MockDateClient()
}

extension DependencyValues {
    public var dateClient: DateClientProtocol {
        get { self[DateClientKey.self] }
        set { self[DateClientKey.self] = newValue }
    }
}
