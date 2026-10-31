import TripLocalization
import TripDomain

extension TripAssistantModel {
    var draftOrigin: String {
        draftProcessing == .privateCloudCompute ? TripText.createdUsingAppleSPrivateCloudCompute.text : TripText.createdOnYourDevice.text
    }

    func daysPreservingDetails(from source: TripPlan) -> [TripDay] {
        let details = savedDetails(in: source)
        return days.map { day in
            var updated = day
            updated.stops = day.stops.map { restoring($0, from: details[$0.place.id]) }
            return updated
        }
    }

    private func savedDetails(in source: TripPlan) -> [String: TripStop] {
        var details: [String: TripStop] = [:]
        for stop in source.days.flatMap(\.stops) + source.collections.flatMap(\.stops) {
            var saved = details[stop.place.id] ?? stop
            if saved.notes.isEmpty { saved.notes = stop.notes }
            details[stop.place.id] = saved
        }
        return details
    }

    private func restoring(_ stop: TripStop, from source: TripStop?) -> TripStop {
        guard let source else { return stop }
        var updated = stop
        updated.notes = source.notes
        updated.timing = source.timing.unpinned
        return updated
    }
}
