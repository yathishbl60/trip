import SwiftUI
import TripDomain
import TripLocalization

struct PlaceSaveButton: View {
    let place: Place
    let controller: PlaceController

    var body: some View {
        Button { controller.save(place) } label: {
            Label(TripText.save.resource, systemImage: "bookmark")
                .fixedSize(horizontal: false, vertical: true)
        }
        .buttonStyle(.bordered)
        .accessibilityLabel(TripText.saveToTrip.resource)
        .modifier(TripPresentationSource(id: place.id))
    }
}

#if DEBUG
#Preview("Save source · local") {
    PlaceSaveButton(place: PreviewFixtures.hotel,
                    controller: PlaceController(model: PlaceDetailPreviewFixtures.saving()))
        .padding()
}
#endif
