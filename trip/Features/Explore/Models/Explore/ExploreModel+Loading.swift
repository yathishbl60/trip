import TripLocalization
import MapEngine
import Foundation
import TripDomain

extension ExploreModel {
    func resumeVisibleContent() {
        filterPlaces()
        refreshAutocomplete()
        scheduleSearch()
        resumeDirections()
    }

    func load(revision: Int) async {
        guard !catalog.hasLoaded else { return }
        let interval = MapPerformance.begin("Load initial places")
        defer { MapPerformance.end("Load initial places", interval) }
        do {
            let snapshot = try await initialCatalog(revision: revision)
            try Task.checkCancellation()
            guard revision == activationRevision else { return }
            MapPerformance.measure("Publish initial places") { catalog.replace(with: snapshot) }
            catalog.hasLoaded = true
        } catch is CancellationError { return }
        catch {
            if revision == activationRevision {
                catalog.status = TripText.canTLoadPlaces.text
                catalog.canRetrySearch = true
            }
        }
    }

    private func initialCatalog(revision: Int) async throws -> CatalogSnapshot {
        let seeds = try await catalog.repository.seeds()
        try Task.checkCancellation()
        guard revision == activationRevision else { throw CancellationError() }
        return try await catalog.repository.merge(seeds, into: catalog.places, preserving: selectedPlace?.id)
    }
}
