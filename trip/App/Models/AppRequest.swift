import Foundation
import TripDomain

/// A transient request chooses either a screen or a feature-owned workflow.
nonisolated struct AppRequest: Hashable {
    enum Operation: Hashable {
        case destination(AppDestination)
        case workflow(AppWorkflowRequest)
    }

    let operation: Operation
    static let explore = Self(operation: .destination(.explore))
    static let trips = Self(operation: .destination(.trips))

    static func savedTrip(_ id: UUID) -> Self { Self(operation: .destination(.savedTrip(id))) }
    static func savedDetail(_ identity: TripDetailIdentity) -> Self { Self(operation: .destination(.detail(identity))) }
    static func savedCollection(_ identity: TripCollectionIdentity) -> Self { Self(operation: .destination(.collection(identity))) }
    static func section(_ id: UUID, _ section: TripSection) -> Self {
        Self(operation: .destination(.section(id, section)))
    }

    var requiresLibrary: Bool {
        switch operation {
        case .destination(.explore), .destination(.trips): false
        case .destination(.savedTrip), .destination(.detail), .destination(.section),
             .destination(.collection), .destination(.linkedDetail), .destination(.restoration), .workflow: true
        }
    }
}

nonisolated enum AppDestination: Hashable {
    case explore, trips, savedTrip(UUID), detail(TripDetailIdentity), section(UUID, TripSection)
    case linkedDetail(UUID, UUID?), restoration(AppRestoration)
    case collection(TripCollectionIdentity)
}

nonisolated struct AppRestoration: Hashable {
    let tab: AppTab
    let tripID: UUID?
    let opensTrip: Bool
}
