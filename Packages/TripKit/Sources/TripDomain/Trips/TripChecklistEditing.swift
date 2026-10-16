import Foundation

public nonisolated enum TripChecklistEditing {
    public static func title(_ text: String) -> String? {
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (1...TripLimits.titleCharacters).contains(value.count),
              value.unicodeScalars.allSatisfy({ !CharacterSet.controlCharacters.contains($0) }) else { return nil }
        return value
    }

    public static func key(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
    }

    public static func missing(_ titles: [String], from items: [TripChecklistItem]) -> [String] {
        var seen = Set(items.map { key($0.title) })
        return titles.compactMap { text in
            guard let value = title(text), seen.insert(key(value)).inserted else { return nil }
            return value
        }
    }

    @discardableResult public static func append(_ titles: [String], to plan: inout TripPlan) -> Int {
        let space = max(0, TripLimits.checklistItems - plan.checklist.count)
        let additions = missing(titles, from: plan.checklist).prefix(space)
        plan.checklist += additions.map(TripChecklistItem.init)
        return additions.count
    }
}
