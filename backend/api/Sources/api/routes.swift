import Vapor
import Fluent

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    app.get("health") { req async -> [String: String] in
        ["status": "ok"]
    }

    let auth = AuthController()
    app.group("auth") { routes in
        routes.post("register") { req async throws -> Response in
            let res = try await auth.register(req)
            let response = Response(status: .created)
            try response.content.encode(res)
            return response
        }
        routes.post("login") { req async throws -> AuthTokenResponse in
            try await auth.login(req)
        }
    }

    // Protected route example: /me (requires Bearer token)
    let protected = app.grouped(UserJWTAuthenticator())
    protected.group("me") { me in
        me.get { req async throws -> [String: String] in
            guard let user = req.auth.get(User.self), let id = user.id else { throw Abort(.unauthorized) }
            return ["id": id.uuidString, "username": user.username]
        }
    }

    // Conversations (protected)
    let conv = ConversationsController()
    protected.group("conversations") { g in
        g.get { req async throws -> [ConversationsController.ConversationItem] in
            try await conv.list(req)
        }
    }

    // Messages (protected)
    let messages = MessagesController()
    protected.group("messages") { g in
        g.get { req async throws -> [MessagesController.MessageItem] in
            try await messages.list(req)
        }
    }
}
