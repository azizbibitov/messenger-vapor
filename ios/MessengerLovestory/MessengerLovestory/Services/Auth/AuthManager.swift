import Foundation

final class AuthManager {
    static let shared = AuthManager()
    private init() {}

    var token: String? { KeychainStorage.getToken() }

    func save(token: String) { KeychainStorage.setToken(token) }
    func logout() { KeychainStorage.removeToken() }
}

