import Foundation

/// Rebuilt only for the mutated trip; marker and list lookups never scan the library.
public nonisolated struct TripSavedPlaceIndex: Sendable {
    private var references: [String: [TripSavedPlaceReference]] = [:]
    private var tripKeys: [UUID: Set<String>] = [:]

    public init(_ plans: [TripPlan] = []) {
        for plan in plans { replace(plan) }
    }

    public func places(_ placeID: String) -> [TripSavedPlaceReference] { references[placeID] ?? [] }

    public mutating func replace(_ plan: TripPlan) {
        remove(plan.id)
        let entries = Self.entries(plan)
        tripKeys[plan.id] = Set(entries.map(\.placeID))
        for entry in entries { references[entry.placeID, default: []].append(entry) }
        for key in tripKeys[plan.id] ?? [] {
            references[key]?.sort { ($0.tripTitle, $0.dayNumber ?? .max, $0.id) < ($1.tripTitle, $1.dayNumber ?? .max, $1.id) }
        }
    }

    public mutating func remove(_ tripID: UUID) {
        for key in tripKeys.removeValue(forKey: tripID) ?? [] {
            references[key]?.removeAll { $0.tripID == tripID }
            if references[key]?.isEmpty == true { references[key] = nil }
        }
    }

    private static func entries(_ plan: TripPlan) -> [TripSavedPlaceReference] {
        let days = plan.days.flatMap { day in
            day.stops.map { TripSavedPlaceReference(trip: plan, containerID: day.id, title: "", dayNumber: day.number, stop: $0) }
        }
        let collections = plan.collections.flatMap { collection in
            collection.stops.map { TripSavedPlaceReference(trip: plan, containerID: collection.id, title: collection.title, stop: $0) }
        }
        return days + collections
    }
}
