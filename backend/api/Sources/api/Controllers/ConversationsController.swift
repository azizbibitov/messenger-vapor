import Vapor
import Fluent

struct ConversationsController {
    struct ConversationItem: Content {
        let id: UUID
        let name: String?
        let lastMessageAt: Date?
    }

    func list(_ req: Request) async throws -> [ConversationItem] {
        guard let user = req.auth.get(User.self), let userId = user.id else { throw Abort(.unauthorized) }

        let limit = min((try? req.query.get(Int.self, at: "limit")) ?? 20, 100)

        let conversations = try await Conversation.query(on: req.db)
            .join(Participant.self, on: \Conversation.$id == \Participant.$conversation.$id)
            .filter(Participant.self, \.$user.$id == userId)
            .sort(\.$lastMessageAt, .descending)
            .limit(limit)
            .all()

        return conversations.compactMap { c in
            guard let id = c.id else { return nil }
            return ConversationItem(id: id, name: c.name, lastMessageAt: c.lastMessageAt)
        }
    }
}

