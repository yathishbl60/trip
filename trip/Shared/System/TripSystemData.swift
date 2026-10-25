import TripStorage
import TripDomain
import TripRouting
import Foundation

nonisolated enum TripSystemData {
    static let appGroup = "group.com.native.trip"
    static let widgetKind = "TripItinerary"
    static let readinessWidgetKind = "TripReadiness"
    static let controlKind = "TripLauncher"
    static let store = TripSurfaceStore(appGroup: appGroup)

    static func publish(_ plans: [TripSurfacePlan], at date: Date) async throws {
        try await store.publish(plans, at: date)
    }

    static func tripURL(_ id: UUID) -> URL? { URL(string: "trip://trip/\(id.uuidString)") }
    static func checklistURL(_ id: UUID) -> URL? { URL(string: "trip://trip/\(id.uuidString)?surface=checklist") }
    static func detailURL(tripID: UUID, itemID: UUID) -> URL? {
        URL(string: "trip://trip/\(tripID.uuidString)?surface=detail&item=\(itemID.uuidString)")
    }
    static func directionsURL(_ coordinate: Coordinate) -> URL? {
        MapsDirectionsLink(destination: coordinate, mode: .automatic).url
    }
    static func journey() async throws -> TripJourney? { try await store.journey() }
    static var tripsURL: URL? { URL(string: "trip://trips") }
}
