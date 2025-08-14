import Vapor
import Fluent

final class Conversation: Model, Content, @unchecked Sendable {
    static let schema = "conversations"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String?

    @Timestamp(key: "last_message_at", on: .none)
    var lastMessageAt: Date?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() {}

    init(id: UUID? = nil, name: String? = nil, lastMessageAt: Date? = nil) {
        self.id = id
        self.name = name
        self.lastMessageAt = lastMessageAt
    }
}

