import AppIntents

// Preserve shipped intent identities while exposing their existing actions to Siri.
extension OpenSavedTripIntent: ToolIntent {}

extension OpenSavedTripDetailIntent: ToolIntent {}

extension ReadTripItineraryIntent: ToolIntent {}

extension ReadTripDayIntent: ToolIntent {}

extension GetNextTripStepIntent: ToolIntent {}

extension ReadTripChecklistIntent: ToolIntent {}

extension AddTripChecklistItemIntent: ToolIntent {}

extension SetTripChecklistItemIntent: ToolIntent {}

extension OpenTripChecklistIntent: ToolIntent {}

extension SuggestTripPackingIntent: ToolIntent {}

extension DraftTripItineraryIntent: ToolIntent {}

extension ImportTripBookingIntent: ToolIntent {}

extension OpenExploreIntent: ToolIntent {}

extension OpenTripsIntent: ToolIntent {}

extension NewTripIntent: ToolIntent {}

extension CreateTripIntent: ToolIntent {}

extension FindPlaceForTripIntent: ToolIntent {}

extension StartTripDayIntent: ToolIntent {}

extension EndTripDayIntent: ToolIntent {}
