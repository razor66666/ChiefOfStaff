import SwiftUI

/// Represents a configurable council/agent persona for the executive dashboard.
public struct PersonaConfig: Identifiable, Codable, Equatable {
    public let id: String
    public let name: String
    public let role: String
    public let iconName: String
    public let colorHex: String
    public var metricCount: Int
    public let metricLabel: String

    public init(id: String, name: String, role: String, iconName: String, colorHex: String, metricCount: Int, metricLabel: String) {
        self.id = id
        self.name = name
        self.role = role
        self.iconName = iconName
        self.colorHex = colorHex
        self.metricCount = metricCount
        self.metricLabel = metricLabel
    }

    /// Converts hex string to SwiftUI Color with safe fallback
    public var themeColor: Color {
        switch colorHex.lowercased() {
        case "red": return .red
        case "orange": return .orange
        case "purple": return .purple
        case "blue": return .blue
        case "green": return .green
        default: return .gray
        }
    }
}