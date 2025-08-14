import Fluent
import SQLKit

struct CreateMessage: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Message.schema)
            .id()
            .field("conversation_id", .uuid, .required, .references(Conversation.schema, .id, onDelete: .cascade))
            .field("sender_id", .uuid, .required, .references(User.schema, .id, onDelete: .cascade))
            .field("content", .string, .required)
            .field("kind", .string, .required)
            .field("client_id", .string, .required)
            .field("created_at", .datetime)
            .field("delivered_at", .datetime)
            .field("read_at", .datetime)
            .unique(on: "conversation_id", "client_id")
            .create()

        // Composite index to support keyset pagination (Postgres)
        if let sql = database as? any SQLDatabase {
            try await sql.raw("CREATE INDEX IF NOT EXISTS idx_messages_conv_created_id ON \(unsafeRaw: Message.schema) (conversation_id, created_at, id)").run()
        }
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Message.schema).delete()
    }
}

