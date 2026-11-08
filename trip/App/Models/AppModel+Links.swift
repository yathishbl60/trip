import Foundation
import TripDomain
import TripLocalization

extension AppModel {
    func openURL(_ url: URL) {
        guard let request = AppRequest(url: url) else { return }
        self.request(request)
    }

    func openLinkedDetail(_ itemID: UUID?, tripID: UUID) {
        guard let trip = navigationPlan(tripID) else { return }
        if let itemID {
            let identity = TripDetailIdentity(tripID: tripID, itemID: itemID)
            if identity.resolve(in: TripSurfacePlan(trip)) != nil { openDetail(identity); return }
        }
        guard openSavedTrip(tripID) else { return }
        navigation.notice = TripText.thisSavedItemIsNoLongerAvailable.text
    }
}

extension AppRequest {
    init?(url: URL) {
        guard url.scheme?.lowercased() == "trip" else { return nil }
        if url.host?.lowercased() == "trips" { self = .trips; return }
        guard url.host?.lowercased() == "trip", let id = UUID(uuidString: url.lastPathComponent) else { return nil }
        let query = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        let surface = query.first { $0.name == "surface" }?.value
        if surface == "detail" {
            let item = query.first { $0.name == "item" }?.value.flatMap(UUID.init(uuidString:))
            self = Self(operation: .destination(.linkedDetail(id, item)))
        } else if surface == "checklist" { self = .checklist(id, nil) }
        else { self = .savedTrip(id) }
    }
}
