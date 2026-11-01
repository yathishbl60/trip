import TripLocalization
import TripDomain
import SwiftUI

/// Search reads stay in the list; the sheet retains the query across library changes.
struct TripSaveChoicesView: View {
    let place: Place
    let controller: TripController
    @Binding var searchText: String

    var body: some View {
        let trips = controller.model.library.filteredTrips(query: searchText, sortOrder: .recent)
        List {
            Section {
                TripPlaceLabel(title: place.name, subtitle: place.category.annotationTitle,
                               symbol: place.category.symbol, color: place.category.color)
            }
            ForEach(trips, content: destination)
        }
        .scrollContentBackground(.hidden)
        #if os(iOS)
        .scrollDismissesKeyboard(.interactively)
        #endif
        .searchable(text: $searchText, prompt: Text(TripText.findATrip.resource))
        .overlay {
            if trips.isEmpty { ContentUnavailableView.search(text: searchText) }
        }
    }

    private func destination(_ trip: TripPlan) -> some View {
        NavigationLink {
            TripSaveDestinationsView(place: place, tripID: trip.id, controller: controller)
        } label: {
            TripRowView(trip: trip)
        }
    }
}

#if DEBUG
#Preview("Save choices · local trips") {
    @Previewable @State var query = ""
    NavigationStack {
        TripSaveChoicesView(place: PreviewFixtures.hotel,
                            controller: TripController(model: PreviewFixtures.tripPlanner()), searchText: $query)
    }
}
#Preview("Save choices · narrow, large text") {
    @Previewable @State var query = ""
    NavigationStack {
        TripSaveChoicesView(place: PreviewFixtures.longName,
                            controller: TripController(model: PreviewFixtures.tripPlanner()), searchText: $query)
    }.frame(width: 360).dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#Preview("Save choices · unmatched search") {
    @Previewable @State var query = "No matching trip"
    NavigationStack {
        TripSaveChoicesView(place: PreviewFixtures.hotel,
                            controller: TripController(model: PreviewFixtures.tripPlanner()), searchText: $query)
    }
}
#endif
