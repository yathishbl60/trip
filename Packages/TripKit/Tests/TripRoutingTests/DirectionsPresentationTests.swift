#if os(iOS) || os(visionOS)
import Testing
import SwiftUI
import TripDomain
import MapKit
@testable import TripRouting

@MainActor struct DirectionsPresentationTests {
    @Test func stepsKeepTheirNavigationDuringCollapseAndRejectLateBackAndHandoff() {
        let model = routeWithSteps()
        let controller = DirectionsController(model: model)
        controller.showSteps()
        let previous = controller.readingSteps
        var handoffs: [Bool] = []
        let complete = model.mapsHandoffCompletion { handoffs.append($0) }
        model.presentation.detent = model.presentation.compact
        #expect(previous.wrappedValue && model.presentation.auxiliary == nil)
        previous.wrappedValue = false
        controller.showSteps()
        previous.wrappedValue = false
        complete(false)
        #expect(controller.readingSteps.wrappedValue && handoffs.isEmpty)
        model.clearResults()
        #expect(!controller.readingSteps.wrappedValue)
    }

    private func routeWithSteps() -> DirectionsModel {
        let model = DirectionsModel()
        let place = Place(id: "destination", name: "Market", coordinate: .bangkok, category: .shopping,
                          importance: 1, rating: nil, reviews: nil)
        let coordinates = [Coordinate(latitude: 13.74, longitude: 100.52).location, place.coordinate.location]
        let route = DirectionsRoute(name: "Local route", estimate: .init(travelTime: 60, distance: 300, arrival: .now),
                                    polyline: MKPolyline(coordinates: coordinates, count: coordinates.count),
                                    steps: [.init(id: 0, instruction: "Continue straight", distance: 300)],
                                    notices: [], hasTolls: false, hasHighways: false)
        model.destination = place
        model.routes = [route]
        model.setSelectedRoute(route.id)
        return model
    }

    @Test func replacingARouteAtIdenticalBoundsRejectsMeasurementsFromThePreviousSession() {
        let place = Place(id: "market", name: "Market", coordinate: .bangkok, category: .shopping,
                          importance: 1, rating: nil, reviews: nil)
        var frames: [CGRect] = []
        let model = DirectionsModel(environment: DirectionsEnvironment(sheetFrameChanged: { frames.append($0) }))
        let controller = DirectionsController(model: model)
        let frame = CGRect(x: 16, y: 24, width: 320, height: 480)
        model.begin(place, origin: nil)
        let first = DirectionsPanelMeasurement(frame: frame, destinationID: place.id, session: model.presentation.session)
        model.beginItinerary([place], origin: nil)
        let next = DirectionsPanelMeasurement(frame: frame, destinationID: place.id, session: model.presentation.session)
        #expect(first != next)
        controller.sheetFrameChanged(first)
        controller.sheetFrameChanged(next)
        model.dismiss()
        controller.sheetFrameChanged(next)
        #expect(frames == [frame])
    }

    @Test func largerTextKeepsTheCompactPreferenceUntilTheUserChoosesAnotherStop() {
        let model = DirectionsPresentationModel(compactHeight: 100)
        model.detent = model.compact
        model.usesLargeText = true
        #expect(model.detent == DirectionsPresentationModel.standard)
        #expect(!model.detents.contains(model.compact))
        model.detent = DirectionsPresentationModel.standard
        model.usesLargeText = false
        #expect(model.detent == model.compact)
        model.usesLargeText = true
        model.detent = .large
        model.usesLargeText = false
        #expect(model.detent == .large)
    }

    @Test func collapsingKeepsTheActiveRouteControlsAndNewRoutesStartAtTheStandardStop() {
        let model = DirectionsPresentationModel(compactHeight: 100)
        let options = DirectionsAuxiliary(.options)
        model.auxiliary = options
        model.detent = model.compact
        #if os(visionOS)
        #expect(!model.isCompact)
        #else
        #expect(model.isCompact)
        #endif
        #expect(model.auxiliary?.id == options.id)
        model.reset()
        #expect(model.detent == DirectionsPresentationModel.standard)
        #expect(model.auxiliary == nil)
    }
}
#endif
