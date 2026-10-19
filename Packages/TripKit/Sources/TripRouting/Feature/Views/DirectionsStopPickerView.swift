#if !TRIP_STANDALONE
import TripLocalization
#endif
#if os(iOS) || os(visionOS)
import SwiftUI
import TripDomain

struct DirectionsStopPickerView: View {
    let controller: DirectionsController
    let session: DirectionsPlacePicker
    var showsCancel = false

    var body: some View {
        List { searchRows }
            .navigationTitle(session.title)
            #if os(iOS)
            .scrollEdgeEffectStyle(.soft, for: .top)
            #endif
            .searchable(text: controller.stopQuery(for: session),
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: Text(TripText.placeOrAddress.resource))
            .textInputAutocapitalization(.words).autocorrectionDisabled()
            .onSubmit(of: .search) { controller.loadStops(session: session) }
            #if os(iOS)
            .scrollDismissesKeyboard(.interactively)
            #endif
            .toolbar { pickerTools }
            .onAppear { controller.loadStops(session: session) }.onDisappear { controller.stopSearching(session: session) }
            .id(session.id)
    }

    @ToolbarContentBuilder private var pickerTools: some ToolbarContent {
        if showsCancel {
            ToolbarItem(placement: .cancellationAction) {
                Button(TripText.cancel.resource) { controller.cancelPlacePicker(session: session) }
            }
        }
    }

    @ViewBuilder private var searchRows: some View {
        if session.target == .origin, controller.model.canUseMyLocation {
            Button { controller.useMyLocation(session: session) } label: {
                Label(TripText.myLocation.resource, systemImage: "location.fill")
            }
            .tint(.primary)
        }
        if controller.model.stopSearch.isLoading { ProgressView(TripText.searching.resource) }
        DirectionsSearchStatusView(controller: controller, session: session)
        ForEach(controller.model.availableStops) { place in
            Button { controller.choosePlace(place, session: session) } label: { placeLabel(place) }.tint(.primary)
        }
    }

    private func placeLabel(_ place: Place) -> some View {
        HStack(spacing: 14) {
            Image(systemName: place.category.symbol).foregroundStyle(.primary)
                .frame(width: 36, height: 36)
                .background(controller.model.environment.placeTint(place).opacity(0.14), in: .circle)
            VStack(alignment: .leading, spacing: 4) {
                Text(place.name).font(.headline)
                if let address = place.address { Text(address).font(.subheadline).foregroundStyle(.secondary).lineLimit(2) }
            }
        }
        .padding(.vertical, 6)
    }
}

#if DEBUG
#Preview("Add Stop · local catalog") {
    let model = DirectionsPreviewFixtures.ready()
    model.beginAddingStop()
    return NavigationStack {
        if let session = model.presentation.placePicker {
            DirectionsStopPickerView(controller: DirectionsController(model: model), session: session)
        }
    }
}
#Preview("Starting point · My Location available") {
    let model = DirectionsPreviewFixtures.ready()
    model.changeOrigin()
    return NavigationStack {
        if let session = model.presentation.placePicker {
            DirectionsStopPickerView(controller: DirectionsController(model: model), session: session)
        }
    }
}
#Preview("Starting point · no location permission") {
    let model = DirectionsPreviewFixtures.withoutLocation()
    model.changeOrigin()
    return NavigationStack {
        if let session = model.presentation.placePicker {
            DirectionsStopPickerView(controller: DirectionsController(model: model), session: session)
        }
    }
}
#endif
#endif
