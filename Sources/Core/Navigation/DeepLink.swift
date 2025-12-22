import Foundation

/// Deep link handling cho app - CHỈ COMMON LINKS
public enum DeepLink: Equatable {
    case settings
    case about
    case privacyPolicy
    case termsOfService
    case webView(url: URL)
    
    /// Parse URL thành DeepLink
    /// Format: myapp://settings, myapp://about, etc.
    public init?(url: URL) {
        // Kiểm tra scheme (có thể customize per app)
        guard url.scheme == "myapp" || url.scheme == "iostemplate" else {
            return nil
        }
        
        let host = url.host ?? ""
        
        switch host {
        case "settings":
            // myapp://settings
            self = .settings
            
        case "about":
            // myapp://about
            self = .about
            
        case "privacy":
            // myapp://privacy
            self = .privacyPolicy
            
        case "terms":
            // myapp://terms
            self = .termsOfService
            
        case "web":
            // myapp://web?url=https://example.com
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                  let urlString = components.queryItems?.first(where: { $0.name == "url" })?.value,
                  let webURL = URL(string: urlString) else {
                return nil
            }
            self = .webView(url: webURL)
            
        default:
            return nil
        }
    }
    
    /// Convert DeepLink thành Destination
    public func toDestination() -> Destination? {
        switch self {
        case .settings:
            return .settings
        case .about:
            return .about
        case .privacyPolicy:
            return .privacyPolicy
        case .termsOfService:
            return .termsOfService
        case .webView(let url):
            return .webView(url: url, title: nil)
        }
    }
}
