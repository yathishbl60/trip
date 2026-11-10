import SwiftUI
import TripDomain
import TripRouting
import TripLocalization

struct MapTravelComparisonView: View {
    @State var model: MapTravelComparisonModel
    @Environment(\.scenePhase) private var scenePhase
    private var controller: MapTravelController { MapTravelController(model: model) }

    var body: some View {
        List {
            options
            status
            Section {
                ForEach(model.places) { MapTravelComparisonRow(place: $0, controller: controller) }
            } header: { Text(TripText.chooseComparisonPlaces.resource) }
              footer: { Text(TripText.travelComparisonExplanation.resource) }
        }
        .navigationTitle(TripText.compareTravelTimes.resource).navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .contentMargins(.top, AppTheme.Spacing.small, for: .scrollContent)
        .toolbar { progress }
        .task(id: MapTravelTaskID(selection: model.request, isActive: scenePhase == .active)) {
            if scenePhase == .active { await controller.load() }
        }
    }

    private var progress: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            ProgressView().controlSize(.small).opacity(model.isLoading ? 1 : 0)
                .accessibilityLabel(TripText.loadingTravelTimes.resource).accessibilityHidden(!model.isLoading)
        }
        #if os(iOS)
        .sharedBackgroundVisibility(.hidden)
        #endif
    }

    private var options: some View {
        Section {
            Picker(TripText.travelFrom.resource, selection: controller.origin) {
                Text(TripText.myLocation.resource).tag("current")
                ForEach(model.origins) { origin in
                    Text("\(origin.title) · \(origin.subtitle)").tag(origin.id)
                }
            }.pickerStyle(.navigationLink)
            Picker(TripText.travelMode.resource, selection: controller.mode) {
                ForEach([TravelMode.walking, .driving], id: \.self) { mode in
                    Label(mode.title, systemImage: mode.symbol).tag(mode)
                }
            }
        }
    }

    @ViewBuilder private var status: some View {
        if let error = model.locationFailure {
            Text(error).foregroundStyle(.secondary)
            Button(TripText.tryAgain.resource, action: controller.retry)
        }
        if !model.failures.isEmpty {
            Button(TripText.retryUnavailableEstimates.resource, systemImage: "arrow.clockwise", action: controller.retry)
        }
    }
}

#if DEBUG
#Preview("Travel comparison · choose local places, no requests") {
    NavigationStack {
        MapTravelComparisonView(model: MapTravelComparisonModel(places: [PreviewFixtures.hotel, PreviewFixtures.longName], groups: []))
    }.dynamicTypeSize(.accessibility2)
}
#endif
