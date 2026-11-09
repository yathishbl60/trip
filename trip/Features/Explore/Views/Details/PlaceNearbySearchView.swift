import TripLocalization
import SwiftUI
import TripDomain

struct PlaceNearbySearchView: View {
    let controller: PlaceController
    @State private var model: PlaceNearbySearchModel
    @Environment(\.scenePhase) private var scenePhase

    init(origin: Place, controller: PlaceController, model: PlaceNearbySearchModel? = nil) {
        self.controller = controller
        _model = State(initialValue: model ?? PlaceNearbySearchModel(origin: origin))
    }

    var body: some View {
        List {
            options
            content
        }
            .navigationTitle(TripText.nearbyPlaces.resource)
            .navigationBarTitleDisplayMode(.inline).scrollContentBackground(.hidden)
            .modifier(PlacePanelContentVisibility(isCompact: controller.model.selection.presentation.isCompact))
            #if os(iOS)
            .scrollEdgeEffectStyle(.soft, for: .top)
            #endif
            .task(id: PlaceNearbyRequestID(revision: model.retryRevision, isActive: scenePhase == .active)) {
                if scenePhase == .active { await PlaceNearbySearchController(model: model).load() }
            }
    }

    private var options: some View {
        Section {
            Picker(TripText.nearbyCategory.resource, selection: PlaceNearbySearchController(model: model).category) {
                ForEach(NearbyPlaceCategory.allCases) { Text($0.title.resource).tag($0) }
            }
            Picker(TripText.nearbyDistance.resource, selection: PlaceNearbySearchController(model: model).radius) {
                ForEach(NearbySearchRadius.allCases) { Text($0.title).tag($0) }
            }
        } footer: { Text(TripText.nearValue(model.origin.name).resource) }
    }

    @ViewBuilder private var content: some View {
        if model.isLoading { ProgressView(TripText.findingNearbyPlaces.resource) }
        if let error = model.error {
            Text(error).foregroundStyle(.secondary)
            Button(TripText.tryAgain.resource, systemImage: "arrow.clockwise") { PlaceNearbySearchController(model: model).retry() }
        } else if model.places.isEmpty, !model.isLoading {
            ContentUnavailableView(TripText.noNearbyPlaces.resource, systemImage: "mappin.slash",
                                   description: Text(TripText.noOtherValueWereFoundHere(model.category.title.text.lowercased()).resource))
        }
        if !model.places.isEmpty {
            Section {
                ForEach(model.places) { place in
                    Button { controller.selectNearby(place) } label: { PlaceChoiceRow(place: place) }
                        .buttonStyle(.plain)
                }
            } header: { Text(TripText.nearValue(model.origin.name).resource) }
        }
    }
}

#if DEBUG
#Preview("Nearby search · local results") {
    let origin = PreviewFixtures.hotel
    NavigationStack {
        PlaceNearbySearchView(origin: origin, controller: PlaceController(model: PreviewFixtures.explore()),
                              model: PlaceNearbySearchModel(origin: origin, results: [PreviewFixtures.longName]))
    }
}
#Preview("Nearby search · empty, large text") {
    let origin = PreviewFixtures.hotel
    NavigationStack {
        PlaceNearbySearchView(origin: origin, controller: PlaceController(model: PreviewFixtures.explore()),
                              model: PlaceNearbySearchModel(origin: origin, results: []))
    }.dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif
