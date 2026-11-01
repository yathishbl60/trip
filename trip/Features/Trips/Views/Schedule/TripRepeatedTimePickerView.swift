import TripLocalization
import SwiftUI
import TripDomain

struct TripRepeatedTimePickerView: View {
    let clock: TripZonedDateTime
    @Binding var selection: TripClockOccurrence

    var body: some View {
        Picker(TripText.repeatedClockTime.resource, selection: $selection) {
            Text(TripText.chooseOccurrence.resource).tag(TripClockOccurrence.unresolved)
            Text(clock.occurrenceLabel(.first)).tag(TripClockOccurrence.first)
            Text(clock.occurrenceLabel(.last)).tag(TripClockOccurrence.last)
        }
    }
}

#if DEBUG
#Preview("Choose a daylight-saving occurrence") {
    @Previewable @State var occurrence = TripClockOccurrence.unresolved
    Form {
        TripRepeatedTimePickerView(clock: TripZonedDateTime(date: TripLocalDate(year: 2026, month: 11, day: 1),
                                                           minute: 90, zoneID: "America/New_York"), selection: $occurrence)
    }
}
#endif
