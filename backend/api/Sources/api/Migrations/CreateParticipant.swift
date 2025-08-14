import Fluent
import SQLKit

struct CreateParticipant: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Participant.schema)
            .id()
            .field("conversation_id", .uuid, .required, .references(Conversation.schema, .id, onDelete: .cascade))
            .field("user_id", .uuid, .required, .references(User.schema, .id, onDelete: .cascade))
            .field("joined_at", .datetime)
            .field("last_read_at", .datetime)
            .field("unread_count", .int, .required, .sql(.default(0)))
            .unique(on: "conversation_id", "user_id")
            .create()
        // Index for quick lookup by user (Postgres)
        if let sql = database as? any SQLDatabase {
            try await sql.raw("CREATE INDEX IF NOT EXISTS idx_participants_user_id ON \(unsafeRaw: Participant.schema) (user_id)").run()
        }
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Participant.schema).delete()
    }
}

