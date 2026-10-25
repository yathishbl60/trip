import SwiftUI
#if !TRIP_STANDALONE
import TripDomain
#endif

extension PlaceCategory {
    var color: Color { Color("Place-" + rawValue) }
    var markerTint: Color { Color("PlaceMarker-" + rawValue) }
}
