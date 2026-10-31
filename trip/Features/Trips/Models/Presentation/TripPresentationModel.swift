import TripDomain
import Observation
import Foundation
import SwiftUI

/// Transient navigation and form drafts; never written to the trip store.
@MainActor @Observable final class TripPresentationModel {
    var selectedTripID: UUID?
    var detailRoute: TripDetailRoute?
    var compactColumn = NavigationSplitViewColumn.sidebar
    var searchQuery = ""
    var sortOrder = TripSortOrder.recent
    var pendingPlace: Place?
    var editDraft: TripEditDraft?
    var assistantTripID: UUID?
    var tripToDelete: UUID?
    var dayToDelete: UUID?
    var collectionDraft: TripCollectionDraft?
    var checklistDraft: TripChecklistDraft?
    var packingTripID: UUID?
    var collectionToDelete: UUID?
    var savedPlacePicker: TripSavedPlacePickerModel?
    var planning: TripPlanningDraft?
    var stopOrder: TripStopOrderModel?
    var daySchedule: TripDayScheduleDraft?
    var stopTiming: TripStopTimingDraft?
    var eventDraft: TripEventDraft?
    var weatherDestination: TripWeatherDestination?
    var notice: String?

    var hasEditingSession: Bool {
        editDraft != nil || eventDraft != nil || assistantTripID != nil || daySchedule != nil
            || stopTiming != nil || stopOrder != nil || savedPlacePicker != nil || pendingPlace != nil
            || checklistDraft != nil || collectionDraft != nil || dayToDelete != nil || tripToDelete != nil
            || collectionToDelete != nil || packingTripID != nil || planning != nil || weatherDestination != nil
    }

}
