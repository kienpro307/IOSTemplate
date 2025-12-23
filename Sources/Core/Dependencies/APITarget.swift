import Foundation
import Moya

// MARK: - Cấu hình API

/// Cấu hình cơ bản cho API
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

    /// Environment hiện tại
    public static var environment: APIEnvironment = .development

    /// Phiên bản API
    public static let apiVersion = "v1"

    /// Timeout cho request
    public static let timeoutInterval: TimeInterval = 30

    /// Số lần retry tối đa
    public static let maxRetryCount = 3
}

/// Cấu hình Environment cho API
public enum APIEnvironment {
    case development
    case staging
    case production
}

// MARK: - API Target

/// Các endpoint API chính sử dụng Moya TargetType
public enum APITarget {
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

    // Generic - cho các endpoint tùy chỉnh
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
        case .createPost:
            return .post
        case .updateUserProfile, .updatePost, .uploadAvatar:
            return .put
        case .deletePost:
            return .delete
        case .getUserProfile, .getPosts, .getPost, .search:
            return .get
        case .custom(_, let method, _):
            return method
        }
    }

    public var task: Moya.Task {
        switch self {
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
        let headers = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]

        return headers
    }

    public var sampleData: Data {
        // Mock data cho testing
        switch self {
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
}

// MARK: - AccessTokenAuthorizable

extension APITarget: AccessTokenAuthorizable {
    public var authorizationType: AuthorizationType? {
        // Tất cả endpoints đều cần auth (trừ khi override)
        return .bearer
    }
}

