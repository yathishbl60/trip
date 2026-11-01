import TripLocalization
import TripDomain
import SwiftUI

struct TripAssistantControls: View {
    let tripID: UUID
    let controller: TripController

    var body: some View {
        Section {
            if let reason = controller.model.assistant.unavailableReason {
                Label(reason, systemImage: "info.circle").foregroundStyle(.secondary)
                Button(TripText.planItMyself.resource, action: controller.dismissAssistant)
            } else if controller.model.library.trip(tripID)?.savedPlaces.isEmpty != false {
                Button(TripText.findPlacesForThisTrip.resource, systemImage: "magnifyingglass") {
                    controller.findAssistantPlaces(tripID)
                }
            } else {
                preferences
                generationAction
            }
        } header: { Text(TripText.yourPlan.resource) }
    }

    private var preferences: some View {
        Group {
            NavigationLink {
                TripAssistantPlacesView(controller: controller)
            } label: {
                LabeledContent(TripText.places.resource, value: controller.model.assistant.selection.summary)
            }
            Button(TripText.findMorePlaces.resource, systemImage: "plus") { controller.findAssistantPlaces(tripID) }
            Stepper(controller.model.assistant.dayCountText, value: controller.planningDayCount, in: TripLimits.planningDays)
            Picker(TripText.pace.resource, selection: controller.planningPace) {
                ForEach(TripPlanningPace.allCases) { Text($0.title).tag($0) }
            }
            Picker(TripText.interests.resource, selection: controller.planningFocus) {
                ForEach(TripPlanningFocus.allCases) { Text($0.title).tag($0) }
            }
            TextField(TripText.anythingElse.resource, text: controller.preferences, axis: .vertical).lineLimit(1...4)
                .accessibilityLabel(TripText.optionalPlanningPreferences.resource)
        }
    }

    @ViewBuilder private var generationAction: some View {
        if controller.model.assistant.isGenerating {
            HStack {
                ProgressView(TripText.creatingDraft.resource)
                Spacer()
                Button(TripText.cancel.resource, action: controller.cancelGeneration)
            }
        } else {
            Button(controller.model.assistant.days.isEmpty ? TripText.createDraft.text : TripText.updateDraft.text, systemImage: "sparkles") {
                controller.generatePlan(tripID)
            }
                .buttonStyle(TripButtonStyles.prominent)
                .tint(AppTheme.accentFill)
                .disabled(!controller.model.assistant.canGenerate)
        }
    }
}

#if DEBUG
#Preview("Preferences") {
    let model = PreviewFixtures.tripPlanner()
    model.assistant.reset(for: model.library.trips[0])
    return Form { TripAssistantControls(tripID: model.library.trips[0].id, controller: TripController(model: model)) }
}
#Preview("Generating · dark") {
    let model = PreviewFixtures.tripPlanner()
    model.assistant.isGenerating = true
    return Form { TripAssistantControls(tripID: model.library.trips[0].id, controller: TripController(model: model)) }
        .preferredColorScheme(.dark)
}
#endif
