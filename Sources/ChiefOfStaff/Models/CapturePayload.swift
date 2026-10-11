import Foundation

public enum CaptureCategory: String, Codable, CaseIterable, Identifiable {
    case inbox = "inbox"
    case todo = "todo"
    case grocery = "grocery"
    case brainstorm = "brainstorm"
    case dailyNote = "daily_note"

    public var id: String { self.rawValue }
}

public struct CapturePayload: Codable, Identifiable {
    public let id: UUID
    public let timestamp: Date
    public var category: CaptureCategory
    public var title: String
    public var content: String
    public var tags: [String]
    public var visibility: String

    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        category: CaptureCategory = .inbox,
        title: String,
        content: String,
        tags: [String] = [],
        visibility: String = "private"
    ) {
        self.id = id
        self.timestamp = timestamp
        self.category = category
        self.title = title
        self.content = content
        self.tags = tags
        self.visibility = visibility
    }
}
