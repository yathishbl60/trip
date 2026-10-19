#if os(iOS) || os(visionOS)
import MapKit
import TripDomain

extension DirectionsModel {
    /// Host selection and itinerary validation do not need the feature's mutable state.
    public var destinationID: String? { destination?.id }
    public var maximumPlaces: Int { min(20, max(0, configuration.maximumStops)) + 2 }

    /// Late binding supports host callbacks that weakly capture their owning model.
    public func configure(environment: DirectionsEnvironment) { self.environment = environment }

    public var routeBounds: MKMapRect? {
        guard isPresented, status == .ready else { return nil }
        return selectedRoute?.polyline.boundingMapRect ?? endpointBounds
    }

    /// A viewport change requests framing only while the user is following the route.
    public func requestRouteFit() -> Bool {
        guard isPresented, presentation.followsRoute else { return false }
        presentation.needsRouteFraming = true
        return true
    }

    public func didFitRoute() { presentation.needsRouteFraming = false }

    public func stopFollowingRoute() {
        presentation.needsRouteFraming = false
        presentation.followsRoute = false
        cancelRouteFit()
    }
}
#endif
