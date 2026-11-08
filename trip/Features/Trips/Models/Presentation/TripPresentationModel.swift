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
    var placeSave: TripPlaceSaveSession?
    var editDraft: TripEditDraft?
    var assistantTripID: UUID?
    var tripToDelete: UUID?
    var dayToDelete: UUID?
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
            || stopTiming != nil || stopOrder != nil || savedPlacePicker != nil || placeSave != nil
            || dayToDelete != nil || tripToDelete != nil || planning != nil || weatherDestination != nil
    }

}
