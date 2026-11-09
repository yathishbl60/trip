#if !TRIP_STANDALONE
import TripDomain
import MapEngine
#endif
import MapKit
import SwiftUI
import Observation
import CoreGraphics

@MainActor @Observable final class CameraModel {
    @ObservationIgnored private var storedPosition: MapCameraPosition
    private var positionRevision = 0
    var position: MapCameraPosition {
        get {
            _ = positionRevision
            return storedPosition
        }
        set {
            restoration.hasNavigation = true
            storedPosition = newValue
            positionRevision += 1
        }
    }
    var zoom: ZoomLevel = .district
    let restoration = MapCameraRestorationModel()
    var previousCamera: MapCamera?
    var isTilted = false
    var isRotated = false
    var size: CGSize = .zero
    @ObservationIgnored var region: MKCoordinateRegion
    var markerScale: CGFloat = 1
    var reduceMotion = false
    @ObservationIgnored var lastLayoutTime = ContinuousClock.now
    @ObservationIgnored var visibleRect = MKMapRect.world
    @ObservationIgnored var pitch = 0.0
    @ObservationIgnored var isMoving = false
    @ObservationIgnored var frame = CGRect.zero
    @ObservationIgnored var contentFrame = CGRect.null
    @ObservationIgnored var noticeFrame = CGRect.null
    var sheetFrame = CGRect.null
    @ObservationIgnored var reservedFrames: [CGRect] = []
    @ObservationIgnored var sample: CameraSample?
    @ObservationIgnored var lastLayoutSample: CameraSample?
    @ObservationIgnored var groundScale: CameraGroundScale?
    let configuration: MapConfiguration

    init(configuration: MapConfiguration = .init()) {
        self.configuration = configuration
        storedPosition = .camera(MapCamera(centerCoordinate: configuration.validCenter.location,
                                           distance: configuration.validDistance))
        region = MKCoordinateRegion(center: configuration.validCenter.location,
                                    latitudinalMeters: configuration.validDistance,
                                    longitudinalMeters: configuration.validDistance)
    }

    @discardableResult func update(_ context: MapCameraUpdateContext) -> Bool {
        let next = CameraSample(context)
        region = context.region
        visibleRect = context.rect
        pitch = context.camera.pitch
        return recordMovement(next)
    }

    /// Detect activity separately from the accumulated threshold for expensive projection.
    @discardableResult func recordMovement(_ next: CameraSample) -> Bool {
        let changed = next != sample
        sample = next
        return changed
    }

    /// MapKit already moved its camera; recording feedback must not rebuild its content.
    func receivePosition(_ position: MapCameraPosition) {
        if position.positionedByUser || position.followsUserLocation { restoration.hasNavigation = true }
        storedPosition = position
    }

    func move(to level: ZoomLevel) {
        var camera = currentCamera
        camera.distance = groundScale?.distance(for: level, camera: camera, viewport: size) ?? level.distance
        navigate(to: camera)
    }

    func focus(_ coordinate: Coordinate) {
        var camera = currentCamera
        camera.centerCoordinate = coordinate.location
        camera.distance = ZoomLevel.street.distance
        navigate(to: camera)
    }
}
