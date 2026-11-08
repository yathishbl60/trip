#if os(iOS) || os(visionOS)
import Testing
import SwiftUI
import TripDomain
@testable import TripRouting

@MainActor struct DirectionsNavigationTests {
    @Test func backFromStandaloneSearchCancelsWorkAndKeepsTheRoute() {
        let model = DirectionsModel()
        let destination = place("destination")
        model.destination = destination
        model.changeOrigin()
        model.stopSearch.isLoading = true
        let generation = model.stopSearch.generation
        let controller = DirectionsController(model: model)
        #expect(controller.editingRoute.wrappedValue)
        controller.editingRoute.wrappedValue = false
        #expect(model.destination == destination && model.startingPoint.place == nil)
        #expect(model.presentation.placePicker == nil && model.presentation.auxiliary == nil)
        #expect(!model.stopSearch.isLoading && model.stopSearch.generation > generation)
    }

    @Test func choosingAnOriginReturnsToTheStopListAndBackReturnsToDirections() throws {
        let model = DirectionsModel()
        let controller = DirectionsController(model: model)
        controller.editStops()
        let editorID = model.presentation.auxiliary?.id
        controller.changeOrigin()
        let picker = try #require(model.presentation.placePicker)
        let origin = place("origin")
        model.stopSearch.results = [origin]
        controller.choosePlace(origin, session: picker)
        #expect(model.startingPoint.place == origin)
        #expect(!controller.choosingPlace.wrappedValue && controller.editingRoute.wrappedValue)
        #expect(model.presentation.auxiliary?.id == editorID)
        controller.editingRoute.wrappedValue = false
        #expect(model.presentation.auxiliary == nil && model.startingPoint.place == origin)
    }

    @Test func lateBackAndPopoverDismissalDoNotCloseANewerEdit() {
        let model = DirectionsModel()
        let controller = DirectionsController(model: model)
        controller.showOptions()
        let oldOptions = controller.options
        controller.editStops()
        let oldEditor = controller.editingRoute
        controller.changeOrigin()
        let oldPicker = controller.choosingPlace
        controller.editStops()
        controller.beginAddingStop()
        let currentPicker = model.presentation.placePicker?.id
        oldOptions.wrappedValue = false
        oldEditor.wrappedValue = false
        oldPicker.wrappedValue = false
        #expect(controller.editingRoute.wrappedValue && controller.choosingPlace.wrappedValue)
        #expect(model.presentation.placePicker?.id == currentPicker)
        #expect(!controller.options.wrappedValue)
    }

    private func place(_ id: String) -> Place {
        Place(id: id, name: id, coordinate: .bangkok, category: .shopping,
              importance: 1, rating: nil, reviews: nil)
    }
}
#endif
