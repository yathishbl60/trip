import Foundation
import Observation
import TripDomain
import TripLocalization

/// An isolated proposal. Only Apply writes through the shared library.
@MainActor @Observable final class TripPlanningDraft: Identifiable, TripDiscardableDraft {
    let id = UUID()
    let trip: TripPlan
    let original: TripDay
    let addedStopID: UUID?
    let routes: TripPlanningRoutes
    private(set) var day: TripDay
    private(set) var revision = 0
    private(set) var placementIndex: Int
    private let initialPlacementIndex: Int
    var notice: String?
    var isDiscarding = false

    init(trip: TripPlan, day: TripDay, place: Place? = nil, index: Int? = nil,
         routes: TripPlanningRoutes = TripPlanningRoutes()) {
        self.routes = routes
        self.trip = trip
        original = day
        var proposal = day
        proposal.itemOrder = trip.journeyItems(on: day).map(\.id)
        let stop = place.map(TripStop.init)
        addedStopID = stop?.id
        if let stop { Self.insert(stop, at: index ?? day.stops.count, into: &proposal) }
        initialPlacementIndex = min(max(index ?? day.stops.count, 0), day.stops.count)
        placementIndex = initialPlacementIndex
        self.day = proposal
        routes.prepare(proposal.stops)
    }

    var isInsertion: Bool { addedStopID != nil }
    var hasChanges: Bool { day.stops != original.stops }
    var hasUnsavedChanges: Bool { isInsertion ? placementIndex != initialPlacementIndex : hasChanges }
    var timeline: TripDayTimeline? {
        guard !trip.needsTimeZoneReview else { return nil }
        return TripDayTimeline(day: day, date: trip.date(for: original), calendar: trip.calendar)
    }
    var conflicts: [TripBookingConflict] { TripBookingConflict.find(in: trip, timeline: timeline) }
    var bookings: [TripEvent] { trip.events.filter { $0.occurs(on: day.id, in: trip) } }
    var mappedStops: [TripStop] { day.stops.filter { $0.place.coordinate.isValid } }

    func move(_ offsets: IndexSet, to destination: Int) {
        guard !isInsertion,
              let edit = IdentifiedListEdit.moving(offsets, to: destination, in: day.stops.map(\.id)) else { return }
        var proposed = day.stops
        guard edit.apply(to: &proposed) else { return }
        guard TripDayReordering.move(offsets, to: destination, in: &day) else {
            notice = TripText.planningFixedOrder.text
            return
        }
        notice = nil
        revision += 1
        routes.prepare(day.stops)
    }

    func setPlacement(_ index: Int) {
        guard (0...original.stops.count).contains(index), index != placementIndex,
              let stop = day.stops.first(where: { $0.id == addedStopID }) else { return }
        placementIndex = index
        day = original
        day.itemOrder = trip.journeyItems(on: original).map(\.id)
        Self.insert(stop, at: index, into: &day)
        notice = nil
        revision += 1
        routes.prepare(day.stops)
    }

    func retryRoutes() {
        routes.refreshCache()
        revision += 1
    }

    func reset() {
        guard !isInsertion else { return }
        day = original
        day.itemOrder = trip.journeyItems(on: original).map(\.id)
        notice = nil
        revision += 1
        routes.prepare(day.stops)
    }

    static func insert(_ stop: TripStop, at index: Int, into day: inout TripDay) {
        let position = min(max(index, 0), day.stops.count)
        let nextID = position < day.stops.count ? day.stops[position].id : nil
        let slot = nextID.flatMap { day.itemOrder.firstIndex(of: $0) } ?? day.itemOrder.count
        day.stops.insert(stop, at: position)
        day.itemOrder.insert(stop.id, at: slot)
    }
}
