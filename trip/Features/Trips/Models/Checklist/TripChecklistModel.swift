import Foundation
import Observation
import TripDomain

/// Owns checklist editing and packing review for one window's shared library.
@MainActor @Observable final class TripChecklistModel {
    let library: TripLibraryModel
    let packing: TripPackingModel
    var draft: TripChecklistDraft?
    var packingSession: TripPackingSession?
    var environment: TripChecklistEnvironment
    var hasEditingSession: Bool { draft != nil || packingSession != nil }

    init(library: TripLibraryModel, packing: TripPackingModel, environment: TripChecklistEnvironment = .init()) {
        self.library = library
        self.packing = packing
        self.environment = environment
    }

    func trip(_ tripID: UUID) -> TripPlan? { library.trip(tripID) }

    func resetPresentation() {
        draft = nil
        dismissPacking()
    }

    func dismissNaming(_ draftID: UUID?) {
        guard draft?.id == draftID else { return }
        draft = nil
    }
}

struct TripPackingSession: Identifiable {
    let id = UUID()
    let tripID: UUID
}
