import MapEngine
import SwiftUI

struct NativePlaceAnnotationView: View {
    let marker: MarkerModel
    let controller: PlaceController
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let revision = marker.presentationRevision
        artwork
            .onAppear { controller.appeared(marker, revision: revision) }
            // Reset unseen reentry artwork; the enclosing map annotation keeps its place identity.
            .id(revision)
            .transition(.identity)
            .transaction { $0.animation = nil }
            .accessibilityHidden(!marker.hasAppeared)
            .allowsHitTesting(marker.hasAppeared)
            .contextMenu { PlaceContextMenu(place: marker.place, controller: controller) }
            .hoverEffect(.highlight)
    }

    private var artwork: some View {
        PlaceMarkerView(place: marker.place, style: marker.style, scale: marker.scale,
                        isSelected: marker.isSelected, includesPhoto: marker.hasPhotoContent,
                        includesLabel: marker.hasLabelContent, animatesChanges: marker.hasAppeared,
                        motion: marker.motion)
            .animation(reduceMotion ? nil : .easeOut(duration: marker.motion.fade)) { content in
                content.opacity(marker.opacity)
            }
    }
}

#if DEBUG
#Preview("Native annotation content", traits: .sizeThatFitsLayout) {
    NativePlaceAnnotationView(
        marker: MarkerModel(placement: MarkerPlacement(place: PreviewFixtures.hotel, style: .card), scale: 1),
        controller: PlaceController(model: PreviewFixtures.explore()))
        .padding(24)
}
#Preview("Subtle entry · replay", traits: .sizeThatFitsLayout) {
    @Previewable @State var isShown = true
    VStack(spacing: 24) {
        if isShown {
            NativePlaceAnnotationView(
                marker: MarkerModel(placement: MarkerPlacement(place: PreviewFixtures.hotel, style: .card), scale: 1),
                controller: PlaceController(model: PreviewFixtures.explore()))
        }
        Button("Toggle annotation") { isShown.toggle() }
    }
    .frame(width: 240, height: 260)
}
#Preview("Card → hidden → dot · stable map identity", traits: .sizeThatFitsLayout) {
    @Previewable @State var marker = MarkerModel(
        placement: MarkerPlacement(place: PreviewFixtures.hotel, style: .card), scale: 1)
    VStack(spacing: 20) {
        NativePlaceAnnotationView(marker: marker, controller: PlaceController(model: PreviewFixtures.explore()))
            .frame(width: 200, height: 220)
        Button("Hide card") { marker.retire() }
        Button("Reappear as dot") {
            marker.update(MarkerPlacement(place: marker.place, style: .dot), scale: 1, reduceMotion: false)
        }
        Button("Promote visible dot to card") {
            marker.update(MarkerPlacement(place: marker.place, style: .card), scale: 1, reduceMotion: false)
        }
    }
    .frame(width: 360).padding()
}
#Preview("Detailed view · animation disabled", traits: .sizeThatFitsLayout) {
    NativePlaceAnnotationView(
        marker: MarkerModel(placement: MarkerPlacement(place: PreviewFixtures.hotel, style: .card),
                            scale: 1, motion: MapMotion(morph: 0, fade: 0)),
        controller: PlaceController(model: PreviewFixtures.explore()))
        .padding(24)
}
#Preview("First promotion · deferred photo and label", traits: .sizeThatFitsLayout) {
    @Previewable @State var marker = MarkerModel(
        placement: MarkerPlacement(place: PreviewFixtures.hotel, style: .dot), scale: 1)
    VStack(spacing: 24) {
        NativePlaceAnnotationView(marker: marker, controller: PlaceController(model: PreviewFixtures.explore()))
            .frame(width: 250, height: 200)
        Button("Promote to card") {
            marker.update(MarkerPlacement(place: marker.place, style: .card), scale: 1, reduceMotion: false)
        }
        Button("Return to dot") {
            marker.update(MarkerPlacement(place: marker.place, style: .dot), scale: 1, reduceMotion: false)
        }
    }.padding()
}
#endif
