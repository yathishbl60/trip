import Foundation
import AppIntents
import TripDomain

extension TripController {
    func openSection(_ section: TripSection, tripID: UUID) { model.openSection(section, tripID: tripID) }
    func openDayTool(_ tool: TripDayTool, dayID: UUID, tripID: UUID) {
        model.openDayTool(tool, dayID: dayID, tripID: tripID)
    }
    func editSavedDetail(_ itemID: UUID, tripID: UUID) { model.editSavedDetail(itemID, tripID: tripID) }
    func savedDetailPlace(_ itemID: UUID, tripID: UUID) -> Place? { model.savedDetailPlace(itemID, tripID: tripID) }
    func tripTitle(_ tripID: UUID) -> String { model.library.trip(tripID)?.title ?? "" }

    func tripEntityIdentifier(_ tripID: UUID) -> EntityIdentifier? {
        model.environment.tripEntityIdentifier(tripID)
    }

}
