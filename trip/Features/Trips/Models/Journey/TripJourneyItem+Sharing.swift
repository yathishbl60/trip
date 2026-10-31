import Foundation
import TripDomain

extension TripJourneyItem {
    func sharingText(day: TripDay, trip: TripPlan, timeline: TripDayTimeline?, includesAddress: Bool) -> String {
        switch self {
        case .event(let event):
            return TripEventPresentation(event: event, day: day, trip: trip).sharingText
        case .visit(let stop):
            let details = ["• \(stop.place.name)", timeline?[stop.id]?.sharingText,
                           includesAddress ? stop.place.address : nil,
                           includesAddress ? stop.place.mapsURL?.absoluteString : nil]
            return details.compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: "\n")
        }
    }
}
