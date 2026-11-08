import Foundation
import Testing
import TripDomain
@testable import trip

struct AppRequestParsingTests {
    @Test func preservesSavedTripAndChecklistLinks() throws {
        let id = UUID()
        let tripURL = try #require(URL(string: "trip://trip/\(id)"))
        let checklistURL = try #require(URL(string: "trip://trip/\(id)?surface=checklist"))
        #expect(AppRequest(url: tripURL) == .savedTrip(id))
        #expect(AppRequest(url: checklistURL) == .checklist(id, nil))
        #expect(AppRequest(url: try #require(URL(string: "trip://trips"))) == .trips)
    }

    @Test func preservesExactDetailIdentityAndMalformedItemFallback() throws {
        let tripID = UUID(), itemID = UUID()
        let detail = try #require(URL(string: "trip://trip/\(tripID)?surface=detail&item=\(itemID)"))
        let stale = try #require(URL(string: "trip://trip/\(tripID)?surface=detail&item=missing"))
        #expect(AppRequest(url: detail)?.operation == .destination(.linkedDetail(tripID, itemID)))
        #expect(AppRequest(url: stale)?.operation == .destination(.linkedDetail(tripID, nil)))
    }

    @Test(arguments: ["https://trip/trips", "trip://unknown", "trip://trip/not-a-uuid"])
    func ignoresUnsupportedLinks(_ address: String) throws {
        #expect(AppRequest(url: try #require(URL(string: address))) == nil)
    }
}
