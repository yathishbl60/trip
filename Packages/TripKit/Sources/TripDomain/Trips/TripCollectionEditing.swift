import Foundation

/// Collection edits shared by manual forms and authenticated system actions.
public nonisolated enum TripCollectionEditing {
    public static func title(_ text: String) -> String? {
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (1...TripLimits.titleCharacters).contains(value.count),
              value.unicodeScalars.allSatisfy({ $0.properties.generalCategory != .control && !CharacterSet.newlines.contains($0) }) else { return nil }
        return value
    }

    public static func key(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
    }

    public static func create(_ text: String, in plan: inout TripPlan) -> UUID? {
        guard let value = title(text), plan.collections.count < TripLimits.collections else { return nil }
        let collection = TripCollection(title: value)
        plan.collections.append(collection)
        return collection.id
    }

    @discardableResult public static func rename(_ collectionID: UUID, to text: String, in plan: inout TripPlan) -> Bool {
        guard let value = title(text), let index = plan.collections.firstIndex(where: { $0.id == collectionID }) else { return false }
        plan.collections[index].title = value
        return true
    }

    @discardableResult public static func append(_ place: Place, to collection: inout TripCollection) -> Bool {
        guard TripStopAvailability(placeID: place.id, stops: collection.stops) == .available else { return false }
        collection.stops.append(TripStop(place: place))
        return true
    }
}
