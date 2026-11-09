import AppIntents
import Foundation
import TripDomain

struct SavedTripCollectionPlaceEntity: AppEntity, Sendable {
    static var typeDisplayRepresentation: TypeDisplayRepresentation { TypeDisplayRepresentation(name: "intent_collection_place") }
    static var defaultQuery: SavedTripCollectionPlaceQuery { SavedTripCollectionPlaceQuery() }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    let id: String
    @Property(title: "name", description: "intent_property_collection_place_name") var name: String
    @Property(title: "collection", description: "intent_property_collection_place_collection") var collectionName: String
    @Property(title: "trip", description: "intent_property_detail_trip") var tripName: String
    @Property(title: "departure_date", description: "intent_property_trip_departure") var departure: Date
    @Property(title: "time_zone", description: "intent_property_trip_zone") var timeZoneID: String

    init(_ stop: TripStop, collection: TripCollection, plan: TripPlan) {
        id = TripCollectionPlaceIdentity(tripID: plan.id, collectionID: collection.id, stopID: stop.id).rawValue
        name = stop.place.name
        collectionName = collection.title
        tripName = plan.title
        departure = plan.startDate
        timeZoneID = plan.calendar.timeZone.identifier
    }

    var displayRepresentation: DisplayRepresentation {
        let zone = TimeZone(identifier: timeZoneID) ?? .gmt
        let date = departure.formatted(Date.FormatStyle(date: .abbreviated, time: .omitted, timeZone: zone))
        return DisplayRepresentation(title: "\(name)", subtitle: "\(collectionName) · \(tripName) · \(date)",
                                     image: .init(systemName: "mappin"))
    }
}
