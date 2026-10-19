#if os(iOS) || os(visionOS)
import MapKit
import SwiftUI
import CoreGraphics
import TripDomain

extension DirectionsModel {
    /// Project immediately in the host's live MapReader callback; the proxy is never retained.
    public func mapExclusions(using proxy: MapProxy, scale: CGFloat) -> [CGRect] {
        var result: [CGRect] = []
        for (index, route) in routes.enumerated() {
            guard let point = proxy.convert(route.labelCoordinate(index: index).location, to: .local) else { continue }
            let size = DirectionsRoute.labelSize
            let width = size.width * scale, height = size.height * scale
            result.append(CGRect(x: point.x - width / 2 - 4, y: point.y - height / 2 - 4,
                                 width: width + 8, height: height + 8))
        }
        for place in annotatedPlaces {
            if let point = proxy.convert(place.coordinate.location, to: .local) {
                result.append(CGRect(x: point.x - 34, y: point.y - 80, width: 68, height: 88))
            }
        }
        return result.filter { $0.minX.isFinite && $0.minY.isFinite && $0.maxX.isFinite && $0.maxY.isFinite }
    }
}
#endif
