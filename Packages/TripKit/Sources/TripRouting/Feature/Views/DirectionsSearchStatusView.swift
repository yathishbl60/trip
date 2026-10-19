#if !TRIP_STANDALONE
import TripLocalization
#endif
#if os(iOS) || os(visionOS)
import SwiftUI

struct DirectionsSearchStatusView: View {
    let controller: DirectionsController
    let session: DirectionsPlacePicker
    private var status: DirectionsSearchStatus { controller.model.stopSearch.status }

    var body: some View {
        if status != .idle {
            if controller.model.availableStops.isEmpty { emptyState }
            else { Text(status.message).font(.footnote).foregroundStyle(.secondary) }
            if status.canRetry {
                Button(TripText.tryAgain.resource, systemImage: "arrow.clockwise") { controller.loadStops(session: session) }
            }
        } else if controller.model.hasFilteredSearchResults {
            ContentUnavailableView(TripText.placesAlreadyAdded.resource, systemImage: "checkmark.circle",
                                   description: Text(TripText.thesePlacesAreAlreadyOnYourRoute.resource))
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(status.title, systemImage: "magnifyingglass",
                               description: Text(status.message))
    }
}

#if DEBUG
#Preview("Route search · retry, large text") {
    let model = DirectionsPreviewFixtures.ready()
    model.beginAddingStop()
    model.stopSearch.status = .timedOut
    return List {
        if let session = model.presentation.placePicker {
            DirectionsSearchStatusView(controller: DirectionsController(model: model), session: session)
        }
    }.dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#Preview("Route search · no matches") {
    let model = DirectionsPreviewFixtures.ready()
    model.beginAddingStop()
    model.stopSearch.status = .noResults
    return List {
        if let session = model.presentation.placePicker {
            DirectionsSearchStatusView(controller: DirectionsController(model: model), session: session)
        }
    }
}
#endif
#endif
