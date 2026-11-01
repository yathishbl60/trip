import PhotosUI
import SwiftUI
import TripDomain
import TripLocalization
import UniformTypeIdentifiers

struct TripBookingImportView: View {
    let controller: TripBookingImportController
    @State private var photo: PhotosPickerItem?
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            Form {
                sources
                if controller.model.isReading { ProgressView(TripText.bookingReadingDocument.resource) }
                if let error = controller.model.error { Section { Text(error).foregroundStyle(.secondary) } }
                if let proposal = controller.model.proposal {
                    TripBookingReviewView(controller: controller, proposal: proposal)
                }
            }
            .navigationTitle(TripText.bookingImport.resource).navigationBarTitleDisplayMode(.inline)
            .toolbar { tools }
            .onChange(of: photo) { _, item in controller.photoChosen(item); photo = nil }
            .onChange(of: scenePhase) { _, phase in controller.sceneChanged(phase) }
        }
        .fileImporter(isPresented: controller.fileImporter, allowedContentTypes: [.pdf, .image, .plainText],
                      allowsMultipleSelection: false, onCompletion: controller.fileChosen)
    }

    private var sources: some View {
        Section {
            Button(action: controller.chooseFile) { Label(TripText.bookingChooseDocument.resource, systemImage: "doc") }
            PhotosPicker(selection: $photo, matching: .images) {
                Label(TripText.bookingChoosePhoto.resource, systemImage: "photo")
            }
        } footer: {
            Text(TripText.bookingImportExplanation.resource)
        }
        .disabled(controller.model.isReading)
    }

    @ToolbarContentBuilder private var tools: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) { Button(TripText.cancel.resource, action: controller.cancel) }
        ToolbarItem(placement: .confirmationAction) {
            Button(controller.model.proposal == nil ? TripText.bookingEnterManually.text : TripText.bookingReviewDetails.text,
                   action: controller.review).disabled(!controller.model.canReview)
        }
    }
}

extension View {
    func tripBookingImportSheet(_ controller: TripController) -> some View {
        sheet(isPresented: controller.bookingImportPresented, onDismiss: controller.finishBookingImport) {
            TripBookingImportView(controller: TripBookingImportController(model: controller.model.bookingImport))
        }
    }
}

#if DEBUG
#Preview("Booking import · local document review") {
    TripBookingImportView(controller: TripBookingImportController(model: TripBookingPreview.model()))
}
#Preview("Booking import · large text and dark") {
    TripBookingImportView(controller: TripBookingImportController(model: TripBookingPreview.model()))
        .dynamicTypeSize(.accessibility3).preferredColorScheme(.dark)
}
#Preview("Booking import · unreadable document") {
    let model = TripBookingPreview.model()
    model.proposal = nil
    model.error = TripText.bookingNoReadableText.text
    return TripBookingImportView(controller: TripBookingImportController(model: model))
}
#endif
