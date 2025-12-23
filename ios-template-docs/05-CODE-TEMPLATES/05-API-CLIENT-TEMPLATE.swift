// MARK: - [Name]Endpoints.swift
// Template cho Moya API Endpoints - Code tiếng Anh, comment tiếng Việt

import Foundation
import Moya

/// Định nghĩa các endpoint của API
enum ItemEndpoint {
    case fetchItems(page: Int, limit: Int)
    case fetchItem(id: String)
    case createItem(CreateItemRequest)
    case updateItem(id: String, UpdateItemRequest)
    case deleteItem(id: String)
}

extension ItemEndpoint: TargetType {
    var baseURL: URL {
        URL(string: "https://api.example.com/v1")!
    }
    
    var path: String {
        switch self {
        case .fetchItems:
            return "/items"
        case .fetchItem(let id):
            return "/items/\(id)"
        case .createItem:
            return "/items"
        case .updateItem(let id, _):
            return "/items/\(id)"
        case .deleteItem(let id):
            return "/items/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchItems, .fetchItem:
            return .get
        case .createItem:
            return .post
        case .updateItem:
            return .put
        case .deleteItem:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .fetchItems(let page, let limit):
            return .requestParameters(
                parameters: ["page": page, "limit": limit],
                encoding: URLEncoding.queryString
            )
        case .fetchItem, .deleteItem:
            return .requestPlain
        case .createItem(let request):
            return .requestJSONEncodable(request)
        case .updateItem(_, let request):
            return .requestJSONEncodable(request)
        }
    }
    
    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
}

// MARK: - Request Models
struct CreateItemRequest: Encodable {
    let name: String
    let description: String
}

struct UpdateItemRequest: Encodable {
    let name: String?
    let description: String?
}
