// MARK: - [Name]Repository.swift
// Template cho Repository Pattern - Code tiếng Anh, comment tiếng Việt

import Foundation
import ComposableArchitecture

// MARK: - Protocol
/// Repository quản lý dữ liệu với 3 tầng: Cache -> Local DB -> Remote
protocol ItemRepositoryProtocol: Sendable {
    func fetch(id: String) async throws -> Item?
    func fetchAll() async throws -> [Item]
    func save(_ item: Item) async throws
    func delete(id: String) async throws
}

// MARK: - Implementation
/// Implementation với caching strategy
struct LiveItemRepository: ItemRepositoryProtocol {
    let networkClient: NetworkClientProtocol
    let localDatabase: LocalDatabaseProtocol
    let cache: CacheProtocol
    
    /// Lấy item theo id với chiến lược cache-first
    func fetch(id: String) async throws -> Item? {
        // 1. Kiểm tra cache trước
        if let cached = cache.get(key: "item_\(id)") as? Item {
            return cached
        }
        
        // 2. Kiểm tra local DB
        if let local = try await localDatabase.fetch(id: id) {
            cache.set(local, key: "item_\(id)")
            return local
        }
        
        // 3. Fetch từ network
        let remote = try await networkClient.request(.fetchItem(id: id)) as Item
        
        // 4. Lưu vào local DB và cache
        try await localDatabase.save(remote)
        cache.set(remote, key: "item_\(id)")
        
        return remote
    }
    
    /// Lấy tất cả items
    func fetchAll() async throws -> [Item] {
        // Tương tự logic 3 tầng
        try await networkClient.request(.fetchItems(page: 1))
    }
    
    /// Lưu item
    func save(_ item: Item) async throws {
        try await networkClient.request(.updateItem(item))
        try await localDatabase.save(item)
        cache.set(item, key: "item_\(item.id)")
    }
    
    /// Xóa item
    func delete(id: String) async throws {
        try await networkClient.request(.deleteItem(id: id))
        try await localDatabase.delete(id: id)
        cache.remove(key: "item_\(id)")
    }
}

// MARK: - Dependency Key
struct ItemRepositoryKey: DependencyKey {
    static let liveValue: ItemRepositoryProtocol = LiveItemRepository(
        networkClient: LiveNetworkClient(),
        localDatabase: LiveLocalDatabase(),
        cache: LiveCache()
    )
}

extension DependencyValues {
    var itemRepository: ItemRepositoryProtocol {
        get { self[ItemRepositoryKey.self] }
        set { self[ItemRepositoryKey.self] = newValue }
    }
}
