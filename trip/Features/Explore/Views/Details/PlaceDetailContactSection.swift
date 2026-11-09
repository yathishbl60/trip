import TripLocalization
import SwiftUI
import TripDomain

struct PlaceDetailContactSection: View {
    let place: Place
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        Section {
            address
            phone
            website
            if PlaceCardController.supports(place) { PlaceNativeCardView(place: place) }
            if let url = place.mapsURL {
                Link(destination: url) { Label(TripText.openInAppleMaps.resource, systemImage: "map") }
            }
        } header: { Text(TripText.details.resource) } footer: {
            if place.isLive { Text(TripText.placeInformationFromAppleMaps.resource) }
        }
    }

    @ViewBuilder private var address: some View {
        if let address = place.address, !address.isEmpty {
            Label(address, systemImage: "mappin.and.ellipse")
                .font(.subheadline).fixedSize(horizontal: false, vertical: true).textSelection(.enabled)
        }
    }

    @ViewBuilder private var phone: some View {
        if let number = place.phoneNumber, !number.isEmpty {
            if let url = place.phoneURL {
                Link(destination: url) { Label(number, systemImage: "phone") }
                    .accessibilityLabel(TripText.callValue(number).resource)
                    .fixedSize(horizontal: false, vertical: true)
            } else { Label(number, systemImage: "phone").textSelection(.enabled) }
        }
    }

    @ViewBuilder private var website: some View {
        if let website = place.webURL {
            Link(destination: website) {
                Label(website.host() ?? TripText.website.text, systemImage: "globe")
                    .lineLimit(typeSize.isAccessibilitySize ? nil : 2).truncationMode(.middle)
                    .fixedSize(horizontal: false, vertical: true)
            }.accessibilityLabel(TripText.websiteValue(website.host() ?? place.name).resource)
        }
    }
}

#if DEBUG
#Preview("Live contact details") {
    List { PlaceDetailContactSection(place: PlaceDetailPreviewFixtures.live) }
}
#Preview("Contact details · large text") {
    List { PlaceDetailContactSection(place: PlaceDetailPreviewFixtures.live) }
        .dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#Preview("Limited place information") {
    List { PlaceDetailContactSection(place: PreviewFixtures.unrated) }
}
#Preview("Long contact details · narrow") {
    var place = PlaceDetailPreviewFixtures.live
    place.phoneNumber = "+66 2 623 5500"
    return List { PlaceDetailContactSection(place: place) }
        .frame(width: 320).dynamicTypeSize(.accessibility2)
}
#endif
