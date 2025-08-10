import Vapor
import Fluent
import FluentPostgresDriver
import JWT

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Database configuration (PostgreSQL via DATABASE_URL)
    if let databaseURL = Environment.get("DATABASE_URL"), let url = URL(string: databaseURL) {
        try app.databases.use(.postgres(url: url), as: .psql)
    } else {
        app.logger.warning("DATABASE_URL not set; database not configured")
    }

    // Migrations
    app.migrations.add(CreateUser())

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

    // register routes
    try routes(app)
}
