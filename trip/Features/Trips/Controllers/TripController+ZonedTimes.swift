import Foundation
import SwiftUI
import TripDomain

extension TripController {
    func eventLocalDate(_ draft: TripEventDraft, arrival: Bool) -> Binding<Date> {
        Binding(get: { draft.clock(arrival: arrival).pickerDate }, set: { draft.setClockDate($0, arrival: arrival) })
    }

    func eventZone(_ draft: TripEventDraft, arrival: Bool) -> Binding<String> {
        Binding(get: { draft.clock(arrival: arrival).zoneID }, set: { draft.setClockZone($0, arrival: arrival) })
    }

    func eventOccurrence(_ draft: TripEventDraft, arrival: Bool) -> Binding<TripClockOccurrence> {
        Binding(get: { draft.clock(arrival: arrival).occurrence }, set: { draft.setClockOccurrence($0, arrival: arrival) })
    }
}
