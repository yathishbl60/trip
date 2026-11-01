import TripLocalization
import TripDomain
import SwiftUI

struct TripAssistantView: View {
    @Environment(\.scenePhase) private var scenePhase
    let tripID: UUID
    let controller: TripController

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(TripText.planYourTrip.resource)
                #if os(iOS)
                .scrollEdgeEffectStyle(.soft, for: .top)
                #endif
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { tools }
        }
        .presentationDetents([.large])
        .presentationSizing(.form)
        .tripAssistantReviewPresentation(controller, tripID: tripID)
        .onDisappear { controller.cancelGeneration() }
        .onChange(of: controller.model.library.trip(tripID)?.savedPlaces) { controller.refreshAssistantPlaces(tripID) }
        .onChange(of: scenePhase) { if scenePhase == .active { controller.refreshIntelligenceAvailability() } }
    }

    private var content: some View {
        List {
            introduction
            TripAIProcessingSection(selection: controller.planningProcessing,
                                    explanation: controller.model.assistant.processing.planningExplanation,
                                    availableModes: TripAIConfiguration.availableModes)
            TripAssistantControls(tripID: tripID, controller: controller)
            if let error = controller.model.assistant.error { Text(error).foregroundStyle(.secondary) }
            if controller.model.assistant.needsNewDraft && !controller.model.assistant.isGenerating {
                Label(TripText.choicesChangedCreateANewDraft.resource, systemImage: "arrow.clockwise")
                    .foregroundStyle(.secondary)
            }
            ForEach(controller.model.assistant.days) { TripDraftDayView(day: $0) }
            if !controller.model.assistant.days.isEmpty {
                TripAssistantReviewView(tripID: tripID, controller: controller)
                draftInformation
            }
        }
    }

    private var introduction: some View {
        Section {
            HStack(spacing: AppTheme.Spacing.medium) {
                TripSymbolTile(symbol: "sparkles")
                VStack(alignment: .leading, spacing: AppTheme.Spacing.tight) {
                    Text(TripText.makeYourPlacesAPlan.resource).font(.title3.weight(.semibold))
                    Text(TripText.groupNearbyStopsWithAppleIntelligence.resource).font(.subheadline).foregroundStyle(.secondary)
                }
            }.padding(.vertical, AppTheme.Spacing.small)
        }
    }

    private var draftInformation: some View {
        Section {
            DisclosureGroup(TripText.aboutThisDraft.text) {
                Text(TripText.valueDistancesAreStraightLineEstimatesNotRoutesCheck(controller.model.assistant.draftOrigin).resource)
                    .font(.subheadline).foregroundStyle(.secondary)
            }
        }
    }

    @ToolbarContentBuilder private var tools: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(TripText.done.resource, action: controller.dismissAssistant)
        }
    }
}

#if DEBUG
#Preview("Itinerary assistant · local draft") {
    let model = PreviewFixtures.tripPlanner()
    model.assistant.reset(for: model.library.trips[0])
    model.assistant.days = model.library.trips[0].days
    return TripAssistantView(tripID: model.library.trips[0].id, controller: TripController(model: model))
}
#Preview("Intelligence unavailable · dark") {
    let model = PreviewFixtures.tripPlanner()
    model.assistant.unavailableReason = "Turn on Apple Intelligence in Settings to create a draft."
    return TripAssistantView(tripID: model.library.trips[0].id, controller: TripController(model: model))
        .preferredColorScheme(.dark)
}
#endif
