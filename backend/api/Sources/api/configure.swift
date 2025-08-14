import Vapor
import Fluent
import FluentPostgresDriver
import JWT

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Database configuration (PostgreSQL via DATABASE_URL)
    if let rawDatabaseURL = Environment.get("DATABASE_URL") {
        if var components = URLComponents(string: rawDatabaseURL) {
            let host = components.host ?? ""
            let isInternal = host.hasSuffix(".internal")
            let isLocalHost = host == "localhost" || host == "127.0.0.1" || host == "host.docker.internal"
            let hasSSLParam = (components.queryItems ?? []).contains { $0.name.lowercased() == "sslmode" }

            // Add an explicit sslmode when not provided:
            // - For local databases, disable TLS to avoid handshake errors
            // - For external hosts, require TLS (e.g., Render external connections)
            if !hasSSLParam {
                var items = components.queryItems ?? []
                let sslValue = isLocalHost ? "disable" : (isInternal ? nil : "require")
                if let sslValue {
                    items.append(URLQueryItem(name: "sslmode", value: sslValue))
                }
                components.queryItems = items
            }

            if let finalURL = components.url {
                try app.databases.use(.postgres(url: finalURL), as: .psql)
                let sslMode: String = (components.queryItems ?? []).first { $0.name.lowercased() == "sslmode" }?.value ?? "(none)"
                app.logger.notice("Configured database host=\(host) sslmode=\(sslMode)")
            } else {
                app.logger.error("Failed to construct DATABASE_URL from components; database not configured")
            }
        } else {
            app.logger.error("Invalid DATABASE_URL format; database not configured")
        }
    } else {
        app.logger.warning("DATABASE_URL not set; database not configured")
    }

    // Migrations
    app.migrations.add(CreateUser())
    app.migrations.add(CreateConversation())
    app.migrations.add(CreateParticipant())
    app.migrations.add(CreateMessage())

    // Optional: run migrations automatically on boot when enabled
    if Environment.get("AUTO_MIGRATE") == "true" {
        do {
            try await app.autoMigrate()
            app.logger.notice("AUTO_MIGRATE completed successfully")
        } catch {
            app.logger.error("AUTO_MIGRATE failed: \(error.localizedDescription)")
            throw error
        }
    }

    // Configure JWT signers (JWT 4)
    if let secret = Environment.get("JWT_SECRET") {
        app.jwt.signers.use(.hs256(key: secret))
    } else {
        app.logger.warning("JWT_SECRET not set; JWT signing will use default/none")
    }

    // Auth: register JWT authenticator happens at route grouping time

    // CORS
    let cors = CORSMiddleware(configuration: .init(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .DELETE, .OPTIONS, .PATCH],
        allowedHeaders: [
            .accept,
            .authorization,
            .contentType,
            .origin,
            .xRequestedWith
        ]
    ))
    app.middleware.use(cors)

    // Respect platform-provided PORT (e.g., Render) instead of hard-coding 8080
    if let portString = Environment.get("PORT"), let port = Int(portString) {
        app.http.server.configuration.port = port
        app.logger.notice("Server binding to PORT=\(port)")
    } else {
        app.logger.notice("PORT not set; defaulting to 8080")
    }

    // register routes
    try routes(app)
}
