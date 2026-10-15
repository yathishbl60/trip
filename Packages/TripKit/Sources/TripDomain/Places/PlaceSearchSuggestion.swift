import Foundation

/// Display-only suggestion; resolve its native completion before creating a place.
public nonisolated struct PlaceSearchSuggestion: Identifiable, Sendable, Equatable {
    public let title: String
    public let subtitle: String
    public var id: String { title + "\u{1F}" + subtitle }

    public init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }
}
