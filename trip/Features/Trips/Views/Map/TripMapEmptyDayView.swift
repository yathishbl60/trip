import TripLocalization
import SwiftUI

struct TripMapEmptyDayView: View {
    var body: some View {
        ContentUnavailableView(TripText.noPlacesYet.resource, systemImage: "mappin.and.ellipse",
            description: Text(TripText.chooseAnotherDayOrAddPlacesInYourItinerary.resource))
    }
}

#Preview("Empty day · one message") {
    TripMapEmptyDayView()
}
#Preview("Empty day · narrow, accessibility") {
    TripMapEmptyDayView().frame(width: 320).dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
