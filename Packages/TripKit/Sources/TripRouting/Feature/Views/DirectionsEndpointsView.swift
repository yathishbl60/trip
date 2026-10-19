#if !TRIP_STANDALONE
import TripLocalization
#endif
#if os(iOS) || os(visionOS)
import SwiftUI
import TripDomain

struct DirectionsEndpointsView: View {
    let controller: DirectionsController

    var body: some View {
        Group {
            origin
            ForEach(controller.directions.destinationPlaces) { place in
                Button { controller.changePlace(place) } label: {
                    row(place.name, symbol: place.category.symbol,
                        color: controller.model.environment.placeTint(place), editable: true)
                }
                .buttonStyle(.plain).hoverEffect(.highlight).accessibilityHint(TripText.changeThisStop.resource)
            }
            actions
        }
    }

    private var origin: some View {
        Button(action: controller.changeOrigin) {
            row(controller.model.startingPoint.title, symbol: controller.model.startingPoint.symbol,
                color: controller.model.startingPoint.place.map(controller.model.environment.placeTint) ?? .blue,
                editable: true)
        }
        .buttonStyle(.plain).hoverEffect(.highlight).accessibilityHint(TripText.chooseADifferentStartingPoint.resource)
    }

    private func row(_ title: String, symbol: String, color: Color, editable: Bool = false) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol).font(.body.weight(.semibold)).foregroundStyle(.primary)
                .frame(width: 36, height: 36).background(color.opacity(0.14), in: .circle)
            Text(title).foregroundStyle(.primary).fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            if editable { Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(.tertiary) }
        }
        .padding(.vertical, 4)
        .frame(minHeight: controlTarget)
        .contentShape(.rect)
    }

    private var actions: some View {
        HStack {
            addStop
            Spacer()
            if !controller.directions.stops.isEmpty {
                Button(action: controller.editStops) {
                    Label(TripText.editStops.resource, systemImage: "list.bullet").labelStyle(.iconOnly)
                        .frame(minWidth: controlTarget, minHeight: controlTarget)
                        .contentShape(.rect)
                }
            }
        }
        .font(.body)
        .buttonStyle(.borderless)
        .frame(minHeight: controlTarget)
    }

    private var addStop: some View {
        Button(action: controller.beginAddingStop) {
            Label(TripText.addStop.resource, systemImage: "plus.circle.fill")
                .frame(minHeight: controlTarget).contentShape(.rect)
        }.disabled(!controller.directions.canAddStop)
    }

    private var controlTarget: CGFloat {
        #if os(visionOS)
        60
        #else
        44
        #endif
    }
}

#if DEBUG
#Preview("Route endpoints · native rows") {
    List { Section { DirectionsEndpointsView(controller: DirectionsController(model: DirectionsPreviewFixtures.ready())) } }
}
#Preview("Long destination · large text, dark") {
    let model = DirectionsPreviewFixtures.ready()
    model.destination = DirectionsPreviewFixtures.longDestination
    return List { Section { DirectionsEndpointsView(controller: DirectionsController(model: model)) } }
        .dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#Preview("Searched starting point") {
    let model = DirectionsPreviewFixtures.ready()
    model.startingPoint.selection = .place(DirectionsPreviewFixtures.stop)
    return List { Section { DirectionsEndpointsView(controller: DirectionsController(model: model)) } }
}
#Preview("Location unavailable · choose starting point") {
    let model = DirectionsPreviewFixtures.withoutLocation()
    return List { Section { DirectionsEndpointsView(controller: DirectionsController(model: model)) } }
}
#endif
#endif
