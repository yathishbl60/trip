import SwiftUI
import TripDomain

/// Save sheets belong to the host that composes Explore and Trips.
struct AppExploreView: View {
    let controller: AppController
    @Namespace private var saveNamespace

    var body: some View {
        MapExperienceView(model: controller.model.explore) { place, placeController in
            PlaceDetailView(place: place, controller: placeController)
                .environment(\.tripPresentationNamespace, saveNamespace)
                .safeAreaInset(edge: .bottom, spacing: 0) { placeFeedback }
                .sheet(item: TripController(model: controller.model.trips).pendingPlace) {
                    TripSaveView(place: $0, controller: TripController(model: controller.model.trips))
                        .modifier(TripPresentationZoom(id: $0.id, namespace: saveNamespace))
                }
        }
        .sheet(item: controller.mapSaveDestination) {
            TripSaveView(place: $0, controller: TripController(model: controller.model.trips))
        }
    }

    @ViewBuilder private var placeFeedback: some View {
        if controller.model.trips.feedback.message != nil {
            TripFeedbackView(model: controller.model.trips.feedback)
                .padding(.bottom, AppTheme.Spacing.small)
        }
    }

}

#if DEBUG
#Preview("Explore with trip saving · local data") {
    AppExploreView(controller: AppController(model: PreviewFixtures.app()))
}
#Preview("Save from map context menu · local data") {
    let model = PreviewFixtures.app()
    model.trips.chooseDestination(for: PreviewFixtures.hotel)
    return AppExploreView(controller: AppController(model: model))
}
#Preview("Save from place details · dark") {
    let model = PreviewFixtures.app()
    model.explore.select(PreviewFixtures.hotel)
    model.trips.chooseDestination(for: PreviewFixtures.hotel)
    return AppExploreView(controller: AppController(model: model)).preferredColorScheme(.dark)
}
#Preview("Save confirmation inside place sheet · local data") {
    let model = PreviewFixtures.app()
    model.explore.select(PreviewFixtures.hotel)
    model.trips.feedback.message = "Added to Weekend · Day 1"
    return AppExploreView(controller: AppController(model: model))
}
#endif
