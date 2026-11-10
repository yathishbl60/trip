import SwiftUI
import TripDomain
import TripLocalization

struct MapBrowseRow: View {
    let item: MapBrowseItem
    let controller: MapBrowseController
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.medium) {
            Button { controller.choose(item.place) } label: { information }
                .buttonStyle(.plain).frame(maxWidth: .infinity, alignment: .leading)
            if controller.model.canSavePlaces {
                PlaceSaveButton(place: item.place, controller: PlaceController(model: controller.model))
                    .labelStyle(.iconOnly).buttonStyle(.borderless)
            }
        }
    }

    private var information: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            TripPlaceLabel(title: item.place.name, subtitle: item.place.category.annotationTitle,
                           symbol: item.place.category.symbol, color: item.place.category.color)
            if let address = item.place.address {
                Text(address).font(.subheadline).foregroundStyle(.secondary)
                    .lineLimit(typeSize.isAccessibilitySize ? nil : 2)
            }
            Text(TripText.distanceFromMapCenter(item.distanceText).resource).font(.caption).foregroundStyle(.secondary)
            if let saved = controller.model.environment.savedPlaces(item.id).first {
                Label(saved.title, systemImage: "bookmark.fill").font(.caption).foregroundStyle(.secondary)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .contentShape(.rect).accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview("Map result · long name, large text") {
    List {
        MapBrowseRow(item: MapBrowseItem(place: PreviewFixtures.longName, distance: 350),
                     controller: MapBrowseController(model: PreviewFixtures.explore()))
    }.dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif
