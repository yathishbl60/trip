import TripLocalization
import SwiftUI
import TripDomain

struct TripLookupControls: View {
    let controller: TripLookupController

    var body: some View {
        Section {
            if let reason = controller.model.unavailableReason {
                Label(reason, systemImage: "info.circle").foregroundStyle(.secondary)
            } else { question }
            filters
        } header: { Text(TripText.findASavedDetail.resource) } footer: {
            Text(TripText.tryWhereAmIStayingOrWhatSPlanned.resource)
        }
    }

    private var question: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField(TripText.askAboutYourItinerary.resource, text: controller.question, axis: .vertical)
                .lineLimit(1...3).submitLabel(.search).onSubmit(controller.ask)
            if controller.model.isSearching {
                HStack {
                    ProgressView(TripText.findingDetails.resource)
                    Spacer()
                    Button(TripText.cancel.resource, action: controller.cancel)
                }
            } else {
                Button(TripText.findDetails.resource, systemImage: "sparkles", action: controller.ask)
                    .disabled(!controller.model.canAsk)
            }
        }
    }

    private var filters: some View {
        Group {
            Menu(controller.model.dayTitle, systemImage: "calendar") {
                Button(TripText.wholeTrip.resource) { controller.chooseDay(nil) }
                ForEach(controller.model.plan?.days ?? []) { day in
                    Button(TripText.dayValueValue(TripText.number(day.number), day.dateText).resource) {
                        controller.chooseDay(day.number)
                    }
                }
            }
            Menu(controller.model.query.category.title, systemImage: "line.3.horizontal.decrease") {
                ForEach([TripDetailCategory.all, .stays, .travel, .reservations, .places, .freeTime, .untimed], id: \.self) { category in
                    Button(category.title) { controller.choose(category) }
                }
            }
        }
    }
}

#if DEBUG
#Preview("Lookup · quick filters") {
    let model = PreviewTripServices.makeLookup()
    model.unavailableReason = "Apple Intelligence is getting ready. Quick filters work now."
    return Form { TripLookupControls(controller: TripLookupController(model: model)) }
}
#Preview("Lookup · searching") {
    let model = PreviewTripServices.makeLookup()
    model.question = "Where am I staying?"
    model.isSearching = true
    return Form { TripLookupControls(controller: TripLookupController(model: model)) }
}
#endif
