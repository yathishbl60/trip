import SwiftUI
import TripDomain

struct TripMapStopsView: View {
    let map: TripMapController
    let trips: TripController
    var dayPickerInList = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScrollViewReader { proxy in
            list
                .onChange(of: map.model.listFocusRevision, initial: true) { revealSelection(using: proxy) }
                .onChange(of: map.model.day?.id) { _, id in
                    if let id { proxy.scrollTo(id, anchor: .top) }
                }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if !dayPickerInList {
                dayHeader.padding(AppTheme.Spacing.medium)
                    .background(.bar).overlay(alignment: .bottom) { Divider() }
            }
        }
    }

    private var list: some View {
        List {
            if let day = map.model.day {
                Section {
                    if dayPickerInList { dayHeader }
                    ForEach(map.model.stops) { stop in
                        TripMapStopRow(stop: stop, map: map, trips: trips).id(stop.id)
                            .listRowBackground(stop.id == map.model.selectedStopID ? AppTheme.accent.opacity(0.12) : nil)
                    }
                }.id(day.id)
            }
        }
        #if os(iOS)
        .scrollEdgeEffectStyle(.soft, for: .top)
        #endif
    }

    @ViewBuilder private var dayHeader: some View {
        if let day = map.model.day, let trip = map.model.trip {
            TripMapDayHeader(day: day, trip: trip, controller: trips, dayPicker: dayPickerInList ? map : nil)
        }
    }

    private func revealSelection(using proxy: ScrollViewProxy) {
        guard let id = map.model.selectedStopID else { return }
        withAnimation(AppTheme.Motion.selection(reduceMotion: reduceMotion)) { proxy.scrollTo(id, anchor: .center) }
    }
}

#if DEBUG
#Preview("Pin selection reveals a distant row · local") {
    let model = TripMapPreview.planner()
    let map = TripMapPreview.map(model, selecting: 9)
    TripMapStopsView(map: TripMapController(model: map), trips: TripController(model: model))
        .frame(width: 320, height: 420)
}
#Preview("Map stop list · large text, dark, local") {
    let model = TripMapPreview.planner()
    let map = TripMapPreview.map(model, selecting: 9)
    TripMapStopsView(map: TripMapController(model: map), trips: TripController(model: model))
        .frame(width: 320, height: 500).dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif
