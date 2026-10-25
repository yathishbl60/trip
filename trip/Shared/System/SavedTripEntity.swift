import TripLocalization
import AppIntents
import CoreSpotlight
import TripDomain
import TripStorage
import Foundation

struct SavedTripEntity: IndexedEntity, Sendable {
    static var typeDisplayRepresentation: TypeDisplayRepresentation { TypeDisplayRepresentation(name: "trip") }
    static var defaultQuery: SavedTripQuery { SavedTripQuery() }
    let id: UUID
    @Property(title: "name", indexingKey: \CSSearchableItemAttributeSet.title) var name: String
    @Property(title: "departure_date") var departure: Date
    @Property(title: "days") var days: Int
    @Property(title: "places") var places: Int

    init(_ trip: TripSurfaceSummary) {
        id = trip.id
        name = trip.title
        departure = trip.startDate
        days = trip.dayCount
        places = trip.stopCount
    }

    private var dayCountText: String { TripText.dayCount(days).text }
    private var placeCountText: String { TripText.plannedPlaceCount(places).text }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", subtitle: "\(departure.formatted(date: .abbreviated, time: .omitted)) · \(dayCountText)",
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
        let today = Calendar.current.startOfDay(for: .now)
        return trips.filter { $0.endDate >= today }.prefix(20).map(SavedTripEntity.init)
    }
}
