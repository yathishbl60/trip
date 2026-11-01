import TripLocalization
import TripDomain
import SwiftUI

struct TripCollectionView: View {
    let tripID: UUID
    let collectionID: UUID
    let controller: TripController

    var body: some View {
        Group {
            if let collection = controller.model.library.trip(tripID)?.collections.first(where: { $0.id == collectionID }) {
                content(collection)
            } else {
                ContentUnavailableView(TripText.collectionUnavailable.resource, systemImage: "square.stack")
            }
        }
    }

    private func content(_ collection: TripCollection) -> some View {
        List {
            if let notice = controller.model.presentation.notice { Text(notice).foregroundStyle(.secondary) }
            if collection.stops.isEmpty {
                ContentUnavailableView(TripText.noSavedPlaces.resource, systemImage: "bookmark",
                                       description: Text(TripText.savePlacesFromTheMapToThisCollection.resource))
            }
            ForEach(collection.stops) { stop in stopRow(stop) }
                .onDelete { controller.removeCollectionStops($0, from: collection, tripID: tripID) }
                .onMove { controller.moveCollectionStops($0, to: $1, in: collection, tripID: tripID) }
        }
        .navigationTitle(collection.title)
        #if os(iOS)
        .scrollEdgeEffectStyle(.soft, for: .top)
        #endif
        .toolbar { EditButton() }
    }

    private func stopRow(_ stop: TripStop) -> some View {
        HStack {
            TripStopRow(stop: stop, controller: controller, showsMapIndicator: false)
            Menu {
                ForEach(controller.model.library.trip(tripID)?.days ?? []) { day in
                    Button(day.title) { controller.schedule(stop.place, on: day.id, tripID: tripID) }
                }
            } label: {
                Label(TripText.addToDay.resource, systemImage: "calendar.badge.plus").labelStyle(.iconOnly)
                    .frame(minWidth: AppTheme.controlTarget, minHeight: AppTheme.controlTarget)
                    .contentShape(.rect)
            }.buttonStyle(.borderless)
                .accessibilityLabel(TripText.addToDay.resource)
                .accessibilityValue(stop.place.name)
        }
    }
}

#if DEBUG
#Preview("Saved places collection") {
    let model = PreviewFixtures.tripPlanner()
    NavigationStack {
        TripCollectionView(tripID: model.library.trips[0].id,
                           collectionID: model.library.trips[0].collections[0].id,
                           controller: TripController(model: model))
    }
}
#Preview("Collection · large text") {
    let model = PreviewFixtures.tripPlanner()
    NavigationStack {
        TripCollectionView(tripID: model.library.trips[0].id,
                           collectionID: model.library.trips[0].collections[0].id,
                           controller: TripController(model: model))
    }.dynamicTypeSize(.accessibility2)
}
#endif
