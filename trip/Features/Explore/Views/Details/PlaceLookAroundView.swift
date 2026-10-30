import TripLocalization
import MapKit
import SwiftUI
import TripDomain

struct PlaceLookAroundView: View {
    let place: Place
    let model: PlaceLookAroundModel

    var body: some View {
        content
    }

    @ViewBuilder private var content: some View {
        switch model.state {
        case .idle: loadButton
        case .loading: loading
        case .available:
            streetPreview
        case .unavailable:
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                Label(TripText.noStreetImageryHere.resource, systemImage: "binoculars")
                Text(TripText.appleMapsDoesnTHaveLookAroundCoverageAt.resource)
                    .font(.subheadline).foregroundStyle(.secondary)
            }
        case .failed(let message): failure(message)
        }
    }

    private var streetPreview: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            LookAroundPreview(initialScene: model.scene, pointsOfInterest: .excludingAll)
                .frame(height: 210)
            Button(TripText.exploreLookAround.resource, systemImage: "binoculars") {
                PlaceLookAroundController(model: model).showViewer()
            }
            .buttonStyle(.borderless)
        }
    }

    private var loadButton: some View {
        Button { PlaceLookAroundController(model: model).load(place) } label: {
            Label(TripText.lookAround.resource, systemImage: "binoculars")
        }
    }

    private var loading: some View {
        ViewThatFits(in: .horizontal) {
            HStack {
                ProgressView(TripText.loadingLookAround.resource).fixedSize()
                Spacer()
                cancelButton
            }
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                ProgressView(TripText.loadingLookAround.resource)
                cancelButton
            }
        }
    }

    private var cancelButton: some View {
        Button(TripText.cancel.resource) { PlaceLookAroundController(model: model).cancel() }
            .buttonStyle(.borderless)
    }

    private func failure(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            Text(message).font(.subheadline).foregroundStyle(.secondary)
            Button(TripText.tryAgain.resource, systemImage: "arrow.clockwise") {
                PlaceLookAroundController(model: model).load(place)
            }
        }
    }
}

#if DEBUG
#Preview("Look Around · ready to explore") {
    List { PlaceLookAroundView(place: PlaceDetailPreviewFixtures.live, model: PlaceLookAroundModel()) }
}
#Preview("Look Around · loading") {
    List { PlaceLookAroundView(place: PreviewFixtures.hotel, model: PlaceLookAroundModel(state: .loading)) }
}
#Preview("Look Around · no coverage, large text") {
    List { PlaceLookAroundView(place: PreviewFixtures.hotel, model: PlaceLookAroundModel(state: .unavailable)) }
        .dynamicTypeSize(.accessibility2)
}
#Preview("Look Around · retry, dark") {
    List { PlaceLookAroundView(place: PreviewFixtures.hotel,
                              model: PlaceLookAroundModel(state: .failed("Look Around couldn’t load. Try again."))) }
        .preferredColorScheme(.dark)
}
#endif
