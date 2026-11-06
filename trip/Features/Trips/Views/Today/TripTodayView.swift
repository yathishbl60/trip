import TripLocalization
import SwiftUI
import TripDomain

struct TripTodayView: View {
    let tripID: UUID
    let controller: TripController
    var previewDate: Date? = nil
    @Environment(\.tripHingePartiallyOpen) private var partiallyOpen

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            if let today = controller.today(tripID, at: previewDate ?? context.date) { content(today) }
            else { ContentUnavailableView(TripText.tripUnavailable.resource, systemImage: "suitcase.rolling") }
        }
        .navigationTitle(TripText.today.resource).navigationBarTitleDisplayMode(.inline)
        .tripWayfinding(.today, tripID: tripID, controller: controller)
        #if os(iOS)
        .scrollEdgeEffectStyle(.soft, for: .top)
        #endif
    }

    private func content(_ today: TripTodayModel) -> some View {
        GeometryReader { geometry in
            let frame = partiallyOpen ? TripPaneDivision.activeFrame(in: geometry) : nil
            TripTodayContentView(tripID: tripID, today: today, controller: controller,
                                 division: TripPaneDivision(frame, in: geometry.size))
        }
    }
}

#if DEBUG
#Preview("Today · saved plans") {
    let model = TripTodayPreview.planner()
    NavigationStack { TripTodayView(tripID: model.library.trips[0].id, controller: TripController(model: model),
                                   previewDate: TripTodayPreview.now) }
}
#Preview("Today · review · accessibility · dark") {
    let model = TripTodayPreview.planner(review: true)
    NavigationStack { TripTodayView(tripID: model.library.trips[0].id, controller: TripController(model: model),
                                   previewDate: TripTodayPreview.now) }
    .dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#Preview("Today · no scheduled day") {
    let model = TripTodayPreview.planner()
    NavigationStack { TripTodayView(tripID: model.library.trips[0].id, controller: TripController(model: model),
                                   previewDate: TripTodayPreview.now.addingTimeInterval(-86400)) }
}
#Preview("Today · large text, local itinerary") {
    let model = TripTodayPreview.planner()
    NavigationStack { TripTodayView(tripID: model.library.trips[0].id, controller: TripController(model: model),
                                   previewDate: TripTodayPreview.now) }
        .frame(width: 320).dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif
