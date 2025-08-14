import Foundation

final class APIClient {
    static let shared = APIClient()
    private init() {}

    private var baseURL: URL { AppEnvironment.baseURL }

    func register(username: String, password: String) async throws -> AuthRegisterResponse {
        let req = AuthRegisterRequest(username: username, password: password)
        return try await post("/auth/register", body: req)
    }

    func login(username: String, password: String) async throws -> AuthTokenResponse {
        let req = AuthLoginRequest(username: username, password: password)
        return try await post("/auth/login", body: req)
    }

    func me(token: String) async throws -> MeResponse {
        var request = URLRequest(url: baseURL.appendingPathComponent("/me"))
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { throw URLError(.badServerResponse) }
        return try JSONDecoder().decode(MeResponse.self, from: data)
    }

    // MARK: - Internal
    private func post<T: Encodable, U: Decodable>(_ path: String, body: T) async throws -> U {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        debugPrint(response)
        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        switch http.statusCode {
        case 200, 201:
            return try JSONDecoder().decode(U.self, from: data)
        case 400...499:
            throw APIError.client(status: http.statusCode, message: String(data: data, encoding: .utf8))
        default:
            throw APIError.server(status: http.statusCode)
        }
    }
}

enum APIError: Error {
    case client(status: Int, message: String?)
    case server(status: Int)
}

