import TripLocalization
import SwiftUI
import TripDomain

struct TripTimeZoneReviewView: View {
    let draft: TripEditDraft
    let controller: TripController

    var body: some View {
        Form {
            Section {
                NavigationLink(draft.timeZoneID.replacingOccurrences(of: "_", with: " ")) {
                    TripTimeZonePickerView(selection: controller.draftTimeZone(draft))
                }
                DatePicker(TripText.departureDate.resource, selection: controller.draftDate(draft), displayedComponents: .date)
                Button(TripText.confirmThisTimeZone.resource) { controller.confirmTimeZone(draft) }
                if draft.timeZoneReviewed { Label(TripText.readyToSaveWithYourTrip.resource, systemImage: "checkmark.circle") }
            } footer: { Text(draft.timeZoneMessage) }
        }
        .environment(\.timeZone, draft.calendar.timeZone).environment(\.calendar, draft.calendar)
        .navigationTitle(TripText.tripTimeZone.resource).navigationBarTitleDisplayMode(.inline)
        #if os(iOS)
        .scrollEdgeEffectStyle(.soft, for: .top)
        #endif
    }
}

#if DEBUG
#Preview("Review older trip times") {
    let model = TripJourneyPreview.planner()
    var trip = model.library.trips[0]
    trip.timeZoneID = nil
    trip.localStartDate = nil
    return NavigationStack {
        TripTimeZoneReviewView(draft: TripEditDraft(trip: trip), controller: TripController(model: model))
    }
}
#endif
