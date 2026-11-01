import TripLocalization
import SwiftUI
import TripDomain

struct TripEventDetailsView: View {
    let draft: TripEventDraft
    let controller: TripController

    var body: some View {
        Section {
            Picker(TripText.type.resource, selection: controller.eventValue(\.kind, draft: draft)) {
                ForEach(TripEventKind.allCases, id: \.self) { kind in
                    Label(kind.title, systemImage: kind.symbol).tag(kind)
                }
            }
            TextField(draft.titlePrompt, text: controller.eventText(\.title, draft: draft), axis: .vertical)
                .lineLimit(1...3).accessibilityLabel(TripText.title.resource)
            locations
        }
    }

    @ViewBuilder private var locations: some View {
        if draft.event.kind != .freeTime || !draft.event.location.isEmpty {
            TextField(draft.event.kind.isTransport ? TripText.fromOptional.text : TripText.locationOptional.text,
                      text: controller.eventText(\.location, draft: draft), axis: .vertical)
                .lineLimit(1...3)
            if draft.event.kind.isTransport {
                TextField(TripText.toOptional.resource, text: controller.eventText(\.arrivalLocation, draft: draft), axis: .vertical)
                    .lineLimit(1...3)
            }
        }
    }
}

#if DEBUG
#Preview("Flight details") {
    let model = TripJourneyPreview.planner()
    let trip = model.library.trips[0]
    Form {
        TripEventDetailsView(draft: TripEventDraft(trip: trip, dayID: trip.days[0].id, event: trip.events[0]),
                             controller: TripController(model: model))
    }
}
#Preview("Free time · large text") {
    let model = TripJourneyPreview.planner()
    let trip = model.library.trips[0]
    Form {
        TripEventDetailsView(draft: TripEventDraft(trip: trip, dayID: trip.days[0].id, kind: .freeTime),
                             controller: TripController(model: model))
    }.dynamicTypeSize(.accessibility2)
}
#endif
