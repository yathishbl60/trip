import SwiftUI
import TripDomain
import TripLocalization

struct TripBookingReviewView: View {
    let controller: TripBookingImportController
    let proposal: TripBookingProposal

    var body: some View {
        Section(TripText.bookingSuggestedDetails.resource) {
            TextField(TripText.title.resource, text: controller.value(\.title), axis: .vertical)
            Picker(TripText.type.resource, selection: controller.value(\.kind)) {
                ForEach(TripEventKind.allCases, id: \.self) { Text($0.title).tag($0) }
            }
            locations
        }
        if !proposal.dates.isEmpty {
            TripBookingClockSelection(controller: controller, dates: proposal.dates)
        }
        Section {
            DisclosureGroup(TripText.bookingSourceText.resource) {
                Text(proposal.recognizedText).textSelection(.enabled)
                    .font(.callout).fixedSize(horizontal: false, vertical: true)
            }
        } footer: { Text(TripText.bookingReviewExplanation.resource) }
    }

    private var locations: some View {
        Group {
            TextField(TripText.locationOptional.resource, text: controller.value(\.location), axis: .vertical)
            if controller.model.kind.isTransport {
                TextField(TripText.toOptional.resource, text: controller.value(\.arrivalLocation), axis: .vertical)
            }
        }
    }
}

#if DEBUG
#Preview("Booking source · local extracted text") {
    let model = TripBookingPreview.model()
    Form { TripBookingReviewView(controller: TripBookingImportController(model: model), proposal: TripBookingPreview.proposal) }
}
#Preview("Booking source · large text") {
    let model = TripBookingPreview.model()
    Form { TripBookingReviewView(controller: TripBookingImportController(model: model), proposal: TripBookingPreview.proposal) }
        .dynamicTypeSize(.accessibility3)
}
#endif
