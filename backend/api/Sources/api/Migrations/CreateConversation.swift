import Fluent
import SQLKit

struct CreateConversation: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Conversation.schema)
            .id()
            .field("name", .string)
            .field("last_message_at", .datetime)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()

        // Index last_message_at for conversation list ordering (Postgres)
        if let sql = database as? any SQLDatabase {
            try await sql.raw("CREATE INDEX IF NOT EXISTS idx_conversations_last_message_at ON \(unsafeRaw: Conversation.schema) (last_message_at)").run()
        }
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Conversation.schema).delete()
    }
}

