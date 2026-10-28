import TripRouting
import MapKit
import SwiftUI
import CoreGraphics

extension ExploreModel {
    func routeExclusions(using proxy: MapProxy) -> [CGRect] {
        directions.mapExclusions(using: proxy, scale: camera.markerScale)
    }
}
