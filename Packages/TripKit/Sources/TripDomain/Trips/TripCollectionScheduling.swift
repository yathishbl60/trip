import Foundation
import TripLocalization

public nonisolated enum TripCollectionScheduling {
    /// Copies the saved place, keeping the shortlist and an existing destination visit intact.
    public static func schedule(_ identity: TripCollectionPlaceIdentity, on dayID: UUID, in plan: inout TripPlan) throws -> UUID {
        guard let source = identity.resolve(in: plan) else { throw TripCollectionSchedulingError.missingPlace }
        guard let index = plan.days.firstIndex(where: { $0.id == dayID }) else { throw TripVisitMoveError.missingDay }
        if let existing = plan.days[index].stops.first(where: { $0.place.id == source.place.id }) { return existing.id }
        guard TripStopAvailability(placeID: source.place.id, stops: plan.days[index].stops) == .available else {
            throw TripVisitMoveError.full
        }
        let stop = TripStop(place: source.place)
        plan.days[index].stops.append(stop)
        return stop.id
    }
}

public nonisolated enum TripCollectionSchedulingError: LocalizedError, CustomLocalizedStringResourceConvertible {
    case missingPlace
    public var errorDescription: String? { String(localized: localizedStringResource) }
    public var localizedStringResource: LocalizedStringResource { TripText.collectionPlaceMissing.resource }
}
