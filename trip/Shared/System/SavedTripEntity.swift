import TripLocalization
import AppIntents
import CoreSpotlight
import TripDomain
import TripStorage
import Foundation
import CoreTransferable

struct SavedTripEntity: IndexedEntity, Transferable, Sendable {
    static var typeDisplayRepresentation: TypeDisplayRepresentation { TypeDisplayRepresentation(name: "trip") }
    static var defaultQuery: SavedTripQuery { SavedTripQuery() }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    let id: UUID
    @Property(title: "name", description: "intent_property_trip_name", indexingKey: \CSSearchableItemAttributeSet.title) var name: String
    @Property(title: "departure_date", description: "intent_property_trip_departure") var departure: Date
    @Property(title: "days", description: "intent_property_trip_days") var days: Int
    @Property(title: "places", description: "intent_property_trip_places") var places: Int
    @Property(title: "time_zone", description: "intent_property_trip_zone") var timeZoneID: String

    init(_ trip: TripSurfaceSummary) {
        id = trip.id
        name = trip.title
        departure = trip.startDate
        days = trip.dayCount
        places = trip.stopCount
        timeZoneID = trip.calendar.timeZone.identifier
    }

    private var dayCountText: String { TripText.dayCount(days).text }
    private var placeCountText: String { TripText.plannedPlaceCount(places).text }
    private var departureText: String {
        let zone = TimeZone(identifier: timeZoneID) ?? .gmt
        return departure.formatted(Date.FormatStyle(date: .abbreviated, time: .omitted, timeZone: zone))
    }

    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation { entity in
            "\(entity.name)\n\(entity.departureText) · \(entity.timeZoneID)\n\(entity.dayCountText) · \(entity.placeCountText)"
        }
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", subtitle: "\(departureText) · \(dayCountText)",
                              image: .init(systemName: "suitcase.rolling"))
    }

    var attributeSet: CSSearchableItemAttributeSet {
        let attributes = defaultAttributeSet
        attributes.contentDescription = "\(dayCountText) · \(placeCountText)"
        return attributes
    }
}

nonisolated struct SavedTripQuery: EntityStringQuery {
    func entities(for identifiers: [UUID]) async throws -> [SavedTripEntity] {
        let trips = try await TripSystemData.store.index()?.trips ?? []
        let byID = Dictionary(uniqueKeysWithValues: trips.map { ($0.id, $0) })
        return identifiers.compactMap { byID[$0].map(SavedTripEntity.init) }
    }

    func entities(matching string: String) async throws -> [SavedTripEntity] {
        let trips = try await TripSystemData.store.index()?.trips ?? []
        let query = PlaceSearchQuery(string)
        return trips.filter { query.matches([$0.title]) }.map(SavedTripEntity.init)
    }

    func suggestedEntities() async throws -> [SavedTripEntity] {
        let trips = try await TripSystemData.store.index()?.trips ?? []
        let now = Date.now
        return trips.filter { $0.endDate >= $0.calendar.startOfDay(for: now) }.prefix(20).map(SavedTripEntity.init)
    }
}
