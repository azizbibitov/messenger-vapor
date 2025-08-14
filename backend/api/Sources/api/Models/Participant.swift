import Vapor
import Fluent

final class Participant: Model, Content, @unchecked Sendable {
    static let schema = "conversation_participants"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "conversation_id")
    var conversation: Conversation

    @Parent(key: "user_id")
    var user: User

    @Timestamp(key: "joined_at", on: .create)
    var joinedAt: Date?

    @Timestamp(key: "last_read_at", on: .none)
    var lastReadAt: Date?

    @Field(key: "unread_count")
    var unreadCount: Int

    init() {}

    init(id: UUID? = nil, conversationID: UUID, userID: UUID, joinedAt: Date? = nil) {
        self.id = id
        self.$conversation.id = conversationID
        self.$user.id = userID
        self.joinedAt = joinedAt
        self.unreadCount = 0
    }
}

