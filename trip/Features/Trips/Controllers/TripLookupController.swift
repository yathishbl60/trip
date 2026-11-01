import Foundation
import SwiftUI
import TripDomain

struct TripLookupController {
    let model: TripLookupModel

    var question: Binding<String> { Binding(get: { model.question }, set: model.setQuestion) }
    var searchText: Binding<String> { Binding(get: { model.searchText }, set: model.setSearchText) }
    var processing: Binding<TripAIProcessing> { Binding(get: { model.processing }, set: model.setProcessing) }
    func ask() { model.ask() }
    func cancel() { model.cancel() }
    func refreshAvailability() { model.refreshAvailability() }
    func sceneChanged(_ phase: ScenePhase) {
        if phase == .active { model.refreshAvailability() }
        else { model.cancel() }
    }
    func choose(_ category: TripDetailCategory) { model.choose(category) }
    func chooseDay(_ number: Int?) { model.chooseDay(number) }
    func resetFilters() { model.resetFilters() }
}
