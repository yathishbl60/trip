#if !TRIP_STANDALONE
import TripLocalization
#endif
#if os(iOS) || os(visionOS)
import Foundation
import MapKit
import TripDomain

extension DirectionsModel {
    var selectedRoute: DirectionsRoute? { routes.first { $0.id == selectedID } }
    var estimate: DirectionsEstimate? { selectedRoute?.estimate ?? transitEstimate }
    public var isPresented: Bool { destination != nil }

    func showSteps() {
        guard presentation.stepsVisit == nil, selectedRoute?.steps.isEmpty == false else { return }
        presentation.stepsVisit = UUID()
    }

    func setSelectedRoute(_ id: String?) {
        selectedID = id
        if presentation.stepsVisit != nil, selectedRoute?.steps.isEmpty != false {
            presentation.stepsVisit = nil
        }
    }

    func mapsHandoffCompletion(_ completion: @escaping (Bool) -> Void) -> (Bool) -> Void {
        let handoffID = UUID()
        presentation.handoffID = handoffID
        let generation = generation
        let auxiliaryID = presentation.auxiliary?.id
        let stepsVisit = presentation.stepsVisit
        let routeID = selectedID
        return { [weak self] accepted in
            guard let self, isPresented, generation == self.generation, routeID == selectedID,
                  presentation.auxiliary?.id == auxiliaryID, presentation.stepsVisit == stepsVisit,
                  presentation.handoffID == handoffID else { return }
            presentation.handoffID = nil
            completion(accepted)
        }
    }

    var mapsURL: URL? {
        guard let destination, startingPoint.selection != .unspecified else { return nil }
        return MapsDirectionsLink(origin: startingPoint.place?.coordinate, destination: destination.coordinate, stops: stops.map(\.coordinate),
                                  mode: mode, options: options).url
    }

    func label(for route: DirectionsRoute) -> String {
        if route.id == routes.min(by: { $0.estimate.travelTime < $1.estimate.travelTime })?.id { return TripText.fastest.text }
        return TripText.alternative.text
    }

    func choiceLabel(for route: DirectionsRoute) -> String {
        let peers = routes.filter {
            $0.estimate.durationText == route.estimate.durationText && label(for: $0) == label(for: route)
        }
        guard peers.count > 1 else { return label(for: route) }
        let name = route.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return ordinalLabel(label(for: route), route, peers) }
        let normalized = normalizedRouteName(name)
        let duplicate = peers.filter { normalizedRouteName($0.name) == normalized }.count > 1
        return duplicate ? ordinalLabel(name, route, peers) : name
    }

    private func ordinalLabel(_ label: String, _ route: DirectionsRoute, _ peers: [DirectionsRoute]) -> String {
        let ordinal = (peers.firstIndex { $0.id == route.id } ?? 0) + 1
        return "\(label) \(ordinal)"
    }

    private func normalizedRouteName(_ name: String) -> String {
        name.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .filter { $0.isLetter || $0.isNumber }
    }

    var annotatedPlaces: [Place] {
        guard let place = startingPoint.place, !destinationPlaces.contains(where: { $0.id == place.id }) else {
            return destinationPlaces
        }
        return [place] + destinationPlaces
    }

    public var placeIDs: Set<String> { Set(annotatedPlaces.map(\.id)) }

    var endpointBounds: MKMapRect? {
        guard let origin, destination != nil else { return nil }
        return ([origin] + destinationPlaces.map(\.coordinate)).reduce(MKMapRect.null) { bounds, coordinate in
            let point = MKMapPoint(coordinate.location)
            return bounds.union(MKMapRect(origin: point, size: MKMapSize(width: 1, height: 1)))
        }
    }
}
#endif
