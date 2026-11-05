import TripLocalization
import SwiftUI
import AppIntents
import TripDomain

struct TripMapStopRow: View {
    let stop: TripMapStop
    let map: TripMapController
    let trips: TripController
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.small) {
            focusButton
            if stop.place.coordinate.isValid {
                Menu {
                    TripMapPlaceActions(stop: stop, controller: trips)
                } label: {
                    Image(systemName: "ellipsis")
                        .frame(minWidth: AppTheme.controlTarget, minHeight: AppTheme.controlTarget)
                }
                .buttonStyle(.borderless)
                .accessibilityLabel(TripText.actionsForValue(stop.place.name).resource)
            }
        }
        .appEntityIdentifier(trips.detailEntityIdentifier(tripID: map.model.tripID, itemID: stop.id))
    }

    private var focusButton: some View {
        Button { map.selectStop(stop.id, reduceMotion: reduceMotion) } label: {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.tight) {
                TripNumberedStopRow(place: stop.place, number: stop.number, isSelected: stop.id == map.model.selectedStopID)
                if !stop.place.coordinate.isValid {
                    Text(TripText.mapLocationUnavailable.resource).font(.footnote).foregroundStyle(.secondary)
                }
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain).hoverEffect(.highlight)
        .disabled(!stop.place.coordinate.isValid)
        .accessibilityAddTraits(stop.id == map.model.selectedStopID ? .isSelected : [])
        .accessibilityHint(stop.place.coordinate.isValid ? TripText.focusOnMap.text : TripText.mapLocationUnavailable.text)
    }
}

#if DEBUG
#Preview("Stop actions · real list, local") {
    let model = TripMapPreview.planner()
    let map = TripMapPreview.map(model, selecting: 9)
    List(map.stops) { stop in
        TripMapStopRow(stop: stop, map: TripMapController(model: map), trips: TripController(model: model))
    }.frame(width: 320, height: 500).dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif
