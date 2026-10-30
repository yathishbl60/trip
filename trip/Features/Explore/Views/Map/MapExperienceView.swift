import TripLocalization
import TripRouting
import TripDomain
import SwiftUI

struct MapExperienceView<Detail: View>: View {
    let model: ExploreModel
    @Environment(\.scenePhase) private var scenePhase
    private let detail: (Place, PlaceController) -> Detail

    init(model: ExploreModel, @ViewBuilder detail: @escaping (Place, PlaceController) -> Detail) {
        self.model = model
        self.detail = detail
    }

    var body: some View {
        NavigationStack { workspace }
        .searchable(text: CatalogController(model: model).query,
                    isPresented: CatalogController(model: model).searchPresentation,
                    prompt: Text(TripText.searchPlaces.resource))
        .searchSuggestions { MapSearchSuggestionsView(controller: CatalogController(model: model)) }
        .searchToolbarBehavior(.minimize)
        .onSubmit(of: .search) { CatalogController(model: model).search() }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .toolbarBackground(.clear, for: .navigationBar)
        .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        .sheet(item: PlaceController(model: model).mapSheet, content: sheet)
        .sheet(isPresented: FilterController(model: model).presentation) {
            FilterPanelView(controller: FilterController(model: model))
        }
        .task(id: scenePhase) { await CatalogController(model: model).start(scenePhase) }
        .onDisappear { MapController(model: model).stop() }
    }

    @ViewBuilder private func sheet(_ destination: ExploreSheet) -> some View {
        switch destination {
        case .details: PlaceDetailsSheetView(model: model, detail: detail)
        case .directions: DirectionsSheetView(model: model.directions)
        }
    }

    private var workspace: some View {
        MapCanvasView(controller: MapController(model: model))
            .navigationBarTitleDisplayMode(.inline)
            #if os(iOS)
            .scrollEdgeEffectStyle(.soft, for: .top)
            #endif
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
            .toolbar { ExploreToolbar(controller: MapController(model: model)) }
            .modifier(MapAppearanceRestoration(controller: MapAppearanceController(model: model.appearance)))
    }
}

#if DEBUG
#Preview("Explore · local hotel provider") {
    MapExperienceView(model: PreviewFixtures.hotels()) { place, controller in
        PlaceDetailView(place: place, controller: controller)
    }
}
#Preview("Custom details · dark") {
    MapExperienceView(model: PreviewFixtures.hotels()) { place, _ in
        Text(place.name).font(.title).padding()
    }.preferredColorScheme(.dark)
}
#Preview("Inline search · Close and reopen") {
    let model = PreviewFixtures.explore()
    model.catalog.setSearchPresented(true)
    return MapExperienceView(model: model) { place, controller in
        PlaceDetailView(place: place, controller: controller)
    }
}
#Preview("Active filters · large text, dark") {
    @Previewable @State var model = PreviewFixtures.explore(categories: [.hotel, .cafe])
    MapExperienceView(model: model) { place, controller in
        PlaceDetailView(place: place, controller: controller)
    }.dynamicTypeSize(.accessibility1).preferredColorScheme(.dark)
}
#Preview("Full-screen Explore · landscape", traits: .landscapeLeft) {
    @Previewable @State var model = PreviewFixtures.explore()
    MapExperienceView(model: model) { place, controller in
        PlaceDetailView(place: place, controller: controller)
    }
}
#Preview("Place sheet · stable attribution") {
    let model = PreviewFixtures.explore()
    model.select(PreviewFixtures.hotel)
    return MapExperienceView(model: model) { place, controller in
        PlaceDetailView(place: place, controller: controller)
    }
}
#Preview("Map interactions · animations disabled") {
    MapExperienceView(model: PreviewFixtures.mapWithoutAnimations()) { place, controller in
        PlaceDetailView(place: place, controller: controller)
    }
}
#endif
