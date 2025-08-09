import Vapor
import Fluent
import JWT

struct UserJWTAuthenticator: AsyncJWTAuthenticator {
    typealias Payload = UserPayload

    func authenticate(jwt: UserPayload, for request: Request) async throws {
        guard let userId = UUID(uuidString: jwt.sub.value) else { return }
        if let user = try await User.find(userId, on: request.db) {
            request.auth.login(user)
        }
    }
}

