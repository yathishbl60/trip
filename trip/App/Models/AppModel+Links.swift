import Foundation
import TripDomain
import TripLocalization

extension AppModel {
    func openURL(_ url: URL) {
        guard url.scheme?.lowercased() == "trip" else { return }
        if url.host?.lowercased() == "trips" {
            navigation.linkTask?.cancel()
            guard allowNavigation() else { return }
            navigation.tab = .trips
            trips.selectTrip(nil)
        }
        if url.host?.lowercased() == "trip", let id = UUID(uuidString: url.lastPathComponent) {
            navigation.linkTask?.cancel()
            guard allowNavigation() else { return }
            let query = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
            let surface = query.first { $0.name == "surface" }?.value
            let item = query.first { $0.name == "item" }?.value
            navigation.linkTask = Task { await resolveTripLink(id, surface: surface, item: item) }
        }
    }

    private func resolveTripLink(_ id: UUID, surface: String?, item: String?) async {
        await trips.library.load()
        guard !Task.isCancelled else { return }
        guard allowNavigation() else { return }
        navigation.tab = .trips
        guard trips.library.isReady else { return }
        guard let trip = trips.library.trip(id) else {
            navigation.notice = TripIntentError.missingTrip.errorDescription
            return
        }
        if surface == "detail" { openLinkedDetail(item, in: trip); return }
        if surface == "checklist" { openChecklist(id) }
        else { openSavedTrip(id) }
    }

    private func openLinkedDetail(_ item: String?, in trip: TripPlan) {
        if let item, let id = UUID(uuidString: item) {
            let identity = TripDetailIdentity(tripID: trip.id, itemID: id)
            if identity.resolve(in: TripSurfacePlan(trip)) != nil { openDetail(identity); return }
        }
        guard openSavedTrip(trip.id) else { return }
        navigation.notice = TripText.thisSavedItemIsNoLongerAvailable.text
    }

}
