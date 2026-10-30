import TripLocalization
import TripDomain
import SwiftUI

struct PlaceActionsView: View {
    let place: Place
    let controller: PlaceController
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        Group {
            if typeSize.isAccessibilitySize { stackedActions }
            else {
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: AppTheme.Spacing.medium) { primaryActions }
                        .fixedSize()
                    stackedActions
                }
            }
        }
        .controlSize(.large)
        .buttonSizing(.fitted)
        .labelStyle(.titleAndIcon)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var stackedActions: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) { primaryActions }
    }

    @ViewBuilder private var primaryActions: some View {
        Button {
            ExploreDirectionsController(model: controller.model).begin(place)
        } label: {
            Label(TripText.directions.resource, systemImage: "arrow.triangle.turn.up.right.diamond")
                .fixedSize(horizontal: false, vertical: true)
        }
        .buttonStyle(.borderedProminent)
        .tint(AppTheme.accentFill)
        if controller.model.canSavePlaces {
            Button { controller.save(place) } label: {
                Label(TripText.save.resource, systemImage: "bookmark")
                    .fixedSize(horizontal: false, vertical: true)
            }
            .buttonStyle(.bordered).accessibilityLabel(TripText.saveToTrip.resource)
        }
    }
}

#if DEBUG
#Preview("Place actions · compact", traits: .sizeThatFitsLayout) {
    PlaceActionsView(place: PreviewFixtures.hotel, controller: PlaceController(model: PlaceDetailPreviewFixtures.saving()))
        .frame(width: 300).padding()
}
#Preview("Place actions · accessibility", traits: .sizeThatFitsLayout) {
    PlaceActionsView(place: PreviewFixtures.longName, controller: PlaceController(model: PlaceDetailPreviewFixtures.saving()))
        .frame(width: 320).padding().dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#Preview("Place actions · narrow sheet", traits: .sizeThatFitsLayout) {
    PlaceActionsView(place: PreviewFixtures.hotel, controller: PlaceController(model: PlaceDetailPreviewFixtures.saving()))
        .frame(width: 240).padding()
}
#Preview("Place actions · wide sheet", traits: .sizeThatFitsLayout) {
    PlaceActionsView(place: PreviewFixtures.hotel, controller: PlaceController(model: PlaceDetailPreviewFixtures.saving()))
        .frame(width: 520).padding()
}
#Preview("Place actions · inset List row") {
    List {
        Section {
            VStack(alignment: .leading, spacing: AppTheme.spacing) {
                PlaceDetailInformationView(place: PreviewFixtures.hotel)
                PlaceActionsView(place: PreviewFixtures.hotel,
                                 controller: PlaceController(model: PlaceDetailPreviewFixtures.saving()))
            }
            .listRowBackground(Color.clear).listRowSeparator(.hidden)
        }
    }
    .listStyle(.insetGrouped).scrollContentBackground(.hidden)
    .frame(width: 320, height: 440)
}
#Preview("Place actions · tall parent") {
    VStack(alignment: .leading) {
        PlaceActionsView(place: PreviewFixtures.hotel,
                         controller: PlaceController(model: PlaceDetailPreviewFixtures.saving()))
        Spacer()
    }.padding().frame(width: 320, height: 600)
}
#Preview("Place actions · standalone without Save", traits: .sizeThatFitsLayout) {
    PlaceActionsView(place: PreviewFixtures.hotel, controller: PlaceController(model: PreviewFixtures.explore()))
        .frame(width: 240).padding()
}
#endif
