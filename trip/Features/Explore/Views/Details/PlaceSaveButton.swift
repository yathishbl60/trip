import SwiftUI
import TripDomain
import TripLocalization

struct PlaceSaveButton: View {
    let place: Place
    let controller: PlaceController

    var body: some View {
        Group {
            if controller.isSaved(place) {
                Menu {
                    ForEach(controller.savedPlaces(place)) { reference in
                        Button(reference.title, systemImage: "arrow.up.forward") { controller.openSavedPlace(reference) }
                    }
                    Button(TripText.addToAnotherTrip.resource, systemImage: "plus") { controller.save(place) }
                } label: { Label(savedTitle, systemImage: "bookmark.fill") }
            } else {
                Button { controller.save(place) } label: { Label(TripText.saveToTrip.resource, systemImage: "bookmark") }
            }
        }
        .buttonStyle(.bordered)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityValue(place.name)
        .modifier(TripPresentationSource(id: place.id))
    }

    private var savedTitle: String {
        let references = controller.savedPlaces(place)
        return references.count == 1 ? references[0].title : TripText.alreadySaved.text
    }
}

#if DEBUG
#Preview("Save source · local") {
    PlaceSaveButton(place: PreviewFixtures.hotel,
                    controller: PlaceController(model: PlaceDetailPreviewFixtures.saving()))
        .padding()
}
#Preview("Saved visit · open or add elsewhere") {
    PlaceSaveButton(place: PreviewFixtures.hotel,
                    controller: PlaceController(model: PlaceDetailPreviewFixtures.saved()))
        .padding().dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif
