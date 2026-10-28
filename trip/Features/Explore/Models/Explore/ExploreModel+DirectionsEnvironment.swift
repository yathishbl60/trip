import TripRouting
import TripDomain
import MapEngine

extension ExploreModel {
    func configureDirections() {
        directions.configure(environment: DirectionsEnvironment(
            currentLocation: { [weak self] in self?.location.currentCoordinate },
            locationAuthorized: { [weak self] in self?.location.isAuthorized == true },
            requestLocation: { [weak self] in self?.requestDirectionsLocation() },
            loadedPlaces: { [weak self] in self?.catalog.places ?? [] },
            search: { [weak self] query in try await self?.searchDirectionsStops(query) ?? [] },
            close: { [weak self] in self?.dismissMapSheet() },
            sheetFrameChanged: { [weak self] frame in self?.directionsFrameChanged(frame) },
            placeTint: { $0.category.markerTint },
            appearance: DirectionsAppearance(actionTint: AppTheme.accentFill)
        ))
    }

    private func requestDirectionsLocation() {
        guard isActive, !location.isFollowing else { return }
        location.start()
    }

    private func searchDirectionsStops(_ query: String) async throws -> [Place] {
        let request = PlaceSearchRequest(area: SearchArea(camera.region), query: query, categories: [])
        return try await catalog.repository.search(request)
    }
}
