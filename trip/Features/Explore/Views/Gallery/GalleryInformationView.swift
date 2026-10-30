import SwiftUI
import TripLocalization

struct GalleryInformationView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Text(TripText.gallerySampleExplanation.resource)
                Link(TripText.galleryPhotoCredits.resource, destination: URL(string: "https://unsplash.com/license")!)
            }
            .navigationTitle(TripText.galleryAboutSamples.resource)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button(role: .close) { dismiss() } } }
            #if os(iOS)
            .scrollEdgeEffectStyle(.soft, for: .top)
            #endif
        }.presentationDetents([.medium, .large])
    }
}

#Preview("Sample photo information") {
    GalleryInformationView()
}
