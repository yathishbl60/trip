import SwiftUI
import TripDomain
import TripLocalization

struct TripBookingClockSelection: View {
    let controller: TripBookingImportController
    let dates: [TripBookingDateCandidate]

    var body: some View {
        Section {
            clockPicker(controller.model.kind.startLabel, selection: controller.value(\.departureCandidateID))
            if controller.model.departureCandidateID != nil {
                zoneLink(controller.value(\.departureZone))
            }
            clockPicker(controller.model.kind.endLabel, selection: controller.value(\.arrivalCandidateID))
            if controller.model.arrivalCandidateID != nil {
                zoneLink(controller.value(\.arrivalZone))
            }
            if controller.model.hasSelectedTimes {
                Toggle(TripText.bookingConfirmTimeZones.resource, isOn: controller.value(\.didConfirmTimeZones))
            }
        } header: { Text(TripText.bookingDetectedTimes.resource) }
        footer: { Text(TripText.bookingTimeReviewExplanation.resource) }
    }

    private func clockPicker(_ title: String, selection: Binding<Int?>) -> some View {
        Picker(title, selection: selection) {
            Text(TripText.bookingSetTimeManually.resource).tag(nil as Int?)
            ForEach(dates) { Text($0.sourceText).tag(Optional($0.id)) }
        }
    }

    private func zoneLink(_ selection: Binding<String>) -> some View {
        NavigationLink {
            TripTimeZonePickerView(selection: selection)
        } label: {
            LabeledContent(TripText.timeZone.resource, value: selection.wrappedValue.replacingOccurrences(of: "_", with: " "))
        }
    }
}

#if DEBUG
#Preview("Booking time choices · nothing preselected") {
    let model = TripBookingPreview.model()
    NavigationStack { Form { TripBookingClockSelection(controller: TripBookingImportController(model: model),
                                                        dates: TripBookingPreview.proposal.dates) } }
}
#endif
