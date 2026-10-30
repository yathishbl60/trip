import MapKit
import SwiftUI
import TripDomain

/// The detail screen owns loading; scrolling its lazy list must not cancel requests.
struct PlaceLookAroundPresentation: ViewModifier {
    let coordinate: Coordinate
    let model: PlaceLookAroundModel
    @Environment(\.scenePhase) private var scenePhase

    func body(content: Content) -> some View {
        content
            .lookAroundViewer(isPresented: PlaceLookAroundController(model: model).viewerPresentation,
                              initialScene: model.scene, pointsOfInterest: .excludingAll)
            .onDisappear { PlaceLookAroundController(model: model).cancel() }
            .onChange(of: coordinate) { PlaceLookAroundController(model: model).reset() }
            .onChange(of: scenePhase) {
                if scenePhase == .background { PlaceLookAroundController(model: model).cancel() }
            }
    }
}

#if DEBUG
#Preview("Look Around · detail-owned presentation") {
    @Previewable @State var model = PlaceLookAroundModel()
    NavigationStack {
        List { PlaceLookAroundView(place: PreviewFixtures.hotel, model: model) }
    }
    .modifier(PlaceLookAroundPresentation(coordinate: PreviewFixtures.hotel.coordinate, model: model))
}
#endif
