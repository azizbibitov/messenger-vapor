import Vapor
import Fluent

struct MessagesController {
    struct MessageItem: Content {
        let id: UUID
        let conversationId: UUID
        let senderId: UUID
        let content: String
        let kind: String
        let createdAt: Date?
        let deliveredAt: Date?
        let readAt: Date?
        let clientId: String
    }

    func list(_ req: Request) async throws -> [MessageItem] {
        // Auth
        guard let user = req.auth.get(User.self), let userId = user.id else {
            throw Abort(.unauthorized)
        }

        // Query params
        guard let conversationId = try? req.query.get(UUID.self, at: "conversationId") else {
            throw Abort(.badRequest, reason: "Missing conversationId")
        }
        let limit = min((try? req.query.get(Int.self, at: "limit")) ?? 50, 200)
        let beforeDate: Date? = try? req.query.get(Date.self, at: "beforeCreatedAt")

        // Membership check
        guard try await Participant.query(on: req.db)
            .filter(\.$conversation.$id == conversationId)
            .filter(\.$user.$id == userId)
            .first() != nil else {
            throw Abort(.forbidden, reason: "Not a participant of this conversation")
        }

        // Build query with keyset-friendly ordering and optional cursor
        let query = Message.query(on: req.db)
            .filter(\.$conversation.$id == conversationId)
            .sort(\.$createdAt, .descending)
            .sort(\.$id, .descending)

        if let beforeDate {
            query.filter(\.$createdAt < beforeDate)
        }

        let rows = try await query.limit(limit).all()

        return rows.compactMap { m in
            guard
                let id = m.id,
                let convId = try? m.$conversation.id,
                let senderId = try? m.$sender.id
            else { return nil }
            return MessageItem(
                id: id,
                conversationId: convId,
                senderId: senderId,
                content: m.content,
                kind: m.kind,
                createdAt: m.createdAt,
                deliveredAt: m.deliveredAt,
                readAt: m.readAt,
                clientId: m.clientId
            )
        }
    }
}

