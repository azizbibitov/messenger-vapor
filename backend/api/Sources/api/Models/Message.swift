import Vapor
import Fluent

final class Message: Model, Content, @unchecked Sendable {
    static let schema = "messages"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "conversation_id")
    var conversation: Conversation

    @Parent(key: "sender_id")
    var sender: User

    @Field(key: "content")
    var content: String

    @Field(key: "kind")
    var kind: String

    @Field(key: "client_id")
    var clientId: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "delivered_at", on: .none)
    var deliveredAt: Date?

    @Timestamp(key: "read_at", on: .none)
    var readAt: Date?

    init() {}

    init(id: UUID? = nil, conversationID: UUID, senderID: UUID, content: String, kind: String = "text", clientId: String) {
        self.id = id
        self.$conversation.id = conversationID
        self.$sender.id = senderID
        self.content = content
        self.kind = kind
        self.clientId = clientId
    }
}

