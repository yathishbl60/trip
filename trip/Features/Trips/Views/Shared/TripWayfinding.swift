import SwiftUI
import AppIntents
import TripLocalization
import TripDomain

struct TripSectionMenu: View {
    let tripID: UUID
    let section: TripSection
    let controller: TripController

    var body: some View {
        Picker(TripText.navigate.resource, selection: selection) {
            ForEach(TripSection.allCases, id: \.self) { section in
                Label(section.title, systemImage: section.symbol).tag(section)
            }
        }
        .pickerStyle(.inline)
        .disabled(controller.model.hasEditingSession)
    }

    private var selection: Binding<TripSection> {
        Binding(get: { section }, set: { controller.openSection($0, tripID: tripID) })
    }
}

private struct TripWayfinding: ViewModifier {
    let tripID: UUID
    let section: TripSection
    let controller: TripController

    func body(content: Content) -> some View {
        content
            .appEntityIdentifier(controller.tripEntityIdentifier(tripID))
            .toolbarTitleMenu { TripSectionMenu(tripID: tripID, section: section, controller: controller) }
            #if os(iOS)
            .navigationSubtitle(section == .itinerary ? "" : controller.tripTitle(tripID))
            #endif
    }
}

extension View {
    func tripWayfinding(_ section: TripSection, tripID: UUID, controller: TripController) -> some View {
        modifier(TripWayfinding(tripID: tripID, section: section, controller: controller))
    }
}

#if DEBUG
#Preview("Section navigation · native title menu") {
    let model = TripJourneyPreview.planner()
    NavigationStack {
        TripEditorView(tripID: model.library.trips[0].id, controller: TripController(model: model))
    }
}
#Preview("Section navigation · long title, large text") {
    let model = TripJourneyPreview.planner()
    Menu("A slow journey through northern Thailand") {
        TripSectionMenu(tripID: model.library.trips[0].id, section: .today, controller: TripController(model: model))
    }.dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif
