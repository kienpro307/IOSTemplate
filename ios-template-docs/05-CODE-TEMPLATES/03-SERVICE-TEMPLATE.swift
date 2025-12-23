// MARK: - [ServiceName]Service.swift
// Template cho Service với Dependency Injection - Code tiếng Anh, comment tiếng Việt

import Foundation
import ComposableArchitecture

// MARK: - Protocol
/// Giao thức định nghĩa các chức năng của service
protocol ItemServiceProtocol: Sendable {
    func fetchItems(page: Int) async throws -> [Item]
    func fetchItem(id: String) async throws -> Item
    func createItem(_ item: Item) async throws -> Item
    func updateItem(_ item: Item) async throws -> Item
    func deleteItem(id: String) async throws
}

// MARK: - Live Implementation
/// Implementation thực tế gọi API
struct LiveItemService: ItemServiceProtocol {
    let networkClient: NetworkClientProtocol
    
    func fetchItems(page: Int) async throws -> [Item] {
        try await networkClient.request(.fetchItems(page: page))
    }
    
    func fetchItem(id: String) async throws -> Item {
        try await networkClient.request(.fetchItem(id: id))
    }
    
    func createItem(_ item: Item) async throws -> Item {
        try await networkClient.request(.createItem(item))
    }
    
    func updateItem(_ item: Item) async throws -> Item {
        try await networkClient.request(.updateItem(item))
    }
    
    func deleteItem(id: String) async throws {
        try await networkClient.request(.deleteItem(id: id))
    }
}

// MARK: - Mock Implementation
/// Implementation giả cho testing và preview
struct MockItemService: ItemServiceProtocol {
    var items: [Item] = []
    var mockError: Error?
    
    func fetchItems(page: Int) async throws -> [Item] {
        if let error = mockError { throw error }
        return items
    }
    
    func fetchItem(id: String) async throws -> Item {
        if let error = mockError { throw error }
        return items.first { $0.id == id } ?? Item.mock
    }
    
    func createItem(_ item: Item) async throws -> Item { item }
    func updateItem(_ item: Item) async throws -> Item { item }
    func deleteItem(id: String) async throws { }
}

// MARK: - Dependency Key
struct ItemServiceKey: DependencyKey {
    static let liveValue: ItemServiceProtocol = LiveItemService(
        networkClient: LiveNetworkClient()
    )
    static let testValue: ItemServiceProtocol = MockItemService()
    static let previewValue: ItemServiceProtocol = MockItemService(
        items: Item.mockList
    )
}

extension DependencyValues {
    var itemService: ItemServiceProtocol {
        get { self[ItemServiceKey.self] }
        set { self[ItemServiceKey.self] = newValue }
    }
}
