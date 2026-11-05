import AppIntents
import SwiftUI
import TripDomain
import TripLocalization

struct TripLookupResultsSection: View {
    let tripID: UUID
    let controller: TripController
    private var lookup: TripLookupController { TripLookupController(model: controller.model.lookup) }

    var body: some View {
        Section {
            if lookup.model.results.isEmpty { emptyResults }
            else { ForEach(lookup.model.results, content: row) }
        } header: { Text(lookup.model.heading) } footer: {
            Text(TripText.savedItineraryTimesUseSavedTimeZonesConfirmBooking.resource)
        }
    }

    private func row(_ result: TripDetailResult) -> some View {
        Button { controller.editSavedDetail(result.id, tripID: tripID) } label: {
            TripLookupResultView(result: result)
                .frame(maxWidth: .infinity, minHeight: AppTheme.controlTarget, alignment: .leading)
                .contentShape(.rect)
        }
            .buttonStyle(.plain)
            .accessibilityHint(TripText.edit.resource)
            .appEntityIdentifier(controller.detailEntityIdentifier(tripID: tripID, itemID: result.id))
            .contextMenu {
                Button(TripText.edit.resource, systemImage: "pencil") { controller.editSavedDetail(result.id, tripID: tripID) }
                if let place = controller.savedDetailPlace(result.id, tripID: tripID) {
                    Button(TripText.showOnMap.resource, systemImage: "map") { controller.showOnMap(place) }
                }
                ShareLink(item: result.shareText)
            } preview: {
                TripLookupResultView(result: result).padding().frame(idealWidth: 320)
            }
    }

    private var emptyResults: some View {
        ContentUnavailableView {
            Label(TripText.noMatchingDetails.resource, systemImage: "text.magnifyingglass")
        } description: {
            Text(lookup.model.emptyMessage)
        } actions: {
            if lookup.model.hasFilters { Button(TripText.showAllDetails.resource, action: lookup.resetFilters) }
        }
    }
}

#if DEBUG
#Preview("Share saved detail · local itinerary") {
    let model = TripJourneyPreview.planner()
    model.lookup.prepare(model.library.trips[0])
    return List {
        TripLookupResultsSection(tripID: model.library.trips[0].id, controller: TripController(model: model))
    }
}
#Preview("Saved details · large text, dark") {
    let model = TripJourneyPreview.planner()
    model.lookup.prepare(model.library.trips[0])
    return List {
        TripLookupResultsSection(tripID: model.library.trips[0].id, controller: TripController(model: model))
    }.dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif
