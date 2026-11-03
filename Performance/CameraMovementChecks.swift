import CoreGraphics
import MapKit
import SwiftUI
import Synchronization

@MainActor enum CameraMovementChecks {
    static func run() throws {
        try slowPan()
        try gentlePinch()
        print("PASS: subpixel pan and gentle pinch detect activity without per-frame projection or observation writes")
    }

    private static func slowPan() throws {
        let model = CameraModel()
        let viewport = CGSize(width: 400, height: 800)
        let rect = CGRect(origin: .zero, size: viewport)
        let baseline = CameraSample(model.currentCamera, rect: rect)
        model.recordMovement(baseline)
        let updates = ObservationCounter()
        CameraFeedbackChecks.observe(model, updates)
        for frame in 1...96 {
            let next = CameraSample(model.currentCamera, rect: rect.offsetBy(dx: Double(frame) / 4, dy: 0))
            try require(model.recordMovement(next), "A subpixel pan did not mark camera activity")
            try require(next.differs(from: baseline, viewport: viewport) == (frame == 96),
                        "Small pan did not retain the accumulated projection threshold")
        }
        try require(!model.recordMovement(model.sample!), "Identical camera callback counted as movement")
        try require(updates.count.withLock { $0 } == 0, "Movement feedback rebuilt observable map content")
    }

    private static func gentlePinch() throws {
        let model = CameraModel()
        var camera = model.currentCamera
        let rect = CGRect(x: 0, y: 0, width: 400, height: 800)
        let baseline = CameraSample(camera, rect: rect)
        var previous = baseline
        model.recordMovement(baseline)
        for _ in 0..<20 {
            camera.distance *= 0.999
            let next = CameraSample(camera, rect: rect)
            try require(!next.differs(from: previous, viewport: rect.size, minimumPanDistance: 1),
                        "Fixture should remain below the old adjacent-frame movement threshold")
            try require(model.recordMovement(next), "Gentle pinch did not cancel settled work")
            previous = next
        }
        try require(previous.differs(from: baseline, viewport: rect.size), "Gentle pinch never accumulated enough to project")
    }
}
