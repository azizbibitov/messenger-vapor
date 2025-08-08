import Vapor
import Fluent

struct AuthRegisterRequest: Content {
    let username: String
    let password: String
}

struct AuthRegisterResponse: Content {
    let id: UUID
    let username: String
}

final class AuthController: @unchecked Sendable {
    func register(_ req: Request) async throws -> AuthRegisterResponse {
        let payload = try req.content.decode(AuthRegisterRequest.self)

        // Check unique username
        if try await User.query(on: req.db).filter(\.$username == payload.username).first() != nil {
            throw Abort(.conflict, reason: "Username is already taken")
        }

        let hash = try await req.password.async.hash(payload.password)
        let user = User(username: payload.username, passwordHash: hash)
        try await user.save(on: req.db)

        let id = try user.requireID()
        return AuthRegisterResponse(id: id, username: user.username)
    }
}

