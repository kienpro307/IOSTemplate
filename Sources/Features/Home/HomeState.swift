import ComposableArchitecture
import Foundation
import SwiftUI

/// Trạng thái của Home feature
@ObservableState
public struct HomeState: Equatable {
    /// Đang tải dữ liệu không
    public var isLoading: Bool = false
    
    /// Quick actions để hiển thị
    public var quickActions: [QuickAction] = [
        QuickAction(icon: "square.and.arrow.up", title: "Share", color: .blue),
        QuickAction(icon: "bookmark", title: "Saved", color: .green),
        QuickAction(icon: "chart.bar", title: "Analytics", color: .orange),
        QuickAction(icon: "person.2", title: "Friends", color: .purple)
    ]
    
    /// Recent activities để hiển thị
    public var recentActivities: [Activity] = [
        Activity(icon: "checkmark.circle.fill", title: "Activity 1", subtitle: "2 hours ago", color: .green),
        Activity(icon: "checkmark.circle.fill", title: "Activity 2", subtitle: "3 hours ago", color: .green),
        Activity(icon: "checkmark.circle.fill", title: "Activity 3", subtitle: "5 hours ago", color: .green)
    ]
    
    public init() {}
}

// MARK: - Quick Action Model

/// Model cho quick action
public struct QuickAction: Equatable, Identifiable {
    public let id: String
    public let icon: String
    public let title: String
    public let color: Color
    
    public init(icon: String, title: String, color: Color) {
        self.id = UUID().uuidString
        self.icon = icon
        self.title = title
        self.color = color
    }
}

// MARK: - Activity Model

/// Model cho activity
public struct Activity: Equatable, Identifiable {
    public let id: String
    public let icon: String
    public let title: String
    public let subtitle: String
    public let color: Color
    
    public init(icon: String, title: String, subtitle: String, color: Color) {
        self.id = UUID().uuidString
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.color = color
    }
}

