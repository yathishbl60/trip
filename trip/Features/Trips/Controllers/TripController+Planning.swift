import Foundation
import SwiftUI
import TripDomain
import TripRouting

extension TripController {
    func planning(savingPlace: Bool) -> Binding<TripPlanningDraft?> {
        let id = model.presentation.planning?.id
        return Binding(get: {
            guard model.presentation.planning?.isInsertion == savingPlace else { return nil }
            return model.presentation.planning
        }, set: { value in
            if value == nil, let id { model.closePlanning(id) }
        })
    }

    func beginPlanning(dayID: UUID, tripID: UUID) { model.beginPlanning(dayID: dayID, tripID: tripID) }
    func reviewPlacement(_ place: Place, dayID: UUID, tripID: UUID) {
        model.reviewPlacement(place, dayID: dayID, tripID: tripID)
    }
    func closePlanning(_ draft: TripPlanningDraft) { model.closePlanning(draft.id) }
    func applyPlanning(_ draft: TripPlanningDraft) { model.applyPlanning(draft) }
    func restorePlanning(_ draft: TripPlanningDraft) { draft.reset() }
    func movePlanning(_ offsets: IndexSet, to destination: Int, draft: TripPlanningDraft) {
        draft.move(offsets, to: destination)
    }
    func refreshPlanning(_ draft: TripPlanningDraft) async { await draft.refreshRoutes() }
    func retryPlanning(_ draft: TripPlanningDraft) { draft.retryRoutes() }
    func suspendPlanning(_ draft: TripPlanningDraft) { draft.routes.invalidate() }
    func planningPosition(_ draft: TripPlanningDraft) -> Binding<Int> {
        Binding(get: { draft.placementIndex }, set: draft.setPlacement)
    }
    func planningMode(_ draft: TripPlanningDraft) -> Binding<TravelMode> {
        Binding(get: { draft.routes.mode }, set: draft.routes.selectMode)
    }
}
