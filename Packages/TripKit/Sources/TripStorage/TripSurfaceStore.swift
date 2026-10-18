#if !TRIP_STANDALONE
import TripLocalization
#endif
import TripDomain
import Foundation

/// A small index and per-trip projections; widgets never open the SwiftData database.
public actor TripSurfaceStore {
    let appGroup: String
    private var lastPublication = Date.distantPast
    private var published: [UUID: TripSurfacePlan] = [:]

    public init(appGroup: String) { self.appGroup = appGroup }

    public func index() throws -> TripSurfaceIndex? { try read("index.json") }
    public func plan(_ id: UUID) throws -> TripSurfacePlan? { try read("\(id).json") }
    public func journey() throws -> TripJourney? { try read("journey.json") }
    public func saveJourney(_ journey: TripJourney) throws { try write(journey, to: "journey.json") }

    public func publish(_ plans: [TripSurfacePlan], at date: Date) throws {
        guard date >= lastPublication else { return }
        let previous = try index()?.trips.map(\.id) ?? []
        for plan in plans where published[plan.id] != plan { try write(plan, to: "\(plan.id).json") }
        try write(TripSurfaceIndex(plans: plans, updatedAt: date), to: "index.json")
        let retained = Set(plans.map(\.id))
        for id in previous where !retained.contains(id) {
            let url = try folder().appending(path: "\(id).json")
            if FileManager.default.fileExists(atPath: url.path) { try FileManager.default.removeItem(at: url) }
        }
        published = Dictionary(uniqueKeysWithValues: plans.map { ($0.id, $0) })
        lastPublication = date
    }

    func folder() throws -> URL {
        guard let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            throw TripSurfaceError.unavailable
        }
        let directory = container.appending(path: "TripSurfaces", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    func read<Value: Decodable>(_ name: String) throws -> Value? {
        let url = try folder().appending(path: name)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return try JSONDecoder().decode(Value.self, from: Data(contentsOf: url))
    }

    func write<Value: Encodable>(_ value: Value, to name: String) throws {
        let data = try JSONEncoder().encode(value)
        try data.write(to: folder().appending(path: name), options: protection)
    }

    private var protection: Data.WritingOptions {
        #if os(iOS)
        [.atomic, .completeFileProtectionUntilFirstUserAuthentication]
        #else
        .atomic
        #endif
    }
}

public nonisolated enum TripSurfaceError: LocalizedError {
    case unavailable, noJourney, missingTrip, missingDay, finishedDay

    public var errorDescription: String? {
        switch self {
        case .unavailable: TripText.tripSSystemFeaturesAreUnavailableOpenTripAnd.text
        case .noJourney: TripText.startTrackingADayInTripFirst.text
        case .missingTrip: TripText.thisTripIsNoLongerAvailable.text
        case .missingDay: TripText.thisDayIsNoLongerAvailable.text
        case .finishedDay: TripText.allPlacesVisited2.text
        }
    }
}
