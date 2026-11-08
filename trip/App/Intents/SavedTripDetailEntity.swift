import TripLocalization
import AppIntents
import CoreSpotlight
import Foundation
import TripDomain
import CoreTransferable

struct SavedTripDetailEntity: IndexedEntity, Transferable, Sendable {
    static var typeDisplayRepresentation: TypeDisplayRepresentation { TypeDisplayRepresentation(name: "trip_detail") }
    static var defaultQuery: SavedTripDetailQuery { SavedTripDetailQuery() }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    let id: String
    @Property(title: "name", description: "intent_property_detail_name", indexingKey: \CSSearchableItemAttributeSet.title) var name: String
    @Property(title: "trip", description: "intent_property_detail_trip") var tripName: String
    @Property(title: "day", description: "intent_property_detail_day") var day: Int
    @Property(title: "kind", description: "intent_property_detail_kind") var kind: String
    @Property(title: "start", description: "intent_property_detail_start") var start: Date?
    @Property(title: "end", description: "intent_property_detail_end") var end: Date?
    @Property(title: "location", description: "intent_property_detail_location") var location: String
    @Property(title: "time_zone", description: "intent_property_detail_zone") var timeZoneID: String
    @Property(title: "intent_saved_times", description: "intent_property_detail_times") var savedTimes: String
    @Property(title: "visit_duration", description: "intent_property_saved_visit_minutes") var visitMinutes: Int?
    @Property(title: "travel_time", description: "intent_property_saved_travel_minutes") var travelMinutes: Int?
    @Property(title: "buffer", description: "intent_property_saved_buffer_minutes") var bufferMinutes: Int?
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
        timeZoneID = result.item.startZoneID ?? result.day.calendar.timeZone.identifier
        savedTimes = result.item.timeText
        let stop = result.item.kind == nil ? result.day.stops.first(where: { $0.id == result.id }) : nil
        visitMinutes = stop?.visitMinutes
        travelMinutes = stop?.travelMinutes
        bufferMinutes = stop?.bufferMinutes
    }

    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation { entity in
            [entity.name, entity.tripName, entity.savedTimes, entity.location].filter { !$0.isEmpty }.joined(separator: "\n")
        }
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
