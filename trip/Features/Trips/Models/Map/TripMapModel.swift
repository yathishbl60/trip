import Foundation
import MapKit
import Observation
import SwiftUI
import TripDomain

@MainActor @Observable final class TripMapModel {
    let tripID: UUID
    let library: TripLibraryModel
    private(set) var selectedDayID: UUID?
    private(set) var selectedStopID: UUID?
    private(set) var listFocusRevision = 0
    var position = MapCameraPosition.automatic
    @ObservationIgnored var currentCamera: MapCamera?
    @ObservationIgnored private var framedLocations: [UUID: Coordinate] = [:]

    init(tripID: UUID, initialDayID: UUID?, library: TripLibraryModel) {
        self.tripID = tripID
        self.library = library
        selectedDayID = initialDayID
    }

    var trip: TripPlan? { library.trip(tripID) }
    var day: TripDay? {
        trip?.days.first { $0.id == selectedDayID }
            ?? trip?.days.first { $0.stops.contains { $0.place.coordinate.isValid } }
            ?? trip?.days.first { !$0.stops.isEmpty } ?? trip?.days.first
    }
    var stops: [TripMapStop] {
        (day?.stops ?? []).enumerated().map { TripMapStop(id: $1.id, number: $0 + 1, place: $1.place) }
    }
    var mappedStops: [TripMapStop] { stops.filter { $0.place.coordinate.isValid } }
    func selectDay(_ id: UUID?, animated: Bool) {
        guard let id, trip?.days.contains(where: { $0.id == id }) == true else { return }
        selectedDayID = id
        selectedStopID = nil
        fit(animated: animated)
    }

    func selectStop(_ id: UUID?, focus: Bool, animated: Bool) {
        guard let id else { selectedStopID = nil; return }
        guard let stop = mappedStops.first(where: { $0.id == id }) else { return }
        selectedStopID = id
        if focus { focusCamera(on: stop.place.coordinate, animated: animated) }
        else { listFocusRevision += 1 }
    }

    func fit(animated: Bool) {
        framedLocations = mappedLocations
        let fitted = fittedPosition
        currentCamera = fitted.camera
        withAnimation(animated ? .smooth(duration: 0.35) : nil) { position = fitted }
    }

    func reconcile() {
        if !mappedStops.contains(where: { $0.id == selectedStopID }) { selectedStopID = nil }
        guard mappedLocations != framedLocations else { return }
        fit(animated: false)
    }

    private var mappedLocations: [UUID: Coordinate] {
        Dictionary(mappedStops.map { ($0.id, $0.place.coordinate) }, uniquingKeysWith: { first, _ in first })
    }

    private var fittedPosition: MapCameraPosition {
        let points = Set(mappedStops.map { $0.place.coordinate })
        if points.count == 1, let point = points.first {
            return .camera(MapCamera(centerCoordinate: point.location, distance: 2500))
        }
        return .automatic
    }
}

nonisolated struct TripMapStop: Identifiable, Equatable {
    let id: UUID
    let number: Int
    let place: Place
    var label: String { "\(number). \(place.name)" }
}
