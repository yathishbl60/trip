import SwiftUI
import TripDomain

struct TripChecklistSection: View {
    let title: String
    let items: [TripChecklistItem]
    let tripID: UUID
    let controller: TripController

    var body: some View {
        if !items.isEmpty {
            Section(title) {
                ForEach(items) { item in
                    TripChecklistRow(item: item, tripID: tripID, controller: controller)
                }
                .onDelete { controller.removeChecklistItems($0, snapshot: items, tripID: tripID) }
            }
        }
    }
}

#if DEBUG
#Preview("Checklist section") {
    let model = PreviewFixtures.tripPlanner()
    let trip = model.library.trips[0]
    List { TripChecklistSection(title: "To do", items: trip.checklist, tripID: trip.id, controller: TripController(model: model)) }
}
#Preview("Checklist section · large text") {
    let model = PreviewFixtures.tripPlanner()
    let trip = model.library.trips[0]
    List { TripChecklistSection(title: "To do", items: trip.checklist, tripID: trip.id, controller: TripController(model: model)) }
        .dynamicTypeSize(.accessibility2)
}
#endif
