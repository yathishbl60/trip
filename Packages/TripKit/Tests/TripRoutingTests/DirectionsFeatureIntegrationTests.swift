#if os(iOS) || os(visionOS)
import Testing
import SwiftUI
import MapKit
import TripDomain
import TripRouting

/// Uses only public API, as a separate host app would; no live service is called.
@MainActor struct DirectionsFeatureIntegrationTests {
    let destination = Place(id: "destination", name: "Market", coordinate: .bangkok,
                            category: .shopping, importance: 1, rating: nil, reviews: nil)

    @Test func publicHostCanComposeTheSheetAndMapWithoutLocationAccess() {
        var requests = 0
        let environment = DirectionsEnvironment(requestLocation: { requests += 1 }, loadedPlaces: { [destination] })
        let model = DirectionsModel(environment: environment)
        _ = DirectionsSheetView(model: model)
        _ = DirectionsMapContent(model: model, scale: 1)
        model.begin(destination, origin: nil)
        #expect(model.isPresented && model.destinationID == destination.id)
        #expect(model.routeBounds == nil)
        #expect(!model.waitsForLocation && requests == 0)
        #expect(model.placeIDs == [destination.id])
        model.dismiss()
        #expect(!model.isPresented && model.destinationID == nil)
    }

    @Test func publicHostCanConfigureAndFrameWithoutReadingInternalState() {
        let configuration = DirectionsConfiguration(modes: [.walking], maximumStops: 3, compactHeight: 140)
        let environment = DirectionsEnvironment(locationAuthorized: { true }, appearance: DirectionsAppearance(actionTint: .teal))
        let model = DirectionsModel(configuration: configuration)
        model.configure(environment: environment)
        model.begin(destination, origin: destination.coordinate)
        #expect(model.maximumPlaces == 5)
        #expect(model.routeBounds != nil && model.requestRouteFit())
        model.didFitRoute()
        model.stopFollowingRoute()
        #expect(!model.requestRouteFit())
        #expect(model.routeBounds != nil)
        model.suspend()
        model.cancelRouteFit()
    }
}
#endif
