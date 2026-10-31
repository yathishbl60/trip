import Foundation
import PhotosUI
import SwiftUI
import TripDomain

extension TripBookingImportModel {
    func load(_ document: TripBookingDocument) {
        start { document }
    }

    func loadFile(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            start { [fileLoader] in try await fileLoader.read(url) }
        case .failure(let error): fail(error)
        }
    }

    func loadPhoto(_ item: PhotosPickerItem?) {
        guard let item else { return }
        start {
            guard let photo = try await item.loadTransferable(type: TripBookingPhoto.self) else {
                throw TripBookingImportError.unreadable
            }
            return photo.document
        }
    }

    private func start(_ document: @escaping @MainActor () async throws -> TripBookingDocument) {
        cancelReading()
        guard isPresented else { return }
        let revision = generation
        error = nil
        isReading = true
        task = Task { [weak self] in
            guard let self else { return }
            do {
                let input = try await document()
                try Task.checkCancellation()
                let proposal = try await reader.read(input)
                guard generation == revision, isPresented, !Task.isCancelled else { return }
                accept(proposal)
            } catch { if generation == revision { fail(error) } }
            if generation == revision { isReading = false; task = nil }
        }
    }
}
