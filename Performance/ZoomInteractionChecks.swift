import Foundation
import MapKit
import SwiftUI

@MainActor enum ZoomInteractionChecks {
    static func run() throws {
        try boundaries()
        try directJumps()
        try navigation()
        try wrappedCamera()
        try CameraGroundScaleChecks.run()
        print("PASS: all zoom hysteresis boundaries, direct jumps, navigation perspective, and wrapped camera movement")
    }

    private static func boundaries() throws {
        for (index, boundary) in [45.0, 3.5].enumerated() {
            let far = ZoomLevel.allCases[index]
            let near = ZoomLevel.allCases[index + 1]
            for hysteresis in [0.02, 0.12, 0.35] {
                for origin in [far, near] {
                    var current = origin
                    for step in 0..<120 {
                        let jitter = (step.isMultiple(of: 2) ? 1 : -1) * hysteresis / 2
                        current = ZoomLevel.resolve(metersPerPoint: boundary * (1 + jitter),
                                                    previous: current, hysteresis: hysteresis)
                        try require(current == origin, "Pinch jitter changed level inside its hysteresis band")
                    }
                }
                try crossing(boundary, far: far, near: near, hysteresis: hysteresis)
            }
        }
    }

    private static func crossing(_ boundary: Double, far: ZoomLevel, near: ZoomLevel, hysteresis: Double) throws {
        let inward = ZoomLevel.resolve(metersPerPoint: boundary * (1 - hysteresis - 0.001),
                                       previous: far, hysteresis: hysteresis)
        let outward = ZoomLevel.resolve(metersPerPoint: boundary * (1 + hysteresis + 0.001),
                                        previous: near, hysteresis: hysteresis)
        try require(inward == near && outward == far, "Zoom did not cross its directional boundary")
    }

    private static func directJumps() throws {
        for origin in ZoomLevel.allCases {
            try require(ZoomLevel.resolve(metersPerPoint: 0.1, previous: origin) == .street, "Fast pinch stopped at an intermediate level")
            try require(ZoomLevel.resolve(metersPerPoint: 1_000, previous: origin) == .region, "Fast zoom out stopped at an intermediate level")
            for invalid in [Double.nan, .infinity, -.infinity, 0, -1] {
                try require(ZoomLevel.resolve(metersPerPoint: invalid, previous: origin) == origin, "Invalid projection changed zoom")
            }
        }
    }

    private static func navigation() throws {
        let model = CameraModel()
        let origin = MapCamera(centerCoordinate: Coordinate.bangkok.location, distance: 9_000, heading: 359, pitch: 50)
        model.receivePosition(.camera(origin))
        for level in ZoomLevel.allCases {
            model.move(to: level)
            let camera = model.currentCamera
            try require(camera.distance == level.distance, "Zoom command lost its requested distance")
            try require(camera.heading == origin.heading && camera.pitch == origin.pitch, "Zoom reset map perspective")
            try require(Coordinate(camera.centerCoordinate) == Coordinate(origin.centerCoordinate), "Zoom moved away from the current area")
            model.goBack()
            try require(model.currentCamera == origin, "Returning from zoom lost the previous viewpoint")
        }
    }

    private static func wrappedCamera() throws {
        var camera = CameraModel().currentCamera
        camera.heading = 359.95
        let world = MKMapSize.world.width
        let viewport = CGSize(width: 400, height: 800)
        let rect = CGRect(x: world - 500, y: 500, width: 1_000, height: 2_000)
        let origin = CameraSample(camera, rect: rect)
        camera.heading = 0.05
        let wrapped = CameraSample(camera, rect: rect.offsetBy(dx: -world + 10, dy: 0))
        try require(!wrapped.differs(from: origin, viewport: viewport), "Heading/dateline wrapping triggered a full layout")
        let moved = CameraSample(camera, rect: rect.offsetBy(dx: -world + 100, dy: 0))
        try require(moved.differs(from: origin, viewport: viewport), "Dateline crossing suppressed a meaningful pan")
    }
}
