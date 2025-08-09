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

    // Configure JWT signers (JWT 4)
    if let secret = Environment.get("JWT_SECRET") {
        app.jwt.signers.use(.hs256(key: secret))
    } else {
        app.logger.warning("JWT_SECRET not set; JWT signing will use default/none")
    }

    // register routes
    try routes(app)
}
