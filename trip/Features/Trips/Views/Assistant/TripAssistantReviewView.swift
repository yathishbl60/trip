import TripLocalization
import SwiftUI
import TripDomain

struct TripAssistantReviewView: View {
    let tripID: UUID
    let controller: TripController

    var body: some View {
        Section {
            refinements
            if let warning = controller.model.assistant.paceWarning {
                Label(warning, systemImage: "clock.badge.exclamationmark").foregroundStyle(.secondary)
            }
            Button(TripText.useThisPlan.resource, systemImage: "checkmark") { controller.requestAssistantApply(tripID) }
                .buttonStyle(.borderedProminent).tint(AppTheme.accentFill)
                .disabled(controller.model.assistantApplyIssue(tripID) != nil)
            Button(TripText.saveAsNewTrip.resource, systemImage: "plus.rectangle.on.rectangle") { controller.saveAssistantPlan(tripID) }
                .disabled(!controller.model.assistant.canSaveDraft || !controller.model.library.canCreate)
        } header: { Text(TripText.reviewYourPlan.resource) } footer: {
            if controller.model.assistant.canSaveDraft, let issue = controller.model.assistantApplyIssue(tripID) {
                Text(issue)
            }
        }
    }

    private var refinements: some View {
        Menu(TripText.refineDraft.resource, systemImage: "sparkles") {
            Button(TripText.lessBacktracking.resource, systemImage: "point.topleft.down.to.point.bottomright.curvepath") {
                controller.refineAssistant(.lessTravel, tripID: tripID)
            }
            Button(TripText.spreadOverAnotherDay.resource, systemImage: "calendar.badge.plus") {
                controller.refineAssistant(.moreTime, tripID: tripID)
            }.disabled(controller.model.assistant.dayCount >= TripLimits.planningDays.upperBound)
            Button(TripText.buildAroundFood.resource, systemImage: "fork.knife") {
                controller.refineAssistant(.food, tripID: tripID)
            }
        }.disabled(!controller.model.assistant.canSaveDraft || controller.model.assistant.unavailableReason != nil)
    }
}

extension View {
    func tripAssistantReviewPresentation(_ controller: TripController, tripID: UUID) -> some View {
        tripSavedPlaceSheet(controller, forAssistant: true)
            .confirmationDialog(TripText.useThisItinerary.resource, isPresented: controller.confirmingAssistantPlan,
                                titleVisibility: .visible) {
                Button(TripText.replaceItinerary.resource) { controller.applyAssistantPlan(tripID) }
            } message: {
                Text(TripText.thisChangesTheOrderAndDayOfYourPlanned.resource)
            }
    }
}

#if DEBUG
#Preview("Review itinerary · local draft") {
    let model = PreviewFixtures.tripPlanner()
    let trip = model.library.trips[0]
    model.presentation.assistantTripID = trip.id
    model.assistant.days = trip.days
    model.assistant.revision = TripItineraryRevision(trip)
    return List { TripAssistantReviewView(tripID: trip.id, controller: TripController(model: model)) }
}
#endif
