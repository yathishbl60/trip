import AppIntents
import Foundation
import TripDomain

struct SavedTripCollectionEntity: AppEntity, Sendable {
    static var typeDisplayRepresentation: TypeDisplayRepresentation { TypeDisplayRepresentation(name: "intent_saved_collection") }
    static var defaultQuery: SavedTripCollectionQuery { SavedTripCollectionQuery() }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    let id: String
    @Property(title: "title", description: "intent_property_collection_title") var title: String
    @Property(title: "trip", description: "intent_property_detail_trip") var tripName: String
    @Property(title: "departure_date", description: "intent_property_trip_departure") var departure: Date
    @Property(title: "time_zone", description: "intent_property_trip_zone") var timeZoneID: String
    @Property(title: "intent_collection_place_count", description: "intent_property_collection_place_count") var placeCount: Int
    @Property(title: "intent_collection_saved_places", description: "intent_property_collection_saved_places") var savedPlaceNames: String

    init(_ collection: TripCollection, plan: TripPlan) {
        id = TripCollectionIdentity(tripID: plan.id, collectionID: collection.id).rawValue
        title = collection.title
        tripName = plan.title
        departure = plan.startDate
        timeZoneID = plan.calendar.timeZone.identifier
        placeCount = collection.stops.count
        savedPlaceNames = collection.stops.prefix(TripLimits.stops).map { String($0.place.name.prefix(96)) }.joined(separator: "\n")
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)", subtitle: "\(tripName) · \(departureText)", image: .init(systemName: "square.stack"))
    }

    private var departureText: String {
        let zone = TimeZone(identifier: timeZoneID) ?? .gmt
        return departure.formatted(Date.FormatStyle(date: .abbreviated, time: .omitted, timeZone: zone))
    }
}
