import TripLocalization
import Foundation
import Observation
import TripDomain

@MainActor @Observable final class TripEventDraft: Identifiable {
    let id = UUID()
    let tripID: UUID
    let original: TripEvent?
    let originalDays: [UUID]
    let originalDate: Date
    let sourceTrip: TripPlan
    let initialEvent: TripEvent
    var event: TripEvent
    var error: String?
    var isDeleting = false
    var isDiscarding = false

    init(trip: TripPlan, dayID: UUID, event: TripEvent? = nil, kind: TripEventKind = .activity) {
        tripID = trip.id
        original = event
        originalDays = trip.days.map(\.id)
        originalDate = trip.startDate
        sourceTrip = trip
        initialEvent = event ?? TripEvent(kind: kind, title: kind == .freeTime ? kind.title : "", dayID: dayID)
        self.event = initialEvent
    }

    var title: String { "\(original == nil ? "Add" : "Edit") \(event.kind.title.lowercased())" }
    var hasChanges: Bool { event != initialEvent }
    var canSave: Bool { !event.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    var deletionMessage: String { TripText.removeThisEventFromEveryDayItAppearsOn.text }

    func set<Value>(_ value: Value, at keyPath: WritableKeyPath<TripEvent, Value>) {
        event[keyPath: keyPath] = value
        error = nil
    }

    func setText(_ value: String, at keyPath: WritableKeyPath<TripEvent, String>) {
        let limit = keyPath == \TripEvent.title ? TripLimits.titleCharacters : TripLimits.noteCharacters
        set(String(value.prefix(limit)), at: keyPath)
    }

    func issue(in trip: TripPlan) -> String? {
        guard trip.startDate == originalDate, trip.timeZoneID == sourceTrip.timeZoneID,
              trip.days.map(\.id) == originalDays else {
            return TripText.theTripSDaysChangedCancelAndReopenThis.text
        }
        guard trip.events.first(where: { $0.id == event.id }) == original else {
            return TripText.thisEventChangedElsewhereCancelAndReopenItTo.text
        }
        if original == nil, trip.events.count >= TripLimits.events { return TripText.thisTripHasReachedItsEventLimit.text }
        return event.validationIssue(in: trip)
    }

    func save(in trip: inout TripPlan) -> Bool {
        event.reviewLegacyTimes(in: trip)
        if let issue = issue(in: trip) { error = issue; return false }
        event.title = event.title.trimmingCharacters(in: .whitespacesAndNewlines)
        if let index = trip.events.firstIndex(where: { $0.id == event.id }) { trip.events[index] = event }
        else { trip.events.append(event) }
        return true
    }
}
