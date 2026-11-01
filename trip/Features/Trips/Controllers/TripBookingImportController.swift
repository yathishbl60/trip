import Foundation
import PhotosUI
import SwiftUI
import TripDomain

@MainActor struct TripBookingImportController {
    let model: TripBookingImportModel

    var fileImporter: Binding<Bool> {
        Binding(get: { model.showsFileImporter }, set: { model.showsFileImporter = $0 })
    }

    func value<Value>(_ keyPath: ReferenceWritableKeyPath<TripBookingImportModel, Value>) -> Binding<Value> {
        Binding(get: { model[keyPath: keyPath] }, set: { model.setValue($0, at: keyPath) })
    }

    func chooseFile() { model.showsFileImporter = true }
    func fileChosen(_ result: Result<[URL], Error>) { model.loadFile(result) }
    func photoChosen(_ item: PhotosPickerItem?) { model.loadPhoto(item) }
    func cancel() { model.cancel() }
    func review() { model.review() }
    func sceneChanged(_ phase: ScenePhase) { if phase == .background { model.cancelReading() } }
}

extension TripController {
    var bookingImportPresented: Binding<Bool> {
        Binding(get: { model.bookingImport.isPresented }, set: { model.bookingImport.isPresented = $0 })
    }

    func beginBookingImport(tripID: UUID, dayID: UUID? = nil) {
        model.beginBookingImport(tripID: tripID, dayID: dayID)
    }

    func finishBookingImport() { model.finishBookingImport() }
}
