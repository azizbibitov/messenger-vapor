import Foundation

enum AppEnvironment {
    #if DEBUG
    static let baseURL: URL = URL(string: "http://localhost:8080")!
    #else
    static let baseURL: URL = URL(string: "https://example.com")! // replace on deploy
    #endif
}

