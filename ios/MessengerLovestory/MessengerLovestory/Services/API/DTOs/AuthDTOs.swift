import Foundation

struct AuthRegisterRequest: Codable {
    let username: String
    let password: String
}

struct AuthRegisterResponse: Codable {
    let id: String
    let username: String
}

struct AuthLoginRequest: Codable {
    let username: String
    let password: String
}

struct AuthTokenResponse: Codable {
    let token: String
}

struct MeResponse: Codable {
    let id: String
    let username: String
}

