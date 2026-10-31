import TripLocalization
import TripDomain
import Foundation

extension TripLibraryModel {
    func load() async {
        guard !isReady else { return }
        if let loadTask { await loadTask.value; return }
        loadTask = Task { await readStoredTrips() }
        await loadTask?.value
        loadTask = nil
    }

    private func readStoredTrips() async {
        isLoading = true
        let startingRevision = revision
        defer { isLoading = false }
        do {
            let stored = try await store.load()
            acceptLoaded(stored, startingRevision: startingRevision)
            await onSaved(trips)
        } catch {
            loadError = TripText.couldnTOpenSavedTripsTryAgain.text
        }
    }

    func persist(changed tripID: UUID? = nil) {
        guard isReady else { return }
        if let tripID { changedTrips.insert(tripID) }
        else { needsFullSave = true }
        revision += 1
        saveTask?.cancel()
        saveTask = Task { [weak self] in
            do { try await Task.sleep(for: .milliseconds(250)) }
            catch { return }
            await self?.saveLocal()
        }
    }

    func saveLocal() async {
        guard isReady, needsFullSave || !changedTrips.isEmpty else { return }
        let currentRevision = revision
        let snapshot = trips
        do {
            try await store.save(snapshot, revision: currentRevision,
                                 changedIDs: needsFullSave ? nil : changedTrips)
            if revision == currentRevision {
                saveError = nil
                changedTrips.removeAll()
                needsFullSave = false
                await onSaved(snapshot)
            }
        } catch {
            if revision == currentRevision { saveError = TripText.yourLatestChangesWerenTSaved.text }
        }
    }

    func flush() async {
        saveTask?.cancel()
        await saveLocal()
    }
}
