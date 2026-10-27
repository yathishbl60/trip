import TripLocalization
import AppIntents
import CoreSpotlight
import Foundation
import TripDomain

struct SavedTripDetailEntity: IndexedEntity, Sendable {
    static var typeDisplayRepresentation: TypeDisplayRepresentation { TypeDisplayRepresentation(name: "trip_detail") }
    static var defaultQuery: SavedTripDetailQuery { SavedTripDetailQuery() }
    let id: String
    @Property(title: "name", indexingKey: \CSSearchableItemAttributeSet.title) var name: String
    @Property(title: "trip") var tripName: String
    @Property(title: "day") var day: Int
    @Property(title: "kind") var kind: String
    @Property(title: "start") var start: Date?
    @Property(title: "end") var end: Date?
    @Property(title: "location") var location: String
    private let symbol: String

    init(_ result: TripDetailResult, plan: TripSurfacePlan) {
        id = TripDetailIdentity(tripID: plan.id, itemID: result.item.id).rawValue
        symbol = result.item.symbol
        name = result.item.title
        tripName = plan.title
        day = result.day.number
        kind = result.item.kind?.title ?? TripText.place.text
        start = result.item.startsAt
        end = result.item.endsAt
        location = result.item.detail
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", subtitle: TripText.valueDayValue(tripName, TripText.number(day)).resource, image: .init(systemName: symbol))
    }

    var attributeSet: CSSearchableItemAttributeSet {
        let attributes = defaultAttributeSet
        attributes.contentDescription = [tripName, kind, location].filter { !$0.isEmpty }.joined(separator: " · ")
        attributes.startDate = start
        attributes.endDate = end
        return attributes
    }
}
