import TripDomain
import SwiftUI

@MainActor struct TripController {
    let model: TripModel

    var placeSaveDestination: Binding<TripPlaceSaveSession?> {
        let id = model.presentation.placeSave?.id
        return Binding(get: { model.presentation.placeSave }, set: { destination in
            guard case nil = destination, let id else { return }
            model.dismissDestination(matching: id)
        })
    }

    var deletingTrip: Binding<Bool> {
        Binding(get: { model.presentation.tripToDelete != nil },
                set: { if !$0 { model.presentation.tripToDelete = nil } })
    }

    var deletingDay: Binding<Bool> {
        Binding(get: { model.presentation.dayToDelete != nil },
                set: { if !$0 { model.presentation.dayToDelete = nil } })
    }

    func load() async { await model.library.load() }
    func chooseDestination(for place: Place) { model.chooseDestination(for: place) }
    func dismissDestination() { model.dismissDestination() }
    func beginCreate() { model.beginCreate() }
    func beginCreate(saving place: Place) { model.beginCreate(saving: place) }
    func beginEdit(_ id: UUID) { model.beginEdit(id) }
    func requestDelete(_ id: UUID) { model.presentation.tripToDelete = id }
    func confirmDelete() { model.deleteTrip() }
    func requestDayDelete(_ id: UUID) { model.presentation.dayToDelete = id }
    func confirmDayDelete(from id: UUID) { model.deleteDay(from: id) }
    func addDay(to id: UUID) { model.addDay(to: id) }
    func save(_ place: Place, to tripID: UUID, dayID: UUID) {
        if model.add(place, to: tripID, dayID: dayID) { dismissDestination() }
    }
    func showOnMap(_ place: Place) {
        model.environment.showPlace(place)
    }
}
