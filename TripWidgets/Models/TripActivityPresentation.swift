import TripLocalization
#if os(iOS)
import Foundation
import TripDomain

nonisolated struct TripActivityPresentation {
    let attributes: TripActivityAttributes
    let state: TripActivityAttributes.ContentState
    let isStale: Bool
    var canVisit: Bool { state.isActive && !isStale && state.nextStopID != nil }
    var title: String {
        if state.total == 0 { return TripText.noPlacesPlanned.text }
        if !state.isActive { return state.visited == state.total ? TripText.allPlacesVisited.text : TripText.trackingEnded.text }
        if isStale { return TripText.openTripToContinue.text }
        return state.nextStopName
    }
    var symbol: String {
        if state.total == 0 { return "suitcase.rolling" }
        if !state.isActive { return state.visited == state.total ? "checkmark.circle.fill" : "stop.circle" }
        return isStale ? "clock" : state.nextSymbol ?? "suitcase.rolling.fill"
    }
    var tripTitle: String { state.currentTripTitle ?? attributes.tripTitle }
    var subtitle: String {
        TripText.dayValueValueOfValueVisited(TripText.number(state.currentDayNumber ?? attributes.dayNumber), TripText.number(state.visited), TripText.number(state.total)).text
    }
    var compactText: String { isStale ? "—" : "\(state.visited)/\(state.total)" }
    var directionsURL: URL? {
        guard canVisit, let coordinate = state.nextCoordinate, coordinate.isValid else { return nil }
        return TripSystemData.directionsURL(coordinate)
    }
    var destinationURL: URL? {
        if canVisit, let id = state.nextStopID { return TripSystemData.detailURL(tripID: attributes.tripID, itemID: id) }
        return TripSystemData.tripURL(attributes.tripID)
    }
    var context: String? {
        guard canVisit else { return nil }
        if let time = state.plannedTime {
            let zone = TripLocalDate.calendar(zoneID: state.timeZoneID ?? TimeZone.current.identifier).timeZone
            return TripText.plannedValue(time.formatted(Date.FormatStyle(date: .omitted, time: .shortened, timeZone: zone))).text
        }
        return state.followingStopName.map { TripText.thenValue($0).text }
    }
}
#endif
