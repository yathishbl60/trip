import MapKit
import SwiftUI
import TripDomain
import TripLocalization

struct PlaceNativeCardView: View {
    let place: Place
    @State private var model = PlaceCardModel()
    @Environment(\.scenePhase) private var scenePhase
    private var controller: PlaceCardController { PlaceCardController(model: model) }

    var body: some View {
        action
            .mapItemDetailSheet(item: controller.item, displaysMap: true)
            .alert(TripText.couldNotLoadAppleDetails.resource, isPresented: controller.failure) {
                Button(TripText.tryAgain.resource) { controller.open(place) }
                Button(TripText.cancel.resource, role: .cancel) {}
            } message: { Text(TripText.checkConnectionAndTryAgain.resource) }
            .onDisappear(perform: controller.cancel)
            .onChange(of: scenePhase) { if scenePhase != .active { controller.cancel() } }
    }

    private var action: some View {
        Button { controller.open(place) } label: {
            HStack {
                Label(TripText.appleMapsDetails.resource, systemImage: "info.circle")
                Spacer()
                if model.isLoading { ProgressView().accessibilityLabel(TripText.loading.resource) }
            }
        }.disabled(model.isLoading)
    }
}

#if DEBUG
#Preview("Native Apple details · available action, no request") {
    let place = Place(id: "I123456789", name: "Museum", coordinate: .bangkok, category: .museum,
                      importance: 1, rating: nil, reviews: nil, isLive: true)
    NavigationStack { List { PlaceNativeCardView(place: place) } }
}
#endif
