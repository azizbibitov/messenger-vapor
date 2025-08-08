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
    }
}
