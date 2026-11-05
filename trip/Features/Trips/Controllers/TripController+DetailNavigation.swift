import Foundation
import SwiftUI
import TripDomain
import AppIntents

extension TripController {
    func openDetail(_ destination: TripDetailRoute.Destination, tripID: UUID) {
        model.openDetail(destination, tripID: tripID)
    }

    func openLookup(_ tripID: UUID, question: String = "") {
        model.openLookup(tripID, question: question)
    }

    func lookupSnapshot(_ tripID: UUID) -> TripSurfacePlan? { model.lookupSnapshot(tripID) }

    func detailEntityIdentifier(tripID: UUID, itemID: UUID) -> EntityIdentifier? {
        model.environment.detailEntityIdentifier(TripDetailIdentity(tripID: tripID, itemID: itemID))
    }

    func detailRoute(for tripID: UUID) -> Binding<TripDetailRoute?> {
        let presented = model.presentation.detailRoute
        return Binding(get: {
            guard model.presentation.detailRoute?.tripID == tripID else { return nil }
            return model.presentation.detailRoute
        }, set: { value in
            if value == nil, presented?.tripID == tripID { model.dismissDetail(presented) }
        })
    }
}
