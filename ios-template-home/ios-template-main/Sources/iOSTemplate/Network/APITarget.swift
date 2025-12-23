import Foundation
import Moya

/// Base API configuration
public enum APIConfiguration {
    /// Base URL cho API
    public static var baseURL: URL {
        switch environment {
        case .development:
            return URL(string: "https://api-dev.example.com")!
        case .staging:
            return URL(string: "https://api-staging.example.com")!
        case .production:
            return URL(string: "https://api.example.com")!
        }
    }

    /// Current environment
    public static var environment: APIEnvironment = .development

    /// API version
    public static let apiVersion = "v1"

    /// Request timeout
    public static let timeoutInterval: TimeInterval = 30

    /// Maximum retry count
    public static let maxRetryCount = 3
}

/// API Environment configuration
public enum APIEnvironment {
    case development
    case staging
    case production
}

// MARK: - API Target

/// Main API endpoints sử dụng Moya TargetType
public enum APITarget {
    // Authentication
    case login(email: String, password: String)
    case register(email: String, password: String, name: String)
    case refreshToken(refreshToken: String)
    case logout

    // User
    case getUserProfile(userID: String)
    case updateUserProfile(userID: String, name: String)
    case uploadAvatar(userID: String, imageData: Data)

    // Content
    case getPosts(page: Int, limit: Int)
    case getPost(postID: String)
    case createPost(title: String, content: String)
    case updatePost(postID: String, title: String, content: String)
    case deletePost(postID: String)

    // Search
    case search(query: String, page: Int)

    // Generic
    case custom(path: String, method: Moya.Method, parameters: [String: Any]?)
}

// MARK: - TargetType Conformance

extension APITarget: TargetType {
    public var baseURL: URL {
        APIConfiguration.baseURL
    }

    public var path: String {
        let version = APIConfiguration.apiVersion

        switch self {
        // Auth
        case .login:
            return "/\(version)/auth/login"
        case .register:
            return "/\(version)/auth/register"
        case .refreshToken:
            return "/\(version)/auth/refresh"
        case .logout:
            return "/\(version)/auth/logout"

        // User
        case .getUserProfile(let userID):
            return "/\(version)/users/\(userID)"
        case .updateUserProfile(let userID, _):
            return "/\(version)/users/\(userID)"
        case .uploadAvatar(let userID, _):
            return "/\(version)/users/\(userID)/avatar"

        // Posts
        case .getPosts:
            return "/\(version)/posts"
        case .getPost(let postID):
            return "/\(version)/posts/\(postID)"
        case .createPost:
            return "/\(version)/posts"
        case .updatePost(let postID, _, _):
            return "/\(version)/posts/\(postID)"
        case .deletePost(let postID):
            return "/\(version)/posts/\(postID)"

        // Search
        case .search:
            return "/\(version)/search"

        // Custom
        case .custom(let path, _, _):
            return path
        }
    }

    public var method: Moya.Method {
        switch self {
        case .login, .register, .refreshToken, .createPost:
            return .post
        case .updateUserProfile, .updatePost, .uploadAvatar:
            return .put
        case .deletePost, .logout:
            return .delete
        case .getUserProfile, .getPosts, .getPost, .search:
            return .get
        case .custom(_, let method, _):
            return method
        }
    }

    public var task: Moya.Task {
        switch self {
        case .login(let email, let password):
            return .requestParameters(
                parameters: ["email": email, "password": password],
                encoding: JSONEncoding.default
            )

        case .register(let email, let password, let name):
            return .requestParameters(
                parameters: [
                    "email": email,
                    "password": password,
                    "name": name
                ],
                encoding: JSONEncoding.default
            )

        case .refreshToken(let refreshToken):
            return .requestParameters(
                parameters: ["refresh_token": refreshToken],
                encoding: JSONEncoding.default
            )

        case .updateUserProfile(_, let name):
            return .requestParameters(
                parameters: ["name": name],
                encoding: JSONEncoding.default
            )

        case .uploadAvatar(_, let imageData):
            let formData = MultipartFormData(
                provider: .data(imageData),
                name: "avatar",
                fileName: "avatar.jpg",
                mimeType: "image/jpeg"
            )
            return .uploadMultipart([formData])

        case .getPosts(let page, let limit):
            return .requestParameters(
                parameters: ["page": page, "limit": limit],
                encoding: URLEncoding.queryString
            )

        case .createPost(let title, let content):
            return .requestParameters(
                parameters: ["title": title, "content": content],
                encoding: JSONEncoding.default
            )

        case .updatePost(_, let title, let content):
            return .requestParameters(
                parameters: ["title": title, "content": content],
                encoding: JSONEncoding.default
            )

        case .search(let query, let page):
            return .requestParameters(
                parameters: ["q": query, "page": page],
                encoding: URLEncoding.queryString
            )

        case .custom(_, _, let parameters):
            if let params = parameters {
                return .requestParameters(
                    parameters: params,
                    encoding: JSONEncoding.default
                )
            }
            return .requestPlain

        default:
            return .requestPlain
        }
    }

    public var headers: [String: String]? {
        var headers = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]

        // Add auth token if available
        if let token = getAuthToken() {
            headers["Authorization"] = "Bearer \(token)"
        }

        return headers
    }

    public var sampleData: Data {
        // Mock data cho testing
        switch self {
        case .login, .register:
            return """
            {
                "access_token": "mock_access_token",
                "refresh_token": "mock_refresh_token",
                "expires_in": 3600,
                "user_id": "123"
            }
            """.data(using: .utf8)!

        case .getUserProfile:
            return """
            {
                "id": "123",
                "email": "test@example.com",
                "name": "Test User",
                "avatar_url": null
            }
            """.data(using: .utf8)!

        case .getPosts:
            return """
            {
                "data": [],
                "pagination": {
                    "page": 1,
                    "limit": 20,
                    "total": 0
                }
            }
            """.data(using: .utf8)!

        default:
            return Data()
        }
    }

    // MARK: - Helpers

    private func getAuthToken() -> String? {
        // Get token from keychain
        // TODO: Implement actual token retrieval
        return nil
    }
}

// MARK: - AccessTokenAuthorizable

extension APITarget: AccessTokenAuthorizable {
    public var authorizationType: AuthorizationType? {
        switch self {
        case .login, .register:
            return nil // No auth needed
        default:
            return .bearer // All other endpoints need auth
        }
    }
}
