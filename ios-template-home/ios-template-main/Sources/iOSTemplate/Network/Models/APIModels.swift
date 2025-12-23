import Foundation

// MARK: - Base Response

/// Base API response wrapper
public struct APIResponse<T: Codable>: Codable {
    public let success: Bool
    public let data: T?
    public let message: String?
    public let errors: [APIError]?

    public init(success: Bool, data: T?, message: String? = nil, errors: [APIError]? = nil) {
        self.success = success
        self.data = data
        self.message = message
        self.errors = errors
    }
}

/// API Error model
public struct APIError: Codable, Error {
    public let code: String
    public let message: String
    public let field: String?

    public init(code: String, message: String, field: String? = nil) {
        self.code = code
        self.message = message
        self.field = field
    }
}

// MARK: - Pagination

/// Pagination metadata
public struct Pagination: Codable, Equatable {
    public let page: Int
    public let limit: Int
    public let total: Int
    public let totalPages: Int

    public init(page: Int, limit: Int, total: Int, totalPages: Int) {
        self.page = page
        self.limit = limit
        self.total = total
        self.totalPages = totalPages
    }
}

/// Paginated response
public struct PaginatedResponse<T: Codable>: Codable {
    public let data: [T]
    public let pagination: Pagination

    public init(data: [T], pagination: Pagination) {
        self.data = data
        self.pagination = pagination
    }
}

// MARK: - Auth Models

/// Login request
public struct LoginRequest: Codable {
    public let email: String
    public let password: String

    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

/// Register request
public struct RegisterRequest: Codable {
    public let email: String
    public let password: String
    public let name: String

    public init(email: String, password: String, name: String) {
        self.email = email
        self.password = password
        self.name = name
    }
}

/// Auth response (already defined in ServiceProtocols.swift)
/// Using AuthResponse from there

// MARK: - Post Models

/// Post model
public struct Post: Codable, Identifiable, Equatable {
    public let id: String
    public let title: String
    public let content: String
    public let authorID: String
    public let authorName: String
    public let createdAt: Date
    public let updatedAt: Date
    public let likesCount: Int
    public let commentsCount: Int

    public init(
        id: String,
        title: String,
        content: String,
        authorID: String,
        authorName: String,
        createdAt: Date,
        updatedAt: Date,
        likesCount: Int = 0,
        commentsCount: Int = 0
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.authorID = authorID
        self.authorName = authorName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.likesCount = likesCount
        self.commentsCount = commentsCount
    }
}

/// Create post request
public struct CreatePostRequest: Codable {
    public let title: String
    public let content: String

    public init(title: String, content: String) {
        self.title = title
        self.content = content
    }
}

/// Update post request
public struct UpdatePostRequest: Codable {
    public let title: String?
    public let content: String?

    public init(title: String? = nil, content: String? = nil) {
        self.title = title
        self.content = content
    }
}

// MARK: - Search Models

/// Search result
public struct SearchResult: Codable, Identifiable {
    public let id: String
    public let type: SearchResultType
    public let title: String
    public let snippet: String
    public let imageURL: URL?

    public init(id: String, type: SearchResultType, title: String, snippet: String, imageURL: URL? = nil) {
        self.id = id
        self.type = type
        self.title = title
        self.snippet = snippet
        self.imageURL = imageURL
    }
}

/// Search result type
public enum SearchResultType: String, Codable {
    case post
    case user
    case tag
}

// MARK: - User Update Models

/// Update profile request
public struct UpdateProfileRequest: Codable {
    public let name: String?
    public let bio: String?
    public let website: URL?

    public init(name: String? = nil, bio: String? = nil, website: URL? = nil) {
        self.name = name
        self.bio = bio
        self.website = website
    }
}

// MARK: - Mock Data

public extension Post {
    static let mock = Post(
        id: "1",
        title: "Sample Post",
        content: "This is a sample post content",
        authorID: "123",
        authorName: "John Doe",
        createdAt: Date(),
        updatedAt: Date(),
        likesCount: 42,
        commentsCount: 12
    )

    static let mockList: [Post] = [
        Post(
            id: "1",
            title: "First Post",
            content: "Content 1",
            authorID: "123",
            authorName: "Alice",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Post(
            id: "2",
            title: "Second Post",
            content: "Content 2",
            authorID: "124",
            authorName: "Bob",
            createdAt: Date(),
            updatedAt: Date()
        ),
        Post(
            id: "3",
            title: "Third Post",
            content: "Content 3",
            authorID: "125",
            authorName: "Charlie",
            createdAt: Date(),
            updatedAt: Date()
        )
    ]
}
