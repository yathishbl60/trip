import TripLocalization
import TripDomain
import SwiftUI

struct TripDraftDayView: View {
    let day: TripDay

    var body: some View {
        Section(day.title) {
            if day.stops.count > 1 {
                LabeledContent(TripText.valueStraightLine(day.placeCountText).resource) {
                    Text(day.draftDistance, format: .measurement(width: .abbreviated, usage: .road))
                }.font(.subheadline).foregroundStyle(.secondary)
            }
            if !day.notes.isEmpty { Text(day.notes).font(.subheadline).foregroundStyle(.secondary) }
            if day.stops.isEmpty { Text(TripText.freeDay.resource).foregroundStyle(.secondary) }
            ForEach(Array(day.stops.enumerated()), id: \.element.id) { index, stop in
                TripNumberedStopRow(place: stop.place, number: index + 1)
            }
        }
    }
}

#if DEBUG
#Preview("Generated day") {
    List { TripDraftDayView(day: PreviewFixtures.tripPlanner().library.trips[0].days[0]) }
}
#Preview("Generated day · accessibility") {
    List { TripDraftDayView(day: PreviewFixtures.tripPlanner().library.trips[0].days[0]) }
        .dynamicTypeSize(.accessibility2)
}
#endif
