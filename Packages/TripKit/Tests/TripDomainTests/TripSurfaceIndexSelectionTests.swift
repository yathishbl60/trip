import Foundation
import Testing
import TripDomain

struct TripSurfaceIndexSelectionTests {
    private let now = Date(timeIntervalSince1970: 1_791_331_200)

    @Test func departureIgnoresAnAlreadyDepartedTrackedTrip() {
        let ongoing = plan(start: now.addingTimeInterval(-86_400), zone: "UTC", days: 3)
        let future = plan(start: now.addingTimeInterval(86_400), zone: "UTC")
        let index = TripSurfaceIndex(plans: [future, ongoing], updatedAt: now)
        let journey = TripJourney(tripID: ongoing.id, dayID: ongoing.days[0].id, now: now)
        #expect(index.selectedTripID(for: .itinerary, journey: journey, at: now) == ongoing.id)
        #expect(index.selectedTripID(for: .departure, journey: journey, at: now) == future.id)
        let pastOnly = TripSurfaceIndex(plans: [ongoing], updatedAt: now)
        #expect(pastOnly.selectedTripID(for: .departure, journey: journey, at: now) == nil)
    }

    @Test func departureUsesDestinationCalendarIncludingTheWholeDepartureDay() throws {
        let zone = "Pacific/Honolulu"
        let calendar = TripLocalDate.calendar(zoneID: zone)
        let today = calendar.startOfDay(for: now)
        let trip = plan(start: today, zone: zone)
        let index = TripSurfaceIndex(plans: [trip], updatedAt: now)
        #expect(index.selectedTripID(for: .departure, journey: nil, at: now) == trip.id)
        let tomorrow = try #require(calendar.date(byAdding: .day, value: 1, to: today))
        #expect(index.nextMidnight(after: now) == tomorrow)
        #expect(index.selectedTripID(for: .departure, journey: nil, at: tomorrow) == nil)
    }

    private func plan(start: Date, zone: String, days: Int = 1) -> TripSurfacePlan {
        let calendar = TripLocalDate.calendar(zoneID: zone)
        let itinerary = (0..<days).map { offset in
            TripSurfaceDay(id: UUID(), number: offset + 1,
                           date: calendar.date(byAdding: .day, value: offset, to: start)!, stops: [], zoneID: zone)
        }
        return TripSurfacePlan(id: UUID(), title: "Sample", startDate: start, days: itinerary)
    }
}
