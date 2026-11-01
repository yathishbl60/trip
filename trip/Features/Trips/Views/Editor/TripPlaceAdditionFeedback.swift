import TripLocalization
import SwiftUI
import TripDomain

struct TripPlaceAdditionFeedback: View {
    let picker: TripSavedPlacePickerModel
    let controller: TripController
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        if let addition = picker.lastAddition {
            let layout = typeSize.isAccessibilitySize
                ? AnyLayout(VStackLayout(alignment: .leading, spacing: AppTheme.Spacing.small))
                : AnyLayout(HStackLayout(spacing: AppTheme.Spacing.medium))
            layout {
                Label(addition.message, systemImage: "checkmark.circle.fill")
                    .font(.subheadline).fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button(TripText.undo.resource) { controller.undoPickedPlace(picker) }
                    .buttonStyle(.bordered).controlSize(.large).fixedSize()
                    .disabled(controller.model.tracking.isBusy)
                    .accessibilityLabel(TripText.undoAddingValue(addition.stop.place.name).resource)
            }.padding().background(.bar)
        }
    }
}

#if DEBUG
#Preview("Added a place · undo, local") {
    let model = PreviewFixtures.tripPlanner()
    let trip = model.library.trips[0]
    let picker = TripSavedPlacePickerModel(tripID: trip.id, dayID: trip.days[0].id)
    picker.lastAddition = TripPlaceAddition(stop: TripStop(place: PreviewFixtures.longName),
                                           dayID: trip.days[0].id, dayTitle: trip.days[0].title)
    return TripPlaceAdditionFeedback(picker: picker, controller: TripController(model: model))
        .frame(width: 320).dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif
