import Foundation

/// Matches every word across searchable fields while preserving a readable service query.
public nonisolated struct PlaceSearchQuery: Sendable {
    public let text: String
    private let words: [String]

    public init(_ text: String) {
        self.text = text.split(whereSeparator: \.isWhitespace).joined(separator: " ")
        words = Self.fold(text).split(separator: " ").map(String.init)
    }

    public var isEmpty: Bool { text.isEmpty }

    public func matches(_ fields: [String]) -> Bool {
        guard !words.isEmpty else { return isEmpty }
        let fields = fields.map(Self.fold)
        return words.allSatisfy { word in fields.contains { $0.contains(word) } }
    }

    public func places(in places: [Place]) -> [Place] {
        guard !isEmpty else { return places }
        var ranked: [(index: Int, place: Place, score: Int)] = []
        for (index, place) in places.enumerated() where matches(place.searchFields) {
            ranked.append((index, place, rank(place.name)))
        }
        ranked.sort {
            $0.score == $1.score ? $0.index < $1.index : $0.score < $1.score
        }
        return ranked.map { $0.place }
    }

    private func rank(_ name: String) -> Int {
        let name = Self.fold(name)
        let phrase = words.joined(separator: " ")
        if name == phrase { return 0 }
        if name.hasPrefix(phrase) { return 1 }
        return words.allSatisfy { name.contains($0) } ? 2 : 3
    }

    private static func fold(_ text: String) -> String {
        let folded = text.folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: .current)
        return folded.split { !$0.isLetter && !$0.isNumber }.joined(separator: " ")
    }
}

nonisolated extension Place {
    public var searchFields: [String] { [name, address ?? "", category.title] }
}
