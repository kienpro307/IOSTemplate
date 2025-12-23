import Foundation
import ComposableArchitecture

/// Protocol cho các thao tác Date (dễ test với mock date)
public protocol DateClientProtocol: Sendable {
    /// Lấy ngày giờ hiện tại
    func now() -> Date
    
    /// Tạo Date từ chuỗi với định dạng cho trước
    func date(from string: String, format: String) -> Date?
}

// MARK: - Triển khai thực tế
/// Triển khai thực tế sử dụng Date() của hệ thống
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

// MARK: - Triển khai Mock (ngày cố định cho testing)
/// Triển khai giả lập với ngày cố định để dễ test
public struct MockDateClient: DateClientProtocol {
    /// Ngày giả lập để trả về
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

// MARK: - Khóa Dependency
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
