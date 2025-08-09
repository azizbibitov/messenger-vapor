import Vapor
import Fluent
import JWT

struct AuthRegisterRequest: Content {
    let username: String
    let password: String
}

struct AuthRegisterResponse: Content {
    let id: UUID
    let username: String
}

struct AuthLoginRequest: Content {
    let username: String
    let password: String
}

struct AuthTokenResponse: Content {
    let token: String
}

struct UserPayload: JWTPayload {
    let sub: SubjectClaim
    let exp: ExpirationClaim

    func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
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

    func login(_ req: Request) async throws -> AuthTokenResponse {
        let payload = try req.content.decode(AuthLoginRequest.self)

        guard let user = try await User.query(on: req.db)
            .filter(\.$username == payload.username)
            .first() else {
            throw Abort(.unauthorized, reason: "Invalid credentials")
        }

        let ok = try await req.password.async.verify(payload.password, created: user.passwordHash)
        guard ok else { throw Abort(.unauthorized, reason: "Invalid credentials") }

        let exp = ExpirationClaim(value: Date().addingTimeInterval(60 * 60))
        let userId = try user.requireID().uuidString
        let tokenPayload = UserPayload(sub: .init(value: userId), exp: exp)
        let token = try req.jwt.sign(tokenPayload)
        return AuthTokenResponse(token: token)
    }
}

