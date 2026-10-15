import Testing
import MapKit
import CoreGraphics
import TripRouting
import TripDomain

struct RouteMapGeometryTests {
    @Test func bottomSheetLeavesTheOriginalTopViewport() {
        let bounds = CGRect(x: 0, y: 0, width: 393, height: 852)
        let sheet = CGRect(x: 0, y: 480, width: 393, height: 372).insetBy(dx: -8, dy: -20)
        #expect(RouteMapGeometry.exposedFrame(in: bounds, obstacles: [sheet])
                == CGRect(x: 0, y: 0, width: 393, height: 460))
    }

    @Test func floatingSheetSelectsTheLargestRemainingRectangle() {
        let bounds = CGRect(x: 0, y: 0, width: 1_024, height: 768)
        let sheet = CGRect(x: 40, y: 80, width: 320, height: 600)
        #expect(RouteMapGeometry.exposedFrame(in: bounds, obstacles: [sheet])
                == CGRect(x: 360, y: 0, width: 664, height: 768))
    }

    @Test func invalidAndCoveredViewportsCannotMoveTheCamera() {
        let frame = CGRect(x: 0, y: 0, width: 393, height: 852)
        #expect(RouteMapGeometry.exposedFrame(in: .null, obstacles: []) == .zero)
        #expect(RouteMapGeometry.exposedFrame(in: frame, obstacles: [frame]) == .zero)
        #expect(RouteMapGeometry.cameraRect(for: .null, in: frame, exposedViewport: frame, mapSize: frame.size) == nil)
        #expect(RouteMapGeometry.cameraRect(for: .world, in: frame, exposedViewport: .zero, mapSize: frame.size) == nil)
    }

    @Test func cameraRectFitsTheSameRouteIntoTheExposedViewport() throws {
        let native = CGRect(x: 0, y: 0, width: 393, height: 852)
        let exposed = CGRect(x: 0, y: 0, width: 393, height: 460)
        let route = MKMapRect(x: 220_000_000, y: 123_000_000, width: 2_000, height: 4_000)
        let camera = try #require(RouteMapGeometry.cameraRect(for: route, in: native,
                                                            exposedViewport: exposed, mapSize: native.size))
        let scale = camera.width / native.width
        #expect(abs((route.midX - camera.minX) / scale - exposed.midX) < 0.0001)
        #expect(abs((route.midY - camera.minY) / scale - exposed.midY) < 0.0001)
        #expect(route.width / scale <= exposed.width - 104 + 0.0001)
        #expect(route.height / scale <= exposed.height - 104 + 0.0001)
    }

    @Test func automaticMapsLinkRetainsTheWidgetsDestinationOnlyURL() {
        let destination = Coordinate(latitude: 13.74, longitude: 100.52)
        let link = MapsDirectionsLink(destination: destination, mode: .automatic)
        #expect(link.url?.absoluteString == "https://maps.apple.com/directions?destination=13.74,100.52")
    }
}
