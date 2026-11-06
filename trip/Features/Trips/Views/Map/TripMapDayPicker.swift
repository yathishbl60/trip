import SwiftUI
import TripDomain
import TripLocalization

struct TripMapDayPicker: View {
    let controller: TripMapController
    var inStopList = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Menu {
            Picker(TripText.day.resource, selection: controller.daySelection(reduceMotion: reduceMotion)) {
                ForEach(controller.model.trip?.days ?? []) { day in
                    Text("\(day.title) · \(day.placeCountText)").tag(Optional(day.id))
                }
            }
            .pickerStyle(.inline)
        } label: {
            Label(controller.model.day?.title ?? TripText.day.text, systemImage: "calendar")
                .frame(minWidth: inStopList ? AppTheme.controlTarget : nil,
                       minHeight: inStopList ? AppTheme.controlTarget : nil, alignment: .leading)
                .contentShape(.rect)
        }
        .disabled(controller.model.trip?.days.isEmpty != false)
    }
}

#if DEBUG
#Preview("Day selection · local itinerary") {
    let model = TripMapPreview.planner()
    TripMapDayPicker(controller: TripMapController(model: TripMapPreview.map(model)))
}
#endif
