#if !TRIP_STANDALONE
import TripDomain
#endif
import Foundation

extension PlaceSearchRequest {
    /// Camera jitter, rotation, and sheet changes do not warrant the same search again.
    public nonisolated func covers(_ other: Self) -> Bool {
        guard query == other.query, categories == other.categories else { return false }
        let latitude = abs(area.center.latitude - other.area.center.latitude)
        let delta = abs(area.center.longitude - other.area.center.longitude).truncatingRemainder(dividingBy: 360)
        let longitude = min(delta, 360 - delta)
        return latitude < min(area.latitudeSpan, other.area.latitudeSpan) * 0.15
            && longitude < min(area.longitudeSpan, other.area.longitudeSpan) * 0.15
            && similar(area.latitudeSpan, other.area.latitudeSpan)
            && similar(area.longitudeSpan, other.area.longitudeSpan)
    }

    private nonisolated func similar(_ first: Double, _ second: Double) -> Bool {
        abs(first - second) < max(first, second) * 0.15
    }
}
