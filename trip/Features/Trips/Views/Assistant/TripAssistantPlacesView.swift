import TripLocalization
import TripDomain
import SwiftUI

struct TripAssistantPlacesView: View {
    let controller: TripController

    var body: some View {
        List {
            Section {
                ForEach(controller.model.assistant.selection.filteredPlaces) { place in
                    placeRow(place)
                }
            } header: {
                Text(controller.model.assistant.selection.summary)
            } footer: {
                Text(TripText.upToValuePlaces(TripText.number(TripLimits.planningPlaces)).resource)
            }
        }
        .navigationTitle(TripText.choosePlaces.resource)
        #if os(iOS)
        .scrollEdgeEffectStyle(.soft, for: .top)
        #endif
        .searchable(text: controller.planningPlaceQuery, prompt: Text(TripText.findASavedPlace.resource))
        .overlay { emptySearch }
        .toolbar { selectionTools }
    }

    private func placeRow(_ place: Place) -> some View {
        Toggle(isOn: controller.planningPlaceSelected(place.id)) {
            TripPlaceLabel(title: place.name, subtitle: place.category.annotationTitle,
                           symbol: place.category.symbol, color: place.category.color)
        }
        .disabled(!controller.model.assistant.selection.canSelect(place.id))
    }

    @ViewBuilder private var emptySearch: some View {
        if controller.model.assistant.selection.filteredPlaces.isEmpty {
            ContentUnavailableView.search(text: controller.model.assistant.selection.query)
        }
    }

    @ToolbarContentBuilder private var selectionTools: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu(TripText.selection.resource, systemImage: "checklist") {
                if controller.model.assistant.selection.canSelectAll {
                    Button(TripText.selectAll.resource) { controller.selectAllPlanningPlaces(true) }
                }
                Button(TripText.clearSelection.resource) { controller.selectAllPlanningPlaces(false) }
            }
        }
    }
}

#if DEBUG
#Preview("Choose saved places") {
    let model = PreviewFixtures.tripPlanner()
    model.assistant.reset(for: model.library.trips[0])
    return NavigationStack { TripAssistantPlacesView(controller: TripController(model: model)) }
}
#Preview("Choose saved places · accessibility") {
    let model = PreviewFixtures.tripPlanner()
    model.assistant.reset(for: model.library.trips[0])
    return NavigationStack { TripAssistantPlacesView(controller: TripController(model: model)) }
        .dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif
