import TripDomain

extension AppModel {
    func connectExplore() {
        explore.environment = ExploreEnvironment(
            savePlace: { [weak trips] in trips?.chooseDestination(for: $0) },
            dismissSave: { [weak trips] in trips?.dismissDestination() },
            isSavingPlace: { [weak trips] in trips?.hasPendingPlaceSave == true },
            savedPlaces: { [weak trips] in trips?.library.savedPlaceIndex.places($0) ?? [] },
            openSavedPlace: { [weak self] in self?.openSavedPlace($0) },
            savedCatalog: { [weak trips] in trips?.library.savedMapGroups ?? [] }
        )
    }

    private func openSavedPlace(_ reference: TripSavedPlaceReference) {
        guard trips.library.savedPlaceIndex.places(reference.placeID).contains(where: { $0.id == reference.id }) else { return }
        if reference.dayNumber != nil {
            request(.savedDetail(TripDetailIdentity(tripID: reference.tripID, itemID: reference.stopID)))
        } else {
            request(.savedCollection(TripCollectionIdentity(tripID: reference.tripID, collectionID: reference.containerID)))
        }
    }
}
