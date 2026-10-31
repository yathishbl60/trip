import Foundation
import TripDomain
import TripLocalization

struct TripPlanningVisit: Identifiable {
    let stop: TripStop
    let number: Int
    let entry: TripTimelineEntry?
    let bookings: [TripBookingConflict]
    let shortAllowance: Bool
    let isNew: Bool
    var id: UUID { stop.id }
    var isFixed: Bool { stop.timing.arrivalMinute != nil }
    var warnings: [TripPlanningWarning] {
        var values: [TripPlanningWarning] = []
        if let issue = entry?.arrivalIssue { values.append(.init(id: "arrival", text: issue)) }
        if let issue = entry?.conflictText { values.append(.init(id: "late", text: issue)) }
        values += bookings.map { .init(id: $0.id, text: TripText.planningBookingOverlap($0.bookingTitle).text) }
        if shortAllowance { values.append(.init(id: "allowance", text: TripText.planningRouteAllowance.text)) }
        return values
    }
}

struct TripPlacementOption: Identifiable {
    let id: Int
    let title: String
}

struct TripPlanningWarning: Identifiable {
    let id: String
    let text: String
}

struct TripPlanningMapPin: Identifiable {
    let stop: TripStop
    let number: Int
    var id: UUID { stop.id }
    var title: String { "\(number.formatted()). \(stop.place.name)" }
}
