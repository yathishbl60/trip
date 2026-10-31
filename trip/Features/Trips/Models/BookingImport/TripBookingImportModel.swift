import Foundation
import Observation
import TripDomain
import TripLocalization

@MainActor @Observable final class TripBookingImportModel {
    let reader: any TripBookingReading
    var isPresented = false
    var isReading = false
    var proposal: TripBookingProposal?
    var sourceTrip: TripPlan?
    var dayID: UUID?
    var title = ""
    var kind = TripEventKind.reservation
    var location = ""
    var arrivalLocation = ""
    var departureCandidateID: Int?
    var arrivalCandidateID: Int?
    var departureZone = "Etc/UTC"
    var arrivalZone = "Etc/UTC"
    var error: String?
    var showsFileImporter = false
    var wantsEventReview = false
    var didConfirmTimeZones = false
    @ObservationIgnored var task: Task<Void, Never>?
    @ObservationIgnored var generation = 0
    @ObservationIgnored let fileLoader = TripBookingFileLoader()

    init(reader: any TripBookingReading) { self.reader = reader }

    var hasSelectedTimes: Bool { departureCandidateID != nil || arrivalCandidateID != nil }
    var canReview: Bool { !isReading && (!hasSelectedTimes || didConfirmTimeZones) }

    func setValue<Value>(_ value: Value, at keyPath: ReferenceWritableKeyPath<TripBookingImportModel, Value>) {
        self[keyPath: keyPath] = value
        let clockFields: [AnyKeyPath] = [\TripBookingImportModel.departureCandidateID, \TripBookingImportModel.arrivalCandidateID,
                                         \TripBookingImportModel.departureZone, \TripBookingImportModel.arrivalZone]
        if clockFields.contains(keyPath) { didConfirmTimeZones = false }
    }

    func begin(trip: TripPlan, dayID: UUID) {
        cancel()
        sourceTrip = trip
        self.dayID = dayID
        departureZone = trip.timeZoneID ?? "Etc/UTC"
        arrivalZone = departureZone
        isPresented = true
    }

    func cancelReading() {
        generation += 1
        task?.cancel()
        task = nil
        isReading = false
    }

    func cancel() {
        cancelReading()
        isPresented = false
        proposal = nil
        sourceTrip = nil
        dayID = nil
        error = nil
        title = ""
        kind = .reservation
        location = ""
        arrivalLocation = ""
        showsFileImporter = false
        departureCandidateID = nil
        arrivalCandidateID = nil
        wantsEventReview = false
        didConfirmTimeZones = false
    }

    func accept(_ proposal: TripBookingProposal) {
        self.proposal = proposal
        title = proposal.suggestedTitle
        kind = proposal.suggestedKind
        location = proposal.suggestedLocation
        arrivalLocation = proposal.suggestedArrivalLocation
        departureCandidateID = nil
        arrivalCandidateID = nil
        didConfirmTimeZones = false
        error = nil
    }

    func review() {
        guard sourceTrip != nil, dayID != nil, canReview else { return }
        wantsEventReview = true
        isPresented = false
    }

    func fail(_ error: Error) {
        guard !(error is CancellationError) else { return }
        self.error = (error as? TripBookingImportError)?.errorDescription ?? TripText.bookingReadFailed.text
    }
}
